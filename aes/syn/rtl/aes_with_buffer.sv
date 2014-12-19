//inv_aespipe wrapper

module aes_with_buffer(
	clk, rst, stall,
	aes_in, aes_valid, aes_ready,
	key, k_valid, k_ready,
	data_out, data_valid
);

	input logic clk, rst, stall;
	input logic [127:0] key;
	input logic k_valid;
	output logic k_ready;
	input logic [127:0] aes_in;
	input logic aes_valid;
	output logic aes_ready;
	output logic [127:0] data_out;//38 cycles later
	output logic data_valid;


	logic [127:0] key_sub, aes_in_sub, data_out_sub;

	logic run;
	integer count;


	inv_aespipe aes_inst(.aes_in(aes_in_sub), .key (key_sub), .data_out(data_out_sub),.*); //ignore stall

	always_ff @(posedge clk) begin
		if(rst) begin
			key_sub <= 'b0;
			aes_in_sub <= 'b0;
			data_out <= 'b0;
			aes_ready <= 1'b0;
			k_ready <= 1'b1;
			run <= 1'b0;
		end else if(!stall) begin
			if(k_valid) begin
				key_sub <= key;
				k_ready <= 1'b0;
				aes_ready <= 1'b1;
			end

			if(aes_ready) begin //input and start counting
				aes_in_sub <= aes_in;
				aes_ready <=1'b0;
				run <= 1'b1;
			end

			if(count==38) begin
				data_out <= data_out_sub;
				data_valid <= 1'b1;
			end

		end
	end


	always_ff @(posedge clk) begin 
		if(rst) begin
			 count <= 0;
		end else if(!stall) begin
			if(run) begin
				count <= count + 1;
			end
		end
	end


	
endmodule
