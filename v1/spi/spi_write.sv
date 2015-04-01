`timescale 1ns/1ns

`include "directives.sv"
`include "defines.sv"

module spi_write (
   clk, rst,
   sclk_posedge, sclk_negedge, mosi, miso,
   bus_io, do_io_o, cmd_o, do_cmd_o,
   write_i, ready_o, ready_i, valid_i, valid_o, write_done_o,
   rsp_go_i, rsp_timeout_i, rsp_err_i, rsp_i,
   crc16_valid_o, crc16_dat_o, crc16_rst_o, crc16_i
);

   // Self evident
   input clk, rst;
   input sclk_posedge, sclk_negedge, miso;
   // write_i: a new write command has come in
   // valid_i: the data on bus_io is valid. Not really meaningful as we get that data when read_i is asserted
   // ready_i: the upstream module can accept the next block
   input write_i, valid_i, ready_i;
   // rsp_go_i: the response of the last command is favorable
   // rsp_timeout_i: the last command timedout
   // rsp_err_i: the last command produced an error. rsp_i will be valid in this case
   // rsp_i: always valid when rsp_err_i is asserted
   input rsp_go_i, rsp_timeout_i, rsp_err_i, rsp_i;
   // crc16_i: the data from the CRC module
   input [15:0] crc16_i;

   // mosi: For when we want to write data to the card
   output mosi;
   // valid_o: the data we wrote on bus_io is valid.
   // ready_o: the upsteam module can accept the next data block.
   // write_done_o: we have completed the write task. There's no more data to send to the upstream module
   output logic valid_o, ready_o, write_done_o;
   // do_cmd_o: We have a valid command and we want you to perform it. This is a pulsed signal
   // do_io_o: We have data on bus_io and we want you to patch us through
   output logic do_cmd_o, do_io_o;
   // cmd_o: the command we want you to perform. Valid when do_cmd_o is asserted
   output logic [`COMMAND_SIZE-1:0] cmd_o;
   // crc16_valid_o: the bit on crc16_dat_o is valid.
   // crc16_dat_o: the next bit to add to the crc
   // crc16_rst_o: to clear the crc value
   output logic 		    crc16_valid_o, crc16_dat_o, crc16_rst_o;

   // bus_io: for communicating with the upstream module
   inout [`BUS_WIDTH-1:0] 	    bus_io;

   // Bus data
   logic [`BUS_WIDTH-1:0] 	    bus_dat;
   // mosi data
   logic do_mosi;
   logic mosi_dat;

   // For holding the request parameters
   logic [`RW_AMOUNT_SIZE-1:0] 	    wcnt, wcnt_done;
   logic [`RW_ADDRESS_SIZE-1:0]     waddr;

   // The data buffer
   reg [`SD_BLOCK_SIZE-1:0] wbuf[`RW_BUF_COUNT-1:0], wbuf_slice;
   logic slice_ready, is_empty;
   logic [`RW_BUF_COUNT-1:0] wbuf_start, wbuf_end;
   // logic [`RW_BUF_COUNT_WIDTH-1:0]   wbuf_blocks_valid;
   // The dw task can only ever decrement, and the fm task can only ever increment
   logic wbuf_blocks_valid_delta_dw, wbuf_blocks_valid_delta_fm;

   // A backbuffer for filling wbuf asynchronously
   reg [`BUS_WIDTH-1:0] bbuffer[`BB_SLOTS-1:0], bb_ping, bb_pong;
   logic [`BB_SLOTS_WIDTH-1:0] bb_pos;   

   // The current number of bits written in this data block
   logic [`SD_BLOCK_SIZE_WIDTH-1:0] block_pos;
   logic [$clog2(16)-1:0] 	    send_crc16_pos;

   // Holding the data response for the latest block
   logic [`DAT_RSP_SIZE-1:0] dat_rsp;
   logic [`DAT_RSP_SIZE_WIDTH-1:0] dat_rsp_pos;

   // The start token holder
   logic [`START_TOKEN_SIZE-1:0]    st_tok;
   logic [`START_TOKEN_SIZE_WIDTH-1:0] st_tok_pos;

   logic [1:0] retry_count;

   // The writing states
   enum {FIDLE, READ_BUS} fat_proc;
   enum {BUFF_FILL, BUFF_FLUSH, FLUSH_WAIT, PAUSE} fat_read_state;
   enum {WIDLE, AWAIT_RSP, WRITING, DATA_RSP, WFINISH} write_proc;
   enum {START_TOKEN, DATA_BLOCK, CRC_BLOCK} write_state;
   enum {SEND_CMD, RSP_ERR, CMD_DONE} cmd_state;
   enum {MULT_WRITE, SINGLE_WRITE} write_type;
   enum {DWAIT, DRSP, DBUSY} dat_rsp_state;

   assign bus_io = do_io_o ? bus_dat : 'z;
   assign mosi = do_mosi ? mosi_dat : '1;

   always_ff @(posedge clk) begin
      if (rst) begin
         valid_o <= '0;
         ready_o <= '1;
         write_done_o <= '0;

         do_cmd_o <= '0;
         do_mosi <= '0;
         do_io_o <= '0;
         retry_count <= '0;

         crc16_valid_o <= '0;
         crc16_dat_o <= '0;
         crc16_rst_o <= '0;

         bus_dat <= '0;
         mosi_dat <= '0;
         cmd_o <= '0;

         dat_rsp <= '0;
         dat_rsp_pos <= '0;

         slice_ready <= '0;
         is_empty <= '0;
         bb_pos <= '0;

         wcnt <= '0;
         wcnt_done <= '0;
         waddr <= '0;
         wbuf_start <= '0;
         wbuf_end <= '0;
         send_crc16_pos <= 'd15;
         block_pos <= '0;

         wbuf_blocks_valid_delta_dw <= '0;
         wbuf_blocks_valid_delta_fm <= '0;
         st_tok <= `START_TOKEN_NOT_MULT_WRITE;

         // State
         fat_proc <= FIDLE;
         write_proc <= WIDLE;
      end
      // Reset takes precedence.
      else begin
         // Fat module communication
         if (fat_proc == FIDLE && write_i) begin
            // If they want us to write 0 blocks, then tell them we're already done
            if (bus_io[`RW_AMOUNT_END:`RW_AMOUNT_START] == '0)
               write_done_o <= '1;

            waddr <= bus_io[`RW_ADDRESS_END:`RW_ADDRESS_START];
            wcnt <= bus_io[`RW_AMOUNT_END:`RW_AMOUNT_START];
            fat_proc <= READ_BUS;
            fat_read_state <= BUFF_FILL;
         end
         else if (fat_proc == READ_BUS) begin
            if (fat_read_state == BUFF_FILL) begin
               // If the buffer will be full next cycle, also deassert ready
               if (valid_i && bb_pos + 'b1 == `BB_SLOTS) begin
                  bbuffer[bb_pos] <= bus_io;
                  bb_pos <= '0;
                  ready_o <= '0;
                  fat_read_state <= BUFF_FLUSH;
               end
               // Fill the buffer
               else if (valid_i) begin
                  bbuffer[bb_pos] <= bus_io;
                  bb_pos++;
               end
            end
            // Tell the background task to copy in the buffer
            else if (fat_read_state == BUFF_FLUSH) begin
               wbuf_blocks_valid_delta_fm <= 'b1;
               fat_read_state <= FLUSH_WAIT;
            end
            // Wait for that to complete
            else if (fat_read_state == FLUSH_WAIT) begin
               if (wbuf_blocks_valid_delta_fm == '0) begin
                  fat_read_state <= PAUSE;
               end
            end
            // Decide whether to loop or exit
            else if (fat_read_state == PAUSE) begin
               // We have no more data to write
               if (wcnt == wcnt_done + 1'b1) begin
                  fat_proc <= FIDLE;
                  ready_o <= '1;
               end
               else begin
                  // Our buffer is full, and we need to wait
                  if (wbuf_start == wbuf_end && !is_empty) begin
                     ready_o <= '1;
                     fat_read_state <= BUFF_FILL;
                     wcnt_done++;
                  end
               end
            end
         end

         // Data writing task
         // Wait for the buffer to be full (or for now, have 1 block)
         if (write_proc == WIDLE && wbuf_start != wbuf_end) begin
            // Format and issue command
            cmd_o[47:46] <= 2'b1;
            cmd_o[45:40] <= 6'd24;
            cmd_o[39:`RW_ADDRESS_SIZE+8] <= '0;
            cmd_o[`RW_ADDRESS_SIZE+7:8] <= waddr;
            cmd_o[7:0] <= '0;
            do_cmd_o <= '1;

            write_type <= SINGLE_WRITE;
            write_proc <= AWAIT_RSP;
         end
         else if (write_proc == AWAIT_RSP) begin
            do_cmd_o <= '0;
            if (rsp_go_i) begin
               write_proc <= WRITING;
               do_mosi <= '1;
               write_state <= START_TOKEN;
            end else if (rsp_timeout_i)
               write_proc <= WIDLE;
         end
         else if (write_proc == WRITING) begin
            if (write_state == START_TOKEN) begin
               if (sclk_posedge) begin
                  // Shifting is by MSB. The idea: the MSB of the 1st byte, then the MSB of the 2nd byte, and so on
                  mosi_dat <= st_tok[`START_TOKEN_SIZE-1];

                  if (st_tok_pos == `START_TOKEN_SIZE-1) begin
                     st_tok <= `START_TOKEN_NOT_MULT_WRITE;
                     st_tok_pos <= '0;
                     write_state <= DATA_BLOCK;
                     wbuf_slice <= wbuf[wbuf_start];
                  end else begin
                     st_tok <= {st_tok[`START_TOKEN_SIZE-2:0], 1'b0};
                     st_tok_pos++;
                  end
               end
            end
            else if (write_state == DATA_BLOCK) begin
               crc16_rst_o <= '0;
               if (sclk_posedge) begin
                  // Send the data over
                  mosi_dat <= wbuf_slice[block_pos];
                  crc16_dat_o <= wbuf_slice[block_pos];
                  crc16_valid_o <= '1;
                  block_pos++;
               end
               else if (block_pos == `SD_BLOCK_SIZE) begin
                  // Turn of the CRC block, send over the CRC block, and reset block_pos
                  crc16_valid_o <= '0;
                  block_pos <= '0;
                  write_state <= CRC_BLOCK;
               end
               else
                  crc16_valid_o <= '0;
            end
            else if (write_state == CRC_BLOCK) begin
               if (sclk_posedge) begin
                  // Send the crc
                  mosi_dat <= crc16_i[send_crc16_pos];
                  send_crc16_pos--;
               end
               else if (send_crc16_pos == '0) begin
                  mosi_dat <= '1;
                  send_crc16_pos <= 'd15;
                  write_proc <= DATA_RSP;
                  dat_rsp_state <= DWAIT;
                  do_mosi <= '0;
               end
            end
         end
         else if (write_proc == DATA_RSP) begin
            // Wait for the 0 signaling the start of the response
            if (dat_rsp_state == DWAIT) begin
               if (sclk_posedge)
                  if (miso == '0)
                     dat_rsp_state <= DRSP;
            end
            // Shift in the 4 bits
            else if (dat_rsp_state == DRSP) begin
               if (sclk_posedge) begin
                  dat_rsp <= {dat_rsp[`DAT_RSP_SIZE-2:0], miso};
                  dat_rsp_pos++;
               end
               else if (dat_rsp_pos == `DAT_RSP_SIZE) begin
                  dat_rsp_pos <= '0;
                  dat_rsp_state <= DBUSY;
               end
            end
            // Wait for miso to go high again
            else if (dat_rsp_state == DBUSY) begin
               if (sclk_posedge) begin
                  if (miso == '1) begin
                     // Check the response. If it's 0101, we're good
                     if (dat_rsp == 'b0101) begin
                        retry_count <= '0;
                        write_proc <= WFINISH;
                        wbuf_blocks_valid_delta_dw <= 'b1;
                     end
                     // CRC error or write error. Try again thrice
                     else if (retry_count < 'd3) begin
                        write_proc <= WIDLE;
                        retry_count++;
                     end else begin
                        // A terrible error has occured
                     end
                  end
               end
            end
         end
         else if (write_proc == WFINISH) begin
            wbuf_blocks_valid_delta_dw <= 'b1;
            write_proc <= WIDLE;
            // If the buffer only had 1 block, then we just finished writing it
            if ((wbuf_start + 'b1) % `RW_BUF_COUNT == wbuf_end)
               write_done_o <= '1;
         end
         else if (write_proc == WIDLE) begin
            do_mosi <= '0;
            mosi_dat <= '1;
            do_cmd_o <= '0;
            cmd_o <= '0;
            do_io_o <= '0;
            bus_dat <= '0;
            write_done_o <= '0;
         end

         // Background tasks
         // // The fat process finished. Update the buffer
         for (logic [`BB_SLOTS_WIDTH-1:0] i = 0; i < `BB_SLOTS; i++) begin
            if (wbuf_blocks_valid_delta_fm > '0 && !slice_ready) begin
               wbuf_slice[i*`BUS_WIDTH+:`BUS_WIDTH] <= bbuffer[i];
               slice_ready <= '1;
            end
         end
         // We completed the write. Shift the starting pointer
         if (wbuf_blocks_valid_delta_dw > '0) begin
            wbuf_start <= (wbuf_start + 'b1) % `RW_BUF_COUNT;
         end
         // We have a write, let's store it
         if (wbuf_blocks_valid_delta_fm > '0 && slice_ready) begin
            wbuf[wbuf_end] <= wbuf_slice;
            wbuf_end <= (wbuf_end + 'b1) % `RW_BUF_COUNT;
            wbuf_blocks_valid_delta_fm <= '0;
            slice_ready <= '0;
         end
         // // Another write of BUS_WIDTH bits would overflow the buffer
         // if (wbuf_blocks_valid + `BUS_WIDTH >= `RW_BUF_SIZE - (`BUS_WIDTH - 1)) begin
         //    ready_o <= '0;
         // end else begin
         //    ready_o <= '1;
         // end
      end
   end

endmodule
