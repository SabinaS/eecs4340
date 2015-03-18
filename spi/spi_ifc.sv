`timescale 1ns/1ns
`include "defines.sv"

interface spi_ifc (
             input bit clk
          );

logic 			 rst;

logic 			 from_slave_i, read_i, write_i, valid_i, ready_i;
logic [2:0] 			 to_slave_o;
logic 			 ready_o, valid_o, ack_o;
logic 			 sclk_posedge_o, sclk_negedge_o;

wire [`BUS_WIDTH-1:0] 	 dat;

// note that the outputs and inputs are reversed from the dut
clocking cb @(posedge clk);
output 			 rst, from_slave_i, read_i, write_i, valid_i, ready_i;
input 			 to_slave_o, ready_o, valid_o, ack_o, sclk_posedge_o, sclk_negedge_o;
inout 			 dat;
endclocking

   modport bench (clocking cb);

modport dut (
           input  clk, rst, from_slave_i, read_i, write_i, valid_i, ready_i,
           output to_slave_o, ready_o, valid_o, ack_o, sclk_posedge_o, sclk_negedge_o,
           inout  dat
        );

// modport sdcard (
//     input to_slave_o,
//     output from_slave_i
// );

endinterface
