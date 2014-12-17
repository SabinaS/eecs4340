`timescale 1ns/1ns
module spi_command (
    clk, sclk, rst,
    mosi, miso,
    do_command_i, command_i, command_valid_i,
    response_o, response_valid_o,
    dat_io, dat_valid_io,
    control_o, control_valid_o
);

// Sending out commands
parameter COMMAND_WIDTH = 6 * 8;
parameter RESPONSE_WIDTH = 5 * 8;
parameter CONTROL_WIDTH = 8;
parameter DAT_WIDTH = 128;
parameter BUF_SIZE = 512 * 8;

parameter BUF_POS = $clog2(BUF_SIZE);

// Synchronous signals
input clk, sclk, rst;

// SPI interface
input miso;
output mosi;

// spi_ module communication
input do_command_i;
input [COMMAND_WIDTH-1:0] command_i;
input command_valid_i;
output [RESPONSE_WIDTH-1:0] response_o;
output response_valid_o;
output [CONTROL_WIDTH-1:0] control_o;
output control_valid_o;
inout [DAT_WIDTH-1:0] dat_io;
inout dat_valid_io;

// For sending out commmands
logic [COMMAND_WIDTH-1:0] command;
logic [COMMAND_WIDTH-1:0] command_shift_position;

// For holding data to read/write
logic [BUF_SIZE-1:0] buf;
logic 

always_ff @(posedge clk) begin
	if(rst) begin
		
	end else begin
		case (state) begin
		end
	end
end

endmodule
