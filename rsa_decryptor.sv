`timescale 1ns/1ns

module rsa_decryptor(
	clk, rst, stall,
	aes_data_i, aes_valid_i, aes_ready_o,
	rsa_data_i, rsa_valid_i, rsa_ready_o,
	ps2_data_i, ps2_valid_i, ps2_done, ps2_reset,
	out_data_o, out_valid_o, out_ready_i,
	led_pass_o, led_fail_o
);
	input clk, rst, stall;

	input aes_valid_i, rsa_valid_i;
	output aes_ready_o, rsa_ready_o;
	input [31:0] aes_data_i, rsa_data_i;

	input [7:0] ps2_data_i; 
	input ps2_done, ps2_reset, ps2_valid_i;

	output [31:0] out_data_o;
	output out_valid_o;
	input out_ready_i;

	output led_pass_o, led_fail_o;

	logic [3:0] state;
	/*
		State 0: Buffering RSA key from FS
		State 1: Buffering keyboard input
		State 2: Validate keyboard input
		State 3: Buffer AES key
		State 4: ModExp loop
		State 5: Output AES key
		State 6: Wait for AES to finish
	*/

	/* RSA keys */
	logic [4095:0] exp_enc;
	logic [4095:0] mod_enc;
	logic [383:0] aes_for_rsa;

	logic [4095:0] exp;
	logic [4095:0] mod;

	/* passphrase */
	logic [7:0] kbd [55:0]; //56 character max passcode


	/* encrypted AES keys */
	logic [255:0] aes;

	/* counts */
	integer count;


	/* AES Submodule */
	logic aes_kb_done;
	logic aes_kb_valid;

	logic aes_done;


	/* STATE MACHINE */
	always_ff @(posedge clk) begin
		if(rst) begin
			state <= 3'b000;
			led_pass_o <= 1'b0;
			led_fail_o <= 1'b0;
		end else begin
			case(state)
				3'b000: begin
					if(count==268) begin //(4096+4096+384)/32
						state <= 3'b001;
						count <= 0;
					end else begin
						/* TODO */
						if(rsa_valid_i) begin
							count <= count + 1;
						end
					end
				end
				3'b001: begin
					if(count==56 || ps2_done) begin
						state <= 3'b010;
						count <= 0;
					end else begin
						/* TODO */
						if(ps2_valid_i) begin
							count <= count + 1;
						end
					end
				end
				3'b010: begin
					if(aes_kb_done) begin
						if(aes_kb_valid) begin
							led_pass_o <= 1'b1;
							state <= 3'b011;
						end else begin
							led_fail_o <=1'b0;
							state <= 3'b001;
						end
					end
				end
				3'b011: begin
					if(count == 8) begin
						state <= 3'b100;
						count <= 0;
					end else begin
						/* TODO */
						if(aes_valid_i) begin
							count = count + 1;
						end
					end
				end
				3'b100: begin
					/* TODO */
					/* if AES done */
					if(aes_done && aes_valid) begin
						state <= 3'b100;
						count <= 0;
					end else begin //undefined behavior
						state <= 3'b000;
						count <= 0;
					end
				end
				3'b101: begin
					if(count == 8) begin
						state <= 3'b110;
						count <= 0;
					end else begin 
						/* TODO */
						if(out_ready_i) begin
							count <= count + 1;
						end
					end
				end
				3'b110: begin
					/* TODO */
					if(out_ready_i) begin /* ready for next block */
						state <= 3'b011;
					end
				end
				3'b111: begin
					/* Error --> reset */
					state <= 3'b000;
				end
			endcase
		end
	end


/* For Reference
	RSA keys 
	logic [4095:0] exp_enc;
	logic [4095:0] mod_enc;
	logic [383:0] aes_for_rsa;

	logic [4095:0] exp;
	logic [4095:0] mod;

	passphrase 
	logic [7:0] kbd [55:0]; //56 character max passcode


	encrypted AES keys
	logic [255:0] aes;
*/

	/* BUFFERS */
	always_ff @(posedge clk) begin 
		if(rst) begin
			exp_enc <= 'b0;
			mod_enc <= 'b0;
			exp <= 'b0;
			mod <= 'b0;
			kbd <= 'b0;
			aes <= 'b0;
		end else begin
			case(state)
				3'b000: begin
					/* buffer encrypted RSA stuff */
				end
				3'b001: begin
					/* keyboard input */
				end
				3'b010: begin
					/* NONE */
				end
				3'b011: begin
					/* NONE */
				end
				3'b100: begin
					/* NONE */
				end
				3'b101: begin
					/* Output Key */
				end
				3'b110: begin
					/* NONE */
				end
				3'b111: begin
					/* error */
				end
		end
	end



endmodule
