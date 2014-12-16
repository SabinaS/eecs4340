//inv_aespipe wrapper

module aes(
	clk, rst, stall,
	aes_in, key, data_out
);

	input clk, rst, stall;
	input [127:0] key;
	input [127:0] aes_in;
	output [127:0] data_out;//38 cycles later

	inv_aespipe aes_inst(.*); //ignore stall
	



