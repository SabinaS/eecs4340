`timescale 1ns/1ns
module keyboard_driver(
	input clk,
	input ps2_clk,

	output [15:0] char_o,
	output char_valid_o,

	inout ps2_dat,
);

endmodule
