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
		State 3: Decrypt RSA
		State 4: Buffer AES key
		State 5: ModExp loop
		State 6: Output AES key
		State 7: Wait for AES to finish
	*/

	/* RSA keys */
	logic [8575:0] input_buff; //input buffer
	logic [4095:0] exp_enc;
	logic [4095:0] mod_enc;
	logic [383:0] key_for_rsa;
	assign exp_enc = input_buff[4095:0];
	assign mod_enc = input_buff[8191:4096];
	assign key_for_rsa = input_buff[8575:8191];

	/* aes key to decrypt rsa keys */
	logic [255:0] aes_for_rsa;
	logic start_kb_decrypt; 
	logic start_rsa_decrypt;
	logic [4095:0] exp; //output of modexp module
	logic [4095:0] mod; //output of modexp module

	/* passphrase */
	logic [447:0] kbd; //56 character max passcode

	/* encrypted AES keys */
	logic [255:0] aes; //buffer

	/* decrypted AES keys */
	logic [255:0] aes_d; //output of AES module

	/* counts */
	integer count; //register


	/* AES Submodule */
	logic aes_kb_done; //AES for kb 
	logic aes_kb_valid; //AES valid for kb
	
	logic aes_done; //done decrypting NECESSARY?
	logic aes_valid; //data valid

	logic modexp_done; //modexp done NECESSARY?
	logic modexp_valid; //modexp valid


	aes_kb aes_kb_inst(.in_buf(key_for_rsa),.key(aes_for_rsa),.valid(aes_kb_valid), .done(aes_kb_done), .start(start_kb_decrypt), .*);
	aes_decrypt aes_inst();
	modexp modexp_inst (.exp(exp), .mod(mod), .key(key), .done(modexp_done), .valid(modexp_valid), .start(start_rsa_decrypt), .*);



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
					//if(aes_kb_done) begin
						if(aes_kb_valid) begin
							led_pass_o <= 1'b1;
							state <= 3'b011;
						end else begin
							led_fail_o <=1'b0;
							state <= 3'b001;
						end
					//end
				end
				3'b011: begin
					/* TODO */
					if(count == 16) begin
						state <= 3'b100;
						count <= 0;
					end else begin
						if(aes_done && aes_valid) begin
							count<=count+1;
						end
					end
				end
				3'b100: begin
					if(count == 8) begin
						state <= 3'b101;
						count <= 0;
					end else begin
						/* TODO */
						if(aes_valid_i) begin
							count = count + 1;
						end
					end
				end
				3'b101: begin
					/* TODO */
					/* if AES done */
					if(aes_done && aes_valid) begin
						state <= 3'b110;
						count <= 0;
					end else begin //undefined behavior
						state <= 3'b000;
						count <= 0;
					end
				end
				3'b110: begin
					if(count == 8) begin
						state <= 3'b111;
						count <= 0;
					end else begin 
						/* TODO */
						if(out_ready_i) begin
							count <= count + 1;
						end
					end
				end
				3'b111: begin
					/* TODO */
					if(out_ready_i) begin /* ready for next block */
						state <= 3'b100;
					end
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
					if(rsa_valid_i==1'b1) begin
						input_buff[(count*32 + 32)-1:count*32] = rsa_data_i;
						count = count + 1;
					end
				end
				3'b001: begin
					/* keyboard input */
					if(ps2_valid_i&&!ps2_done&&!ps2_valid_i) begin //don't buffer the enter key
						kbd[(8*count)+8-1:(8*count)] = ps2_data_i;
						count = count + 1;
					end else if(ps2_valid_i && ps2_reset) begin
						kbd = 'b0; //reset buffer
					end
				end
				3'b010: begin
					/* NONE */
				end
				3'b011: begin
					/* decrypt RSA */
					/* TODO */


				end
				3'b100: begin
					/* Encrypted AES Key */
					if(aes_valid_i) begin
						aes[(32*count) + 32 - 1: (32*count)] = aes_data_i;
						count = count + 1;
					end
				end
				3'b101: begin
					/* NONE */
				end
				3'b110: begin
					/* Output Key */
					if(out_ready_i) begin
						out_data_o <= aes_d[(count*32) + 32 - 1: (count*32)];
						count = count + 1;
					end
				end
				3'b111: begin
					/* NONE */
				end
			endcase
		end
	end



endmodule
