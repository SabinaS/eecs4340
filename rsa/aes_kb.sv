`timescale 1ns/1ns

module aes_kb(
	clk, rst, stall,
	in_buf, key, start,
	valid, done;
);
	input clk, rst, stall;
	input [383:0] in_buf;
	input start;
	output [127:0] key;
	output valid, done;

	md5 md5_inst();
	aes aes_inst();



endmodule
