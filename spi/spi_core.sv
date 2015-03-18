`timescale 1ns/1ns
`include "defines.sv"

module spi_core (
          clk, rst,
          to_slave_o, dat, valid_o, ready_o, ack_o,
          from_slave_i, read_i, write_i, valid_i, ready_i,
          sclk_posedge_o, sclk_negedge_o
       );

// See spi_driver for details on the inputs and outputs
input clk, rst;
input from_slave_i, read_i, write_i, valid_i, ready_i;
output [2:0] to_slave_o;
output 	ready_o, valid_o, ack_o;
output 	sclk_posedge_o, sclk_negedge_o;
inout [`BUS_WIDTH-1:0] dat;

spi_driver driver (.*);

endmodule
