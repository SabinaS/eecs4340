`timescale 1ns/1ns

`include "directives.sv"
`include "defines.sv"

module spi_read (
 clk, rst,
 sclk_posedge, sclk_negedge, miso,
 read_i, bus_io, do_io_o, valid_o, ready_o, ready_i, read_done_o,
 do_cmd_o, cmd_o,
 rsp_go_i, rsp_timeout_i, rsp_err_i, rsp_i,
 crc16_i, crc16_valid_o, crc16_dat_o, crc16_rst_o
 );

input clk, sclk_posedge, sclk_negedge, rst;
input read_i, miso;
input [15:0] crc16_i;
input rsp_go_i, rsp_timeout_i, rsp_err_i;
input [`R1_SIZE-1:0] rsp_i;

output logic read_done_o, valid_o;
output logic crc16_valid_o, crc16_dat_o, crc16_rst_o;
output logic do_cmd_o;
output logic [`COMMAND_SIZE-1:0] cmd_o;
output do_io_o;

inout [`BUS_WIDTH-1:0] bus_io;

// Bus data
logic [`BUS_WIDTH-1:0] bus_dat;
logic do_io;

// For holding the request parameters
logic [`RW_AMOUNT_SIZE-1:0] rcnt;
logic [`RW_ADDRESS_SIZE-1:0] raddr;
// The data buffer
logic [`RW_BUF_SIZE-1:0] rbuf;
logic [`RW_SIZE_WIDTH-1:0] rbuf_pos;

// The CRC16 received from the device; to check against our computed CRC16
logic [15:0] recv_crc16;
logic [$clog2(16)-1:0] recv_crc16_pos;
// The current number of bits read in this data block
logic [`SD_BLOCK_SIZE_WIDTH-1:0] block_pos;

// The reading states
enum {IDLE, COMMANDING, READING, WRITE_DATA, READ_DONE, PERM_FAIL} proc_state;
enum {SEND_CMD, AWAIT_RSP, RSP_ERR, CMD_DONE} cmd_state;
enum {MULT_READ, SINGLE_READ} read_type;
enum {START_TOKEN, DATA_BLOCK, CRC_BLOCK, CRC_CHECK} recv_state;

assign bus_io = do_io ? bus_dat : 'z;
assign do_io_o = do_io;

always_ff @(posedge clk) begin
   if (rst) begin
      reading <= '0;
      read_done_o <= '0;
      crc16_valid_o <= '0;
      crc16_dat_o <= '0;
      crc16_rst_o <= '1;
      do_io <= '0;
      rbuf <= '0;
      rbuf_pos <= '0;
      block_pos <= '0;
      bus_dat <= '0;
      rcnt <= '0;
      raddr <= '0;
      recv_crc16 <= '0;
      recv_crc16_pos <= '0;

      cmd_state <= SEND_CMD;
      proc_state <= IDLE;
   // Reset takes precedence.
   end else begin
      // First, take in the address and count
      if (proc_state == IDLE && read_i) begin
         raddr <= bus_io[`RW_ADDRESS_END:`RW_ADDRESS_START];
         rcnt <= bus_io[`RW_AMOUNT_END:`RW_AMOUNT_START];
         proc_state <= COMMANDING;
      // Send the command to the card
      end else if (proc_state == COMMANDING) begin
         if (cmd_state == SEND_CMD) begin
            if (rcnt > 1) begin
               cmd_o[47:46] <= 2'b1;
               cmd_o[45:40] <= 6'd18;
               cmd_o[39:`RW_ADDRESS_SIZE+8] <= '0;
               cmd_o[`RW_ADDRESS_SIZE+7:8] <= raddr;
               cmd_o[7:0] <= '0;

               do_cmd_o <= '1;
               read_type <= MULT_READ;
               cmd_state <= AWAIT_RSP;
            end else if (rcnt == 1) begin
               cmd_o[47:46] <= 2'b1;
               cmd_o[45:40] <= 6'd17;
               cmd_o[39:`RW_ADDRESS_SIZE+8] <= '0;
               cmd_o[`RW_ADDRESS_SIZE+7:8] <= raddr;
               cmd_o[7:0] <= '0;

               do_cmd_o <= '1;
               read_type <= SINGLE_READ;
               cmd_state <= AWAIT_RSP;
            // Unless we were asked to read a count of 0
            end else begin
               reading <= '0;
               proc_state <= READ_DONE;
               cmd_state <= SEND_CMD;
            end
         // Wait for the response
         end else if (cmd_state == AWAIT_RSP) begin
            if (rsp_go_i) begin
               if (read_type == SINGLE_READ) begin
                  recv_state <= START_TOKEN;
                  proc_state <= READING;
               end
            end
         end
      // Receiving the data
      end else if (proc_state == READING) begin
         if (recv_state == START_TOKEN) begin
         // Check for the 0 at the end of the token
         if (miso == 0)
            recv_state <= DATA_BLOCK;
         end else if (recv_state == DATA_BLOCK && sclk_posedge) begin
            // Store the data
            rbuf[rbuf_pos] <= miso;
            rbuf_pos++;

            // We're still receiving data
            if (block_pos != `SD_BLOCK_SIZE-1) begin
               block_pos++;

               // Shift in the crc
               crc16_valid_o <= '1;
               crc16_dat_o <= miso;
               crc16_rst_o <= '0;
            // We just received the last bit (when block_pos is 4095, we will be receiving the 4096th bit)
            end else begin
               recv_state = CRC_BLOCK;
               crc16_valid_o <= '0;
               block_pos <= '0;
            end
         end else if (recv_state == CRC_BLOCK && sclk_posedge) begin
            // Shift in the crc
            recv_crc16 <= {recv_crc16[14:0], miso};
            if (recv_crc16_pos != 15) begin
               recv_crc16_pos++;
            // We've received all of the crc
            end else begin
               recv_crc16_pos <= '0;
               recv_state <= CRC_CHECK;
            end
         end else if (recv_state == CRC_CHECK) begin
            // CRC Matches, good job
            if (crc16_i == recv_crc16) begin
               proc_state <= WRITE_DATA;
            // Retry
            end else if (read_type == SINGLE_READ) begin
               proc_state <= COMMANDING;
               cmd_state <= SEND_CMD;
               rbuf_pos <= rbuf_pos - SD_BLOCK_SIZE;
            end
         end
      end else if (proc_state == WRITE_DATA) begin
         // Make sure the upstream module is ready
         if (ready_i) begin
            bus_dat <= rbuf[`BUS_WIDTH-1:0];
            do_io <= '1;
            valid_o <= '1;
            rbuf_pos <= rbuf_pos - `BUS_WIDTH;
            // Shift the data
            rbuf[`RW_BUF_SIZE-`BUS_WIDTH-1:0] <= rbuf[`RW_BUF_SIZE-1:`BUS_WIDTH];
            rbuf[`RW_BUF_SIZE-1:`RW_BUF_SIZE-`BUS_WIDTH] <= '0;
            // We are currently on the write that will empty the buffer
            if (rbuf_pos - `BUS_WIDTH == 0) begin
               proc_state <= READ_DONE;
            end
         end
      end else if (proc_state == READ_DONE) begin
         read_done_o <= '1;
         proc_state <= IDLE;
         cmd_state <= SEND_CMD;
         valid_o <= '0;
         do_io <= '0;
      // In the idle state, reset everything
      end else if (proc_state == IDLE) begin
         reading <= '0;
         read_done_o <= '0;
         crc16_valid_o <= '0;
         crc16_dat_o <= '0;
         crc16_rst_o <= '1;
         do_io <= '0;
         bus_dat <= '0;
         rcnt <= '0;
         raddr <= '0;
      end
   end
end

endmodule
