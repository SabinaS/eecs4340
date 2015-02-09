`timescale 1ns/1ns
module crc_7 (
	      clk, rst,
	      valid_i, dat_i,
	      crc_o
	      );

   input clk, rst;
   input valid_i, dat_i;
   output logic [6:0] crc_o;
   
   wire 	      inv;
   // XOR required?
   assign inv = dat_i ^ crc_o[6];
   
   always @(posedge clk) begin
      if (rst) begin
         crc_o <= '0;
      end else begin
         crc_o[6] <= valid_i ? crc_o[5]       : crc_o[6];
         crc_o[5] <= valid_i ? crc_o[4]       : crc_o[5];
         crc_o[4] <= valid_i ? crc_o[3]       : crc_o[4];
         crc_o[3] <= valid_i ? crc_o[2] ^ inv : crc_o[3];
         crc_o[2] <= valid_i ? crc_o[1]       : crc_o[2];
         crc_o[1] <= valid_i ? crc_o[0]       : crc_o[1];
         crc_o[0] <= valid_i ? inv            : crc_o[0];
      end
   end
   
endmodule