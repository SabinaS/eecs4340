`timescale 1ns/1ns

module aes_kb(
	clk, rst, stall,
	in_buf, kb, start,
	key, valid, done;
);
	input clk, rst, stall;
	input [383:0] in_buf;
	input [447:0] kb; 
	input start;
	output [127:0] key;
	output valid, done;

	//md5 md5_inst();
	//aes aes_inst();

	/* when start goes high, run the AES decryption
	 * when done, raise the output done signal
	 * if valid, also raise valid, otherwise dont
	 */

	 integer count; //counts time to process md5/aes


	 /* md5 kb and */





endmodule
