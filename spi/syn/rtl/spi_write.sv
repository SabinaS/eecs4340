`timescale 1ns/1ns
module spi_write (
		  clk, sclk_posedge, rst,
		  mosi, miso,
		  write_i, bus_io, write_done_o,
		  crc7_valid_o, crc7_dat_o, crc7_rst_o, crc7_i,
		  crc16_valid_o, crc16_dat_o, crc16_rst_o, crc16_i
		  );

   parameter BUS_WIDTH = 128;

   input clk, sclk_posedge, rst;
   input write_i, miso;
   input [6:0] crc7_i;
   input [15:0] crc16_i;

   output 	mosi, write_done_o;
   output 	crc7_valid_o, crc7_dat_o, crc7_rst_o;
   output 	crc16_valid_o, crc16_dat_o, crc16_rst_o;

   inout [BUS_WIDTH-1:0] bus_io;

endmodule
