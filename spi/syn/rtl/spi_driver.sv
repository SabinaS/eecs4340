`timescale 1ns/1ns
module spi_driver (
    clk, rst,
    to_slave_o, dat, valid_o, ready_o, ack_o,
    from_slave_i, read_i, write_i, valid_i, ready_i
);

// The speed of clk.
parameter CLK_MHZ               = 50;
// The width of the device communication with the FAT32 module
parameter BUS_WIDTH             = 128;
// The number of cycles to toggle SCLK for during initialization
parameter SCLK_WAIT             = 74;

// See spi_command.sv for definitions
parameter COMMAND_SIZE         = 6 * 8;

// The number of bits needed to represent SCLK_WAIT
parameter SCLK_WAIT_WIDTH       = $clog2(SCLK_WAIT + 1);
// The number of cycles elapsed in CLK_MHZ to wait to toggle sclk during initialization
parameter SPI_CYCLE_INIT        = (CLK_MHZ * 1000000) / 400000;
// The number of cycles to wait to toggle sclk in normal operation
parameter SPI_CYCLE             = (CLK_MHZ * 1000000) / (25 * 1000000);
// The number of bits needed to represent SPI_CYCLE_INIT
parameter SPI_CYCLE_INIT_WIDTH  = $clog2(SPI_CYCLE_INIT);
// The number of cycles to wait for a millisecond to elapse..
parameter MILLISECOND_MHZ       = (CLK_MHZ * 1000000) / 1000;
// The number of bytes needed to represent MILLISECOND_MHZ
parameter MILLISECOND_MHZ_WIDTH = $clog2(MILLISECOND_MHZ + 1);
// The number of bits needed to represent all positions in COMMAND_SIZE
parameter COMMAND_SIZE_WIDTH = $clog2(COMMAND_SIZE);

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
/* The data bus for communicating with the FS module */
inout [BUS_WIDTH-1:0] dat;

// For controlling the value driving on dat
logic [BUS_WIDTH-1:0] dat_buf;
logic dat_enable;

// Some renaming for easier coding
logic sclk, mosi, ss;
wire miso, sclk_posedge;

// CRC. The modules get unfiltered access to the CRC modules, as they do buses, but this should also be fine as no two modules should be actively using a crc block.
logic crc7_valid, crc7_dat, crc7_rst;
logic crc16_valid, crc16_dat, crc16_rst;
wire [6:0] crc7_i;
wire [15:0] crc16_i;

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
wire [BUS_WIDTH-1:0] read_bus, write_bus;
wire read_done, write_done;
logic do_read, do_write;

wire read_crc7_valid, read_crc7_dat, read_crc7_rst;
wire read_crc16_valid, read_crc16_dat, read_crc16_rst;

wire write_crc7_valid, write_crc7_dat, write_crc7_rst;
wire write_crc16_valid, write_crc16_dat, write_crc16_rst;

wire read_mosi, write_mosi;

spi_read #(BUS_WIDTH) reader  (.mosi(read_mosi),
                               .bus_io(read_bus),
                               .read_done_o(read_done),
                               .read_i(do_read),
                               .crc7_valid_o(read_crc7_valid),
                               .crc7_dat_o(read_crc7_dat),
                               .crc7_rst_o(read_crc7_rst),
                               .crc16_valid_o(read_crc16_valid),
                               .crc16_dat_o(read_crc16_dat),
                               .crc16_rst_o(read_crc16_rst),
                               .*);
spi_write #(BUS_WIDTH) writer (.mosi(write_mosi),
                               .bus_io(write_bus),
                               .write_done_o(write_done),
                               .write_i(do_write),
                               .crc7_valid_o(write_crc7_valid),
                               .crc7_dat_o(write_crc7_dat),
                               .crc7_rst_o(write_crc7_rst),
                               .crc16_valid_o(write_crc16_valid),
                               .crc16_dat_o(write_crc16_dat),
                               .crc16_rst_o(write_crc16_rst),
                               .*);

// A register used to count up to 74 SPI cycles.
logic [SCLK_WAIT_WIDTH-1:0] spi_counter;
// For configuring the clock speed of the module. Since the lowest speed is SPI_CYCLE_INIT, we will need at most those bits to count and wait to toggle sclk. ss_toggle_value serves the purpose of dynamically setting the speed of sclk. Supports setting 
logic [SPI_CYCLE_INIT_WIDTH-1:0] ss_divider, ss_toggle_value;
// A register used to count up to the number of cycles needed to elapse for a a full millisecond at our clock speed.
logic [MILLISECOND_MHZ_WIDTH-1:0] ms_waiter;

// The register to hold the command for chifting it out
logic [COMMAND_SIZE-1:0] command;
logic [COMMAND_SIZE_WIDTH-1:0] command_pos;
logic command_sent;
logic command_done;

// STATES. The different "states" represented by this device, though more similar to mode of operation. Multiple states can be active at the same time, most commonly, SCLK_ACTIVE_STATE and READ_STATE/WRITE_STATE. Due to this, enums don't suite our purpose
parameter STATES = 12;
// The main states of SPI. A 1 means the state is currently active. At most one of these should be high at any time.
parameter INIT_STATE = 0;
parameter IDLE_STATE = 1;
parameter READ_STATE = 2;
parameter WRITE_STATE = 3;
// The SPI clock is active if this state is high
parameter SCLK_ACTIVE_STATE = 4;
// A value of 1 in this state means 74 SPI cycles have elapsed
parameter SCLK_WAIT_STATE = 5;
parameter MILLISECOND_WAIT_STATE = 6;
// Response processing
parameter RECEIVE_R1_STATE = 7;
parameter RECEIVE_R3_STATE = 8;
// The command flow of SPI initialization
parameter INIT_CMD0_STATE = 9;
parameter INIT_CMD8_STATE = 10;
parameter DO_COMMAND = 11;
// The state register. Used to condence the numerous 1 bit logic check registers. Take a look at the variables ending with _STATE to see what the different positions correspond to.
logic [STATES-1:0] state;

// Assignmens
assign miso = from_slave_i;
assign to_slave_o[0] = sclk;
assign to_slave_o[1] = mosi;
assign to_slave_o[2] = ss;
// It's time to toggle the value of sclk, and sclk was previously low
assign sclk_posedge = (ss_divider == ss_toggle_value - 1) && !sclk;
assign dat = dat_enable ? dat_buf : 'z;

// The behavior
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
        state[INIT_STATE] <= 1'b1;
        state[IDLE_STATE] <= 1'b0;
        state[READ_STATE] <= 1'b0;
        state[WRITE_STATE] <= 1'b0;
        state[SCLK_ACTIVE_STATE] <= 1'b0;
        state[SCLK_WAIT_STATE] <= 1'b0;
        state[MILLISECOND_WAIT_STATE] <= 1'b1;
        state[RECEIVE_R1_STATE] <= 1'b0;
        state[RECEIVE_R3_STATE] <= 1'b0;
        state[INIT_CMD0_STATE] <= 1'b0;
        state[INIT_CMD8_STATE] <= 1'b0;
        state[DO_COMMAND] <= 1'b0;

        // sclk values
        sclk <= '1;
        ss_divider <= '0;
        ss_toggle_value <= SPI_CYCLE_INIT;
        spi_counter <= '0;

        // Other initial states
        mosi <= '0;
        ss <= '0;
        ms_waiter <= '0;
        do_read <= '0;
        do_write <= '0;
        command <= '0;
        command_pos <= COMMAND_SIZE-1;
        command_sent <= '0;
        command_done <= '0;
        crc7_valid <= '0;
        crc7_dat <= '0;
        crc7_rst <= '1;
        crc16_valid <= '0;
        crc16_dat <= '0;
        crc16_rst <= '1;
        $display("Resetting");
        $display("MILLISECOND_MHZ: %d, MILLISECOND_MHZ_WIDTH: %d", MILLISECOND_MHZ, MILLISECOND_MHZ_WIDTH);
    // Reset takes precedence. remainder of the behavior
    end else begin
        // Toggle sclk
        if (state[SCLK_ACTIVE_STATE]) begin
            // Time to toggle
            ss_divider <= ss_divider == ss_toggle_value - 1 ? '0 : ss_divider + 1'b1;
            sclk <= ss_divider == ss_toggle_value - 1 ? ~sclk : sclk;
        end
        // Send out a command
        // DO_COMMAND has a latency of 1
        if (state[DO_COMMAND]) begin
            if (sclk_posedge) $display("command: %b, mosi: %d, command << 1: %b, crc7_i: %b, command_pos: %d", command, mosi, command << 1, crc7_i, command_pos);
            // Shift out the bits
            if (!command_sent) begin
                if (command_pos == 0) command_sent <= '1;
                command <= sclk_posedge ? command << 1 : command;
                command_pos <= sclk_posedge ? command_pos - 1'b1 : command_pos;
                crc7_dat <= command[COMMAND_SIZE-1];
                crc7_valid <= sclk_posedge && command_pos > 7 && command_pos < 47 ? '1 : '0;
                if (command_pos <= 7 && command_pos >= 1 && sclk_posedge) begin
                    $display("crc7: %b", crc7_i);
                    mosi <= crc7_i[command_pos - 1];
                end else if (sclk_posedge)
                    mosi <= command[COMMAND_SIZE-1];
            end else begin
                // End the command session
                if (sclk_posedge) begin
                    mosi <= '1;
                    command_done <= '1;
                    command_sent <= '0;
                    command <= '0;
                    command_pos <= '0;
                    state[DO_COMMAND] <= '0;
                end
            end
        end

        // Initialization
        if (state[INIT_STATE]) begin
            if (state[MILLISECOND_WAIT_STATE]) begin
                ms_waiter <= ms_waiter + 1'b1;
                // Drive the resets of the crc modules low
                crc7_rst <= '0;
                crc16_rst <= '0;

                state[MILLISECOND_WAIT_STATE] <= ms_waiter == MILLISECOND_MHZ ? '0 : '1;
                // Activate sclk
                state[SCLK_ACTIVE_STATE] <= ms_waiter == MILLISECOND_MHZ  ? '1 : '0;
                // The next phase is SCLK_WAIT_STATE
                state[SCLK_WAIT_STATE] <= ms_waiter == MILLISECOND_MHZ ? '1 : '0;
            end else if (state[SCLK_WAIT_STATE]) begin
                    ss <= '1;
                    mosi <= '1;

                    if (sclk_posedge) $display("spi_counter: %d @%d ns", spi_counter, $time);
                    spi_counter <= sclk_posedge ? spi_counter + 1'b1 : spi_counter;

                    // We're done waiting (technically, we will be one cycle into the SPI cycle, but that can't be helped since spi_counter == SCLK_WAIT - 1 would have us wait for a single cycle if SCLK_WAIT were 1, as opposed to the requisite number of ticks)
                    state[SCLK_WAIT_STATE] <= spi_counter == SCLK_WAIT ? '0 : '1;
                    state[INIT_CMD0_STATE] <= spi_counter == SCLK_WAIT ? '1 : '0;
            // State 0: send command
            end else if (state[INIT_CMD0_STATE]) begin
                // Formatting the CMD0 command
                if (!state[DO_COMMAND]) command <= {1'b0, 1'b1, 6'd0, 32'd0, 7'b0, 1'b1};
                state[DO_COMMAND] <= command_done ? '0 : '1;
                state[INIT_CMD0_STATE] <= command_done ? '0 : '1;
                state[RECEIVE_R1_STATE] <= command_done ? '1 : '0;
                if (command_done) command_done <= '0;
            end else if (state[RECEIVE_R1_STATE]) begin
            end
        end else if (state[READ_STATE]) begin
        end else if (state[WRITE_STATE]) begin
        end else if (state[IDLE_STATE]) begin
        end
    end
end

endmodule
