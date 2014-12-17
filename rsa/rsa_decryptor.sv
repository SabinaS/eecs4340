`timescale 1ns/1ns

module rsa_decryptor(
	clk, rst, stall,
	aes_data_i, aes_valid_i, aes_ready_o,
	rsa_data_i, rsa_valid_i, rsa_ready_o,
	ps2_data_i, ps2_valid_i, ps2_done, ps2_reset,
	out_data_o, out_valid_o, out_ready_i,
	led_pass_o, led_fail_o
);
	input logic clk, rst, stall;

	input logic aes_valid_i, rsa_valid_i;
	output logic aes_ready_o, rsa_ready_o;
	input logic [31:0] aes_data_i, rsa_data_i;

	input logic [7:0] ps2_data_i; 
	input logic ps2_done, ps2_reset, ps2_valid_i;

	output logic [31:0] out_data_o;
	output logic out_valid_o;
	input logic out_ready_i;

	output logic led_pass_o, led_fail_o;

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
	//logic [31:0] input_buff [0:267]; //input buffer
	logic [4095:0] exp_enc; //convert to 
	logic [4095:0] mod_enc;
	logic [383:0] key_for_rsa;
	assign exp_enc = input_buff[4095:0]; 
	assign mod_enc = input_buff[8191:4096]; 
	assign key_for_rsa = input_buff[8575:8191]; 

	/* aes key to decrypt rsa keys */
	logic [127:0] aes_for_rsa;
	logic start_kb_decrypt; 
	logic start_rsa_decrypt;

	logic [8575:0] output_buff;
	//logic [31:0] output_buff [0:267];


	logic [4095:0] exp; //output of modexp module
	logic [4095:0] mod; //output of modexp module
	assign exp = output_buff[4095:0];
	assign mod = output_buff[8575:4096];

	/* passphrase */
	logic [447:0] kbd; //56 character max passcode
	//logic [31:0] kbd [0:55]; //56 character max passcode

	/* encrypted AES keys */
	logic [127:0] aes; //buffer
	//logic [31:0] aes [0:3]; //buffer

	/* decrypted AES keys */
	logic [127:0] aes_d; //output of AES module
	//logic [31:0] aes_d [0:3]; //output of AES module

	/* counts */
	integer count; //register


	/* AES Submodule */
	logic aes_kb_done; //AES for kb 
	logic aes_kb_valid; //AES valid for kb
	
	logic aes_done; //done decrypting NECESSARY?
	logic aes_valid; //data valid

	logic modexp_done; //modexp done NECESSARY?
	logic modexp_valid; //modexp valid

	logic start_aes_decrypt;


	aes_kb aes_kb_inst(.in_buf(key_for_rsa),.key(aes_for_rsa),.valid(aes_kb_valid), .done(aes_kb_done), .start(start_kb_decrypt), .kb(kbd), .*);
	//aes_decrypt aes_inst(.start(start_aes_decrypt), .*);
	modexp modexp_inst (.exp(exp), .mod(mod), .key_i(aes), .done(modexp_done), .valid(modexp_valid), .start(start_rsa_decrypt), .key_o(aes_d),.*);



	/* STATE MACHINE */
	always_ff @(posedge clk) begin
		if(rst) begin
			state <= 3'b000;
			led_pass_o <= 1'b0;
			led_fail_o <= 1'b0;
			aes_ready_o <= 1'b0;
			rsa_ready_o <= 1'b1;

		end else begin
			case(state)
				3'b000: begin //get all RSA stuff
					if(count==268) begin //(4096+4096+384)/32
						state <= 3'b001;
						count <= 0;
						rsa_ready_o<=1'b1;
					end else begin
						/* TODO */
						if(rsa_valid_i) begin
							count <= count + 1;
						end
					end
				end

				3'b001: begin //buffer keyboard input 
					if(count == 56 || (ps2_done && ps2_valid_i)) begin
						state <= 3'b010;
						count <= 0;
						start_kb_decrypt <= 1'b1;
					end else begin
						start_kb_decrypt <= 1'b0;
						if(ps2_valid_i && !ps2_reset) begin
							count <= count + 1;
						end else if(ps2_valid_i && ps2_reset) begin
							count <= 0;
						end 
					end
				end

				3'b010: begin //decrypt AES key from KB (validate input)
					start_kb_decrypt <= 1'b0;
					if(aes_kb_done && aes_kb_valid) begin
						led_pass_o <= 1'b1;
						state <= 3'b011;
						start_aes_decrypt <= 1'b1;
					end else if(aes_kb_done && !aes_kb_valid) begin
						led_fail_o <=1'b0;
						state <= 3'b001;
						start_rsa_decrypt <= 1'b0;
					end
				end

				3'b011: begin //decrypt 4096 RSA exp and 4096 RSA mod
					start_aes_decrypt <= 1'b0;
					if(count == 64) begin
						state <= 3'b100;
						count <= 0;
						aes_ready_o <= 1'b1;
					end else begin
						if(aes_done && aes_valid) begin
							count <= count + 1;
						end
					end
				end

				3'b100: begin //buffer encrypted AES keys
					if(count == 8) begin
						state <= 3'b101;
						count <= 0;
						aes_ready_o <= 1'b0; // one cycle too late??
						start_rsa_decrypt <= 1'b1;
					end else begin
						if(aes_valid_i) begin
							count <= count + 1;
						end
					end
				end

				3'b101: begin /* decrypt AES key */
					start_rsa_decrypt <= 1'b0;
					/* if AES done */
					if(aes_done && aes_valid) begin
						state <= 3'b110;
						count <= 0;
					end 
				end

				3'b110: begin /* send to AES data module */
					if(count == 8) begin
						state <= 3'b111;
						count <= 0;
					end else begin 
						if(out_ready_i) begin
							count <= count + 1;
						end
					end
				end

				3'b111: begin /* wait to go back to state 4 */
					if(out_ready_i) begin /* ready for next block */
						state <= 3'b100;
						aes_ready_o <= 1'b1;
					end
				end
			endcase
		end
	end

	/* BUFFERS */
	always_ff @(posedge clk) begin 
		if(rst) begin
			kbd <= 'b0;
			aes <= 'b0;
		end else begin
			case(state) 
				3'b000: begin 
					/* buffer encrypted RSA stuff */
					if(rsa_valid_i==1'b1) begin
						input_buff[count*32+:32] <= rsa_data_i;// convert to chunked
					end
				end
				
				3'b001: begin
					/* keyboard input */
					if(ps2_valid_i&&!ps2_done&&!ps2_valid_i) begin //don't buffer the enter key
						kbd[(8*count)+:8] <= ps2_data_i; // convert to chunked
					end else if(ps2_valid_i && ps2_reset) begin
						kbd <= 'b0; //reset buffer
					end
				end

				3'b010: begin
					/* Validate keyboard input */
					/* NONE */
				end
				
				3'b011: begin
					/* decrypt RSA */
					/* TODO */
					if(aes_done && aes_valid) begin
						output_buff[(count*32)+:32] <= aes_d; // convert to chunked
					end


				end
				
				3'b100: begin
					/* Encrypted AES Key */
					if(aes_valid_i) begin
						aes[(32*count)+:32] <= aes_data_i; // convert to chunked
					end
				end
				
				3'b101: begin
					/* NONE */
					/* decrpyt AES key */
				end
				
				3'b110: begin
					/* Output Key */
					if(out_ready_i) begin
						out_data_o <= aes_d[(count*32)+:32];// convert to chunked
						out_valid_o <= 1'b1;
					end
				end
				
				3'b111: begin
					/* NONE */
					/* wait for downstream to be ready again */
				end
			endcase
		end
	end



endmodule
