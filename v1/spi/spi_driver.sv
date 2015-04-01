`timescale 1ns/1ns
`include "directives.sv"
`include "spi_state_defines.sv"

module spi_driver (
   clk, rst,
   to_slave_o, dat, valid_o, ready_o, ack_o,
   from_slave_i, read_i, write_i, valid_i, ready_i,
   sclk_posedge_o, sclk_negedge_o
);

   /* the clock and reset signals */
   input clk, rst;
   /* from_slave_i: the MISO of the SPI protocol */
   /* read_i: asserted for a single cycle the fs module to begin a read
    operation. The first data token should be the address information */
   /* write_i: asserted for a single cycle (or more, but doesn't matter) by the fs
    module to begin a write operation. The first data token should be the
    address information. */
   /* valid_i: asserted by the fs module that the data on dat is valid */
   /* ready_i: asserted by the fs module if it is able to receive more data */
   input from_slave_i, read_i, write_i, valid_i, ready_i;
   // The wires connecting to the SPI slave of this master
   output [2:0] to_slave_o;
   /* ready_o: indicates to the fs module that this module is ready to receive a
    command */
   /* valid_o: indicates to the fs module that this module's data output is valid.
    */
   /* ack_o: acknowledges that a command has been received. Will be sent on the
    cycle following the first valid data input, and if not, the command was
    missed */
   output logic ready_o, valid_o, ack_o;
   output 	sclk_negedge_o, sclk_posedge_o;
   /* The data bus for communicating with the FS module */
   inout [`BUS_WIDTH-1:0] dat;

   // For controlling the value driving on dat
   logic [`BUS_WIDTH-1:0] dat_buf;
   logic 		  dat_enable;

   // Some renaming for easier coding
   logic 		  sclk, mosi, ss;
   wire 		  miso, sclk_posedge, sclk_negedge;

   // CRC. The modules get unfiltered access to the CRC modules, as they do buses, but this should also be fine as no two modules should be actively using a crc block.
   logic 		  crc7_valid, crc7_dat, crc7_rst;
   logic 		  crc16_valid, crc16_dat, crc16_rst;
   wire [6:0] 		  crc7_i;
   wire [15:0] 		  crc16_i;

   crc_7 crc7   (.valid_i(crc7_valid),
      .dat_i(crc7_dat),
      .crc_o(crc7_i),
      .rst(crc7_rst),
      .*);
   crc_16 crc16 (.valid_i(crc16_valid),
      .dat_i(crc16_dat),
      .crc_o(crc16_i),
      .rst(crc16_rst),
      .*);

   // The read and write submodules are given unfiltered access to the data bus to avoid sharing logic, seeing as the driver is the one that ultimately initiates the module.
   wire [`BUS_WIDTH-1:0]  read_bus, write_bus;
   wire 		  read_done, write_done;
   wire 		  read_do_io, write_do_io;

   wire 		  read_crc16_valid, read_crc16_dat, read_crc16_rst;

   wire 		  write_crc7_valid, write_crc7_dat, write_crc7_rst;
   wire 		  write_crc16_valid, write_crc16_dat, write_crc16_rst;

   wire 		  read_mosi, write_mosi;

   wire 		  read_do_cmd, write_do_cmd, read_cmd, write_cmd;
   wire 		  read_valid, write_valid, read_ready, write_ready;
   logic 		  read_rsp_go, write_rsp_go, read_rsp_timeout, write_rsp_timeout, read_rsp_err, write_rsp_err;
   logic [`R1_SIZE-1:0]   read_rsp, write_rsp;

   spi_read reader  (.bus_io(read_bus),
		     // We have data to present
      .do_io_o(read_do_io),
		     // The data on the bus is valid
      .valid_o(read_valid),
		     // We are ready to accept a new read command
      .ready_o(read_ready),
		     // We are done using spi_driver's resources
      .read_done_o(read_done),
		     // We need to communicate with the crc16 module
      .crc16_valid_o(read_crc16_valid),
      .crc16_dat_o(read_crc16_dat),
      .crc16_rst_o(read_crc16_rst),
		     // We need you to issue a command
      .do_cmd_o(read_do_cmd),
		     // This is the command to issue
      .cmd_o(read_cmd),
		     // These are the responses to the command given
      .rsp_go_i(read_rsp_go),
      .rsp_timeout_i(read_rsp_timeout),
      .rsp_err_i(read_rsp_err),
		     // Here is the response itself
      .rsp_i(read_rsp),
		     // Non-trivial:
		     //  ready_i - is the fat module ready to receive data
		     //  read_i - the fat module issued a command and data is on the bus
		     //  crc16_i - the crc16 data
      .*);
   // Everything is much the same as the spi_read
   spi_write writer (.mosi(write_mosi),
      .bus_io(write_bus),
      .do_io_o(write_do_io),
      .valid_o(write_valid),
      .ready_o(write_ready),
      .write_done_o(write_done),
      .crc16_valid_o(write_crc16_valid),
      .crc16_dat_o(write_crc16_dat),
      .crc16_rst_o(write_crc16_rst),
      .do_cmd_o(write_do_cmd),
      .cmd_o(write_cmd),
      .rsp_go_i(write_rsp_go),
      .rsp_timeout_i(write_rsp_timeout),
      .rsp_err_i(write_rsp_err),
      .rsp_i(write_rsp),
		     // Non-trivial (or different from spi_read)
		     //  valid_i - the data on the bus from the fat module is valid
		     //  mosi - The module writes non-commands to the device
      .*);
   logic 		  doing_write_command;

   // A register used to count up to 74 SPI cycles.
   logic [`SCLK_WAIT_WIDTH-1:0] spi_counter;
   // For configuring the clock speed of the module. Since the lowest speed is SPI_CYCLE_INIT, we will need at most those bits to count and wait to toggle sclk. ss_toggle_value serves the purpose of dynamically setting the speed of sclk. Supports setting the value to toggle at dynamically
   logic [1:0] 			ss_divider, ss_toggle_value;
   // A register used to count up to the number of cycles needed to elapse for a a full millisecond at our base clock speed.
   logic [`CYCLE_MILLISECOND_WDITH-1:0] ms_waiter;

   // The register to hold the command for shifting it out
   logic [`COMMAND_SIZE-1:0] 		command;
   logic [`COMMAND_SIZE_WIDTH-1:0] 	command_pos;
   logic 				crc7_active;
   logic 				command_sent;

   logic [`R1_SIZE-1:0] 		r1_response;
   logic [`R3_SIZE-1:0] 		r37_response;
   logic [`R1_SIZE_WIDTH-1:0] 		r1_pos;
   logic [`R3_SIZE_WIDTH-1:0] 		r37_pos;
   logic [1:0] 				response_received;
   logic 				response_initiated;
   logic 				r7_crc_err;
   logic 				await_response;
   logic 				rsp_err;

   logic [`TIMEOUT_WIDTH-1:0] 		timeout_counter;
   logic 				timeout;

   // The state register. Used to condence the numerous 1 bit logic check registers. Take a look at the variables ending with _STATE to see what the different positions correspond to.
   logic [`STATES-1:0] 			state;
   // Used by states to identify logical position
   logic 				right_acmd41;

   // Assignmens
   assign miso = from_slave_i;
   assign to_slave_o[0] = sclk;
   assign to_slave_o[1] = mosi;
   assign to_slave_o[2] = ss;
   // It's time to toggle the value of sclk, and sclk was previously low
   assign sclk_posedge = (ss_divider == ss_toggle_value - 1) && !sclk;
   assign sclk_negedge = (ss_divider == ss_toggle_value - 1) && sclk;
   assign sclk_posedge_o = sclk_posedge;
   assign sclk_negedge_o = sclk_negedge;
   assign dat = dat_enable ? dat_buf : 'z;

   assign read_rsp = r1_response;

   always_ff @(posedge clk) begin
      // init is asserted on reset
      if (rst) begin
         // Output initialization
         valid_o <= '0;
         ready_o <= '0;
         ack_o <= '0;
         // Dat initialization
         dat_enable <= '0;
         dat_buf <= '0;

         // State initialization
         state[`INIT_STATE] <= 1'b1;
         state[`IDLE_STATE] <= 1'b0;
         state[`READ_STATE] <= 1'b0;
         state[`WRITE_STATE] <= 1'b0;
         state[`SCLK_ACTIVE_STATE] <= 1'b0;
         state[`SCLK_WAIT_STATE] <= 1'b0;
         state[`MILLISECOND_WAIT_STATE] <= 1'b1;
         state[`DO_COMMAND] <= 1'b0;
         state[`RECEIVE_R1_STATE] <= 1'b0;
         state[`RECEIVE_R3_STATE] <= 1'b0;
         state[`RECEIVE_R7_STATE] <= 1'b0;
         state[`INIT_CMD0_STATE] <= 1'b0;
         state[`INIT_CMD8_STATE] <= 1'b0;
         state[`INIT_ACMD41_STATE] <= 1'b0;
         state[`INIT_CMD58_STATE] <= 1'b0;
         state[`INIT_CMD1_STATE] <= 1'b0;
         state[`INIT_CMD16_STATE] <= 1'b0;
         state[`INIT_CMD8_TIMED_OUT] <= 1'b0;
         command_sent <= 1'b0;
         await_response <= 1'b0;
         right_acmd41 <= 1'b0;

         // sclk values
         sclk <= '1;
         ss_divider <= '0;
         ss_toggle_value <= `SPI_CYCLE_INIT;
         spi_counter <= '0;

         // Other initial states
         mosi <= '1;
         ss <= '1;
         ms_waiter <= '0;

         command <= '0;
         command_pos <= `COMMAND_SIZE-1;
         crc7_active <= '0;

         crc7_valid <= '0;
         crc7_dat <= '0;
         crc7_rst <= '1;
         crc16_valid <= '0;
         crc16_dat <= '0;
         crc16_rst <= '1;

         r1_response <= '0;
         r1_pos <= '0;
         r37_response <= '0;
         r37_pos <= '0;
         r7_crc_err <= '0;
         response_received <= '0;
         response_initiated <= '0;

         timeout <= '0;
         timeout_counter <= '0;

         doing_write_command <= '0;

         `display(("RST: Resetting"));
         `display(("RST: `CYCLE_MILLISECOND: %0d, `CYCLE_MILLISECOND_WDITH: %0d", `CYCLE_MILLISECOND, `CYCLE_MILLISECOND_WDITH));

	 // Reset takes precedence. remainder of the behavior
      end
      else begin
         // Toggle sclk
         if (state[`SCLK_ACTIVE_STATE]) begin
            // Time to toggle
            ss_divider <= ss_divider == ss_toggle_value - 1 ? '0 : ss_divider + 1'b1;
            sclk <= ss_divider == ss_toggle_value - 1 ? ~sclk : sclk;
         end

         // Receiving responses
         if (state[`RECEIVE_R1_STATE] || state[`RECEIVE_R3_STATE] || state[`RECEIVE_R7_STATE]) begin
            // If we haven't started initiate the timeout
            if (timeout_counter < `TIMEOUT) begin
               timeout_counter <= timeout_counter + 1'b1;
               crc7_rst <= '0;
            end
            // A timeout occured
            if (timeout_counter == `TIMEOUT) begin
               `display(("RECEIVE_R#_STATE: timeout occured. R1: %b, R2: %b, R3: %b", state[`RECEIVE_R1_STATE], state[`RECEIVE_R3_STATE], state[`RECEIVE_R7_STATE]));
               timeout <= '1;
               // Reset receive state
               state[`RECEIVE_R1_STATE] <= '0;
               state[`RECEIVE_R3_STATE] <= '0;
               state[`RECEIVE_R7_STATE] <= '0;
               timeout_counter <= '0;
               response_initiated <= '0;
               r1_pos <= '0;
               r37_pos <= '0;
               crc7_rst <= '1;
            end

            if (sclk_posedge) begin
               // We're still waiting for a response to be initiated
               if (!response_initiated && !miso) begin
                  r7_crc_err <= '0;
                  rsp_err <= '0;
                  response_initiated <= '1;
                  if (state[`RECEIVE_R1_STATE]) begin
                     `display(("RECEIVE_R#_STATE: r1 response initiated"));
                     r1_response <= {r1_response[`R1_SIZE-2:0], miso};
                     r1_pos <= r1_pos + 1'b1;
                  end
                  else if (state[`RECEIVE_R3_STATE] || state[`RECEIVE_R7_STATE]) begin
                     `display(("RECEIVE_R#_STATE: r3/7 response initiated"));
                     r37_response <= {r37_response[`R3_SIZE-2:0], miso};
                     r37_pos <= r37_pos + 1'b1;
                  end
                  // Reset the timeout
                  timeout_counter <= '0;
               end
               // Shift in the response
               else if (response_initiated) begin
                  if (state[`RECEIVE_R1_STATE] && r1_pos <= `R1_SIZE) begin
                     // `display(("RECEIVE_R#_STATE: r1 pos: %0d", r1_pos));
                     r1_response <= {r1_response[`R1_SIZE-2:0], miso};
                     r1_pos <= r1_pos + 1'b1;
                  end
                  else if ((state[`RECEIVE_R3_STATE] || state[`RECEIVE_R7_STATE]) && r37_pos <= `R3_SIZE) begin
                     // `display(("RECEIVE_R#_STATE: r3/7 pos: %0d", r37_pos));
                     r37_response <= {r37_response[`R3_SIZE-2:0], miso};
                     r37_pos <= r37_pos + 1'b1;
                     if (r37_pos < `R3_SIZE-8) begin
                        // `display(("Adding to crc"));
                        crc7_dat <= miso;
                        crc7_valid <= '1;
                     end
                     else
                        crc7_valid <= '0;
                  end
               end
            end
            else
               crc7_valid <= '0;
            // We just received the last bit
            if (sclk_negedge && (r1_pos == `R1_SIZE || r37_pos == `R3_SIZE)) begin
               if (state[`RECEIVE_R1_STATE]) begin
                  `display(("RECEIVE_R#_STATE: r1_response: %b", r1_response));
                  response_received[`R1_RESPONSE_SLOT] <= '1;
                  if (r1_response[`R1_SIZE-1:`R1_SIZE-8] != '0) begin
                     `display(("RECEIVE_R#_STATE: response error"));
                     rsp_err <= '1;
                  end
               end
               else if (state[`RECEIVE_R3_STATE] || state[`RECEIVE_R7_STATE]) begin
                  `display(("RECEIVE_R#_STATE: r3/7_response: %b", r37_response));
                  response_received[`R37_RESPONSE_SLOT] <= '1;
                  // Check the crc
                  if (state[`RECEIVE_R7_STATE]) begin
                     `display(("RECEIVE_R#_STATE: response r7 CRC7: %b, calculated r7 CRC7: %b", r37_response[7:1], crc7_i));
                     r7_crc_err <= crc7_i == r37_response[7:1] ? '0 : '1;
                  end
                  if (r37_response[`R3_SIZE-1:`R3_SIZE-8] != '0) begin
                     `display(("RECEIVE_R#_STATE: response error"));
                     rsp_err <= '1;
                  end
               end
               // Reset receive state
               state[`RECEIVE_R1_STATE] <= '0;
               state[`RECEIVE_R3_STATE] <= '0;
               state[`RECEIVE_R7_STATE] <= '0;
               timeout_counter <= '0;
               response_initiated <= '0;
               r1_pos <= '0;
               r37_pos <= '0;
               crc7_rst <= '1;
            end
         end
         // Sending commands (the command is assumed to be ready to be sent if this state is activated)
         else if (state[`DO_COMMAND]) begin
            // if (sclk_posedge) `display(("command: %b, mosi: %0d, command << 1: %b, crc7_i: %b, command_pos: %0d", command, mosi, command << 1, crc7_i, command_pos));
            // if (sclk_posedge) `display(("dut: mosi @%0d ns: %0d",$time, mosi));
            // Activate the crc
            if (!crc7_active) begin
               crc7_active <= '1;
               crc7_rst <= '0;
            end
            else if (sclk_posedge) begin
               if (command_pos == `COMMAND_SIZE-1)
                  `display(("`DO_COMMAND: sending command: %b", command));
               crc7_dat <= command[`COMMAND_SIZE-1];
               crc7_valid <= command_pos > 7 ? '1 : '0;
               // We haven't shifted out all bits
               if (command_pos > 0) begin
                  command <= command << 1;
                  command_pos <= command_pos - 1'b1;
               end

               // Send the CRC
               if (command_pos <= 7 && command_pos >= 1) begin
                  if (command_pos == 7)
                     `display(("`DO_COMMAND: crc7 = [%b]", crc7_i));
                  mosi <= crc7_i[command_pos - 1];
               end
               // Or the command otherwise
               else if (command_pos > 0)
                  mosi <= command[`COMMAND_SIZE-1];
               // Or stop the transmission
               else if (command_pos == '0) begin
                  crc7_rst <= '1;
                  crc7_active <= '0;
                  crc7_valid <= '0;
                  command <= '0;
                  command_pos <= `COMMAND_SIZE-1;
                  state[`DO_COMMAND] <= '0;
                  mosi <= '1;
                  `display(("`DO_COMMAND: COMMAND SENT"));
               end
            end
            else
               crc7_valid <= '0;
            // Exit the command transmission state
            // if (sclk_negedge && command_pos == '0) begin
            // end
         end

         // Initialization
         if (state[`INIT_STATE]) begin
            if (state[`MILLISECOND_WAIT_STATE]) begin
               ms_waiter <= ms_waiter + 1'b1;
               // After a millisecond has elapsed, change the following states
               // Disable the millisecond wait state
               state[`MILLISECOND_WAIT_STATE] <= ms_waiter == `CYCLE_MILLISECOND ? '0 : '1;
               // Activate sclk
               state[`SCLK_ACTIVE_STATE] <= ms_waiter == `CYCLE_MILLISECOND  ? '1 : '0;
               // The next phase is `SCLK_WAIT_STATE
               state[`SCLK_WAIT_STATE] <= ms_waiter == `CYCLE_MILLISECOND ? '1 : '0;
            end
            else if (state[`SCLK_WAIT_STATE]) begin
               // According to the specification, we should hold the chip select high during the 74 clock period toggle
               ss <= '1;
               mosi <= '1;

               if (sclk_posedge)
                   // `display(("`SCLK_WAIT_STATE: spi_counter: %0d", spi_counter));
                  spi_counter <= sclk_posedge ? spi_counter + 1'b1 : spi_counter;

               // We're done waiting (technically, we will be one cycle into the SPI cycle, but that can't be helped since spi_counter == SCLK_WAIT - 1 would have us wait for a single cycle if SCLK_WAIT were 1, as opposed to the requisite number of ticks)
               state[`SCLK_WAIT_STATE] <= spi_counter == `SCLK_WAIT ? '0 : '1;
               state[`INIT_CMD0_STATE] <= spi_counter == `SCLK_WAIT ? '1 : '0;
               // Send CMD0
            end
            else if (state[`INIT_CMD0_STATE]) begin
               // Formatting the CMD0 command
               if (!state[`DO_COMMAND] && !command_sent && !await_response) begin
                  // `display(("command: %b", {1'b0, 1'b1, 6'd0, 32'd0, 7'b0, 1'b1}));
                  command <= {2'b01, 6'd0, 32'd0, 7'b0, 1'b1};
                  state[`DO_COMMAND] <= '1;
                  command_sent <= '1;
                  `display(("`INIT_CMD0_STATE: CMD0 issued"));
                  // Wait for `DO_COMMAND to be de-asserted by the command routine
               end
               else if (!state[`DO_COMMAND] && command_sent && !await_response) begin
                  state[`RECEIVE_R1_STATE] <= '1;
                  await_response <= '1;
                  `display(("`INIT_CMD0_STATE: CMD0 sent"));
                  // Wait to receive a response or timeout
               end
               else if (response_received || timeout) begin
                  if (response_received[`R1_RESPONSE_SLOT]) begin
                     // As per the spec, the card should be in the idle state as indicated by a 1 in the R! response frame
                     if (r1_response == 1'b1) begin
                        response_received[`R1_RESPONSE_SLOT] <= '0;
                        state[`INIT_CMD0_STATE] <= '0;
                        state[`INIT_CMD8_STATE] <= '1;
                        command_sent <= '0;
                        await_response <= '0;
                     end
                  end
               end
            end
            // Then send CMD8
            else if (state[`INIT_CMD8_STATE]) begin
               // `display(("command_done = %0d @%0d ns", command_done, $time));
               // Formatting the CMD8 command
               if (!state[`DO_COMMAND] && !command_sent) begin
                  // `display(("command: %b", {1'b0, 1'b1, 6'd0, 32'd0, 7'b0, 1'b1}));
                  command <= {2'b01, 6'd8, 32'h1AA, 7'b0, 1'b1};
                  state[`DO_COMMAND] <= '1;
                  command_sent <= '1;
                  `display(("`INIT_CMD8_STATE: CMD8 (%b) issued", {2'b01, 6'd8, 32'h1AA, 7'b0, 1'b1}));
               end
               // Wait for `DO_COMMAND to be de-asserted by the command routine
               else if (!state[`DO_COMMAND] && command_sent) begin
                  state[`INIT_CMD8_STATE] <= '0;
                  state[`INIT_ACMD41_STATE] <= '1;
                  state[`RECEIVE_R7_STATE] <= '1;
                  command_sent <= '0;
                  `display(("`INIT_CMD8_STATE: CMD8 sent"));
               end
            end
            else if (state[`INIT_ACMD41_STATE]) begin
               // Wait to receive an R7
               if ((response_received[`R37_RESPONSE_SLOT] || timeout) && !command_sent && !await_response) begin
                  state[`DO_COMMAND] <= '1;
                  command_sent <= '1;
                  // If we timedout or an error occured, send a clear ACMD41
                  if (right_acmd41 || timeout || r37_response[`R3_SIZE-1:`R3_SIZE-`R1_SIZE-1] != '0) begin
                     command <= {2'b01, 6'd41, 32'h0, 7'b0, 1'b1};
                     right_acmd41 <= '1;
                     `display(("`INIT_ACMD41_STATE: ACMD41 (%b) issued", {2'b01, 6'd41, 32'h0, 7'b0, 1'b1}));
                  end
                  else begin
                     command <= {2'b01, 6'd41, 2'b01, 30'h0, 7'b0, 1'b1};
                     `display(("`INIT_ACMD41_STATE: ACMD41 (%b) issued", {2'b01, 6'd41, 2'b01, 30'h0, 7'b0, 1'b1}));
                  end
                  // Clear response status
                  response_received[`R37_RESPONSE_SLOT] <= '0;
                  timeout <= '0;
               end
               // Wait for the command to be completely sent
               else if (!state[`DO_COMMAND] && command_sent && !await_response) begin
                  state[`RECEIVE_R1_STATE] <= '1;
                  command_sent <= '0;
                  await_response <= '1;
               end
               // Transition decision
               else if ((response_received[`R1_RESPONSE_SLOT] || timeout) && await_response) begin
                  response_received[`R1_RESPONSE_SLOT] <= '0;
                  // On a timeout or error other 0x1, go to CMD1
                  if (right_acmd41 && (timeout || r1_response > 1)) begin
                     if (timeout)
                        `display(("`INIT_ACMD41_STATE: timeout occured, right_acmd41: %b", right_acmd41));
                     timeout <= '0;
                     state[`INIT_ACMD41_STATE] <= '0;
                     state[`INIT_CMD1_STATE] <= '1;
                  end
                  // Transition to CMD58 or CMD16 depending on which side we are
                  else if (r1_response == '0 && !timeout) begin
                     state[`INIT_ACMD41_STATE] <= '0;
                     if (right_acmd41)
                        state[`INIT_CMD16_STATE] <= '1;
                     else
                        state[`INIT_CMD58_STATE] <= '1;
                  end
                  // Loop back on outselves in this case
                  else if (r1_response == 1'b1 && !timeout) begin
                     response_received[`R37_RESPONSE_SLOT] <= '1;
                  end
                  command_sent <= '0;
                  await_response <= '0;
               end
            end
            // Get the OCR
            else if (state[`INIT_CMD58_STATE]) begin
               if (!state[`DO_COMMAND] && !command_sent && !await_response) begin
                  command <= {2'b01, 6'd58, 32'h0, 7'b0, 1'b1};
                  state[`DO_COMMAND] <= '1;
                  command_sent <= '1;
                  `display(("`INIT_CMD58_STATE: CMD58 (%b) issued", {2'b01, 6'd58, 32'h0, 7'b0, 1'b1}));
               end
               // Wait for the command to be sent
               else if (!state[`DO_COMMAND] && command_sent && !await_response) begin
                  await_response <= '1;
                  state[`RECEIVE_R3_STATE] <= '1;
                  `display(("`INIT_CMD58_STATE: CMD58 sent"));
               end
               else if (response_received[`R37_RESPONSE_SLOT]) begin
                  response_received <= '0;
                  await_response <= '0;
                  command_sent <= '0;
                  // If bit 30 (SDSC), we need to set the block size
                  if (r37_response[30] == 0) begin
                     state[`INIT_CMD16_STATE] <= '1;
                     state[`INIT_CMD58_STATE] <= '0;
                  end
                  // Initialization done
                  else if (r37_response[30] == 1) begin
                     state[`INIT_CMD58_STATE] <= '0;
                     state[`INIT_STATE] <= '0;
                     state[`IDLE_STATE] <= '1;
                  end
               end
            end // CMD58
            else if (state[`INIT_CMD1_STATE]) begin
               if (!state[`DO_COMMAND] && !command_sent && !await_response) begin
                  state[`DO_COMMAND] <= '1;
                  command <= {2'b01, 6'd1, 32'h0, 7'b0, 1'b1};
                  command_sent <= '1;
                  `display(("`INIT_CMD1_STATE: CMD1 (%b) issued", {2'b01, 6'd1, 32'h0, 7'b0, 1'b1}));
               end
               // Wait for the command to be sent
               else if (!state[`DO_COMMAND] && command_sent && !await_response) begin
                  await_response <= '1;
                  state[`RECEIVE_R1_STATE] <= '1;
                  `display(("`INIT_CMD1_STATE: CMD1 sent"));
                  // Await a response
               end
               else if (response_received[`R1_RESPONSE_SLOT]) begin
                  response_received <= '0;
                  await_response <= '0;
                  command_sent <= '0;
                  // If it's 1, start over (nothing needs to be done). If it's a 0, go to cmd16
                  if (r1_response == '0) begin
                     state[`INIT_CMD16_STATE] <= '1;
                     state[`INIT_CMD1_STATE] <= '0;
                  end
               end
            end
            else if (state[`INIT_CMD16_STATE]) begin
               if (!state[`DO_COMMAND] && !command_sent && !await_response) begin
                  state[`DO_COMMAND] <= '1;
                  command <= {2'b01, 6'd16, 32'h200, 7'b0, 1'b1};
                  command_sent <= '1;
                  `display(("`INIT_CMD16_STATE: CMD16 (%b) issued", {2'b01, 6'd16, 32'h200, 7'b0, 1'b1}));
               end
               // Wait for the command to be sent
               else if (!state[`DO_COMMAND] && command_sent && !await_response) begin
                  await_response <= '1;
                  state[`RECEIVE_R1_STATE] <= '1;
                  `display(("`INIT_CMD16_STATE: CMD16 sent"));
                  // Await a response
               end
               else if (response_received[`R1_RESPONSE_SLOT]) begin
                  // If it's 0, we're done
                  if (r1_response == '0) begin
                     response_received <= '0;
                     await_response <= '0;
                     command_sent <= '0;
                     state[`INIT_CMD16_STATE] <= '0;
                     state[`IDLE_STATE] <= '1;
                     state[`INIT_STATE] <= '0;
                  end
               end
            end
         end

         // Steady state
         else if (state[`READ_STATE]) begin
            // Delegate command over to the read module
            dat_enable <= read_do_io;
            valid_o <= read_valid;
            crc16_rst <= read_crc16_rst;
            crc16_dat <= read_crc16_dat;
            crc16_valid <= read_crc16_valid;

            // If we receive a command, do it
            if (read_do_cmd) begin
               if (!state[`DO_COMMAND] && !command_sent && !await_response) begin
                  state[`DO_COMMAND] <= '1;
                  command <= read_cmd;
                  command_sent <= '1;
                  `display(("`READ_STATE: CMD17/18 (%b) issued", read_cmd));
               end
            end
            // Wait for the command to be sent
            else if (!state[`DO_COMMAND] && command_sent && !await_response) begin
               await_response <= '1;
               state[`RECEIVE_R1_STATE] <= '1;
               `display(("`READ_STATE: CMD17/18 sent"));
            end
            // Await a response
            else if (await_response) begin
               if (response_received[`R1_RESPONSE_SLOT] || timeout) begin
                  response_received <= '0;
                  await_response <= '0;
                  command_sent <= '0;
                  if (timeout)
                     read_rsp_timeout <= '1;
                  else if (r1_response == '0)
                     read_rsp_go <= '1;
                  else begin
                     read_rsp_err <= '1;
                  end
               end
            end
            // Make sure not to accidentally inform the reader of a response
            else begin
               read_rsp_err <= '0;
               read_rsp_timeout <= '0;
               read_rsp_go <= '0;
            end

            if (read_done) begin
               state[`IDLE_STATE] <= '1;
               state[`READ_STATE] <= '0;
            end
         end
         else if (state[`WRITE_STATE]) begin
            // Delegate command over to the write module
            if (!doing_write_command)
               mosi <= write_mosi;
            dat_enable <= write_do_io;
            valid_o <= write_valid;
            crc16_rst <= write_crc16_rst;
            crc16_dat <= write_crc16_dat;
            crc16_valid <= write_crc16_valid;

            // If we receive a command, do it
            if (write_do_cmd) begin
               if (!state[`DO_COMMAND] && !command_sent && !await_response) begin
                  state[`DO_COMMAND] <= '1;
                  command <= read_cmd;
                  command_sent <= '1;
                  `display(("`READ_STATE: CMD17/18 (%b) issued", read_cmd));
               end
               doing_write_command <= '1;
            end
            // Wait for the command to be sent
            else if (!state[`DO_COMMAND] && command_sent && !await_response) begin
               await_response <= '1;
               state[`RECEIVE_R1_STATE] <= '1;
               `display(("`READ_STATE: CMD17/18 sent"));
            end
            // Await a response
            else if (await_response) begin
               if (response_received[`R1_RESPONSE_SLOT] || timeout) begin
                  response_received <= '0;
                  await_response <= '0;
                  command_sent <= '0;
                  if (timeout)
                     write_rsp_timeout <= '1;
                  else if (r1_response == '0)
                     write_rsp_go <= '1;
                  else begin
                     write_rsp <= '0;
                     write_rsp_err <= '1;
                  end
                  doing_write_command <= '0;
               end
            end
            // Make sure not to accidentally inform the writer of a response
            else begin
               write_rsp_err <= '0;
               write_rsp_timeout <= '0;
               write_rsp_go <= '0;
               write_rsp <= '0;
            end

            if (write_done) begin
               state[`IDLE_STATE] <= '1;
               state[`WRITE_STATE] <= '0;
            end
         end
         else if (state[`IDLE_STATE]) begin
            // Read received
            if (read_i) begin
               state[`READ_STATE] <= '1;
               state[`IDLE_STATE] <= '0;
            end
            // Write received
            else if (write_i) begin
               state[`WRITE_STATE] <= '1;
               state[`IDLE_STATE] <= '0;
            end

            // Don't drive any outputs
            dat_enable <= '0;
            valid_o <= '0;
            crc16_rst <= '1;
            crc16_dat <= '0;
            crc16_valid <= '0;
         end
      end
   end

endmodule
