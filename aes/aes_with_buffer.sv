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


	logic [127:0] key_sub, aes_in_sub, data_out_sub;
	logic [1:0] count_a,count_k,count_d;

	logic [127:0] key_, aes_in_sub, data_out_a;

	inv_aespipe aes_inst(.*); //ignore stall
	always_ff @(posedge clk) begin
		if(rst) begin
			key_sub <= 'b0;
			aes_in_sub <= 'b0;
			data_out_sub <= 'b0;
			count <= 'b0;
			aes_ready <= 1'b0;
			k_ready <= 1'b1;
		end else begin
			/* TODO */


		end
	end



	
endmodule
