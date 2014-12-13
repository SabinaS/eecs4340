`timescale 1ns/1ns

module modexp(
	clk, rst, stall,
	exp, mod, key_i, start,
	key_o, done, valid
);
	input clk, rst, stall;
	input [4095:0] exp, mod;
	input [255:0] key_i;
	input start;
	output [255:0] key_o;
	output done, valid;



endmodule
