`timescale 1ns/1ns
module spi_core (
		 clk, rst,
		 to_slave_o, dat, valid_o, ready_o, ack_o,
		 from_slave_i, read_i, write_i, valid_i, ready_i,
		 sclk_posedge_o, sclk_negedge_o
		 );

   // See spi_driver.sv for definitions
   parameter CLK_MHZ = 50;
   parameter BUS_WIDTH = 128;
   parameter SCLK_WAIT = 74;

   // See spi_command.sv for definitions
   parameter COMMAND_WIDTH = 6 * 8;
   parameter INTERNAL_DAT_WIDTH = 8;
   parameter COMMAND_BUF_SIZE = INTERNAL_DAT_WIDTH;

   // See spi_driver for details on the inputs and outputs
   input clk, rst;
   input from_slave_i, read_i, write_i, valid_i, ready_i;
   output [2:0] to_slave_o;
   output 	ready_o, valid_o, ack_o;
   output 	sclk_posedge_o, sclk_negedge_o;
   inout [BUS_WIDTH-1:0] dat;

   spi_driver #(CLK_MHZ, BUS_WIDTH, SCLK_WAIT, COMMAND_WIDTH) driver (.*);

endmodule
