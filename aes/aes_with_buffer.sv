//inv_aespipe wrapper

module aes_with_buffer(
	clk, rst, stall,
	aes_in, aes_valid, aes_ready,
	key, k_valid, k_ready,
	data_out, data_valid
);

	input logic clk, rst, stall;
	input logic [31:0] key;
	input logic k_valid;
	output logic k_ready;
	input logic [31:0] aes_in;
	input logic aes_valid;
	output logic aes_ready;
	output logic [31:0] data_out;//38 cycles later
	output logic data_valid;

	inv_aespipe aes_inst(.*); //ignore stall




	
endmodule
