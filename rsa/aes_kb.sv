`timescale 1ns/1ns

module aes_kb(
	clk, rst, stall,
	in_buf, key, start,
	valid, done;
);
	input clk, rst, stall;
	input [383:0] in_buf;
	input start;
	output [255:0] key;
	output valid, done;



endmodule
