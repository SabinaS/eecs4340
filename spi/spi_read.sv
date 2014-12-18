`timescale 1ns/1ns
module spi_read (
    clk, sclk_posedge, rst,
    mosi, miso,
    read_i, bus_io
);

parameter BUS_WIDTH = 128;

input clk, sclk_posedge, rst;
input read_i, miso;

output mosi;

inout [BUS_WIDTH-1:0] bus_io;

endmodule
