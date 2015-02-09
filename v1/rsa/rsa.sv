`timescale 1ns/1ns

module rsa(
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
	input logic [127:0] aes_data_i, rsa_data_i;

	input logic [7:0] ps2_data_i; 
	input logic ps2_done, ps2_reset, ps2_valid_i;

	output logic [127:0] out_data_o;
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
	logic [8319:0] input_buff; //input buffer

	logic [4095:0] exp_enc; //convert to 
	logic [4095:0] mod_enc;

	logic [127:0] key_for_rsa;
	assign exp_enc = input_buff[4095:0]; 
	assign mod_enc = input_buff[8191:4096]; 
	assign key_for_rsa = input_buff[8319:8192]; 

	/* aes key to decrypt rsa keys */
	logic [127:0] aes_for_rsa;
	logic start_kb_decrypt; 
	logic start_rsa_decrypt;

	logic [8191:0] output_buff;


	logic [4095:0] exp; //output of modexp module
	logic [4095:0] mod; //output of modexp module
	assign exp = output_buff[4095:0];
	assign mod = output_buff[8191:4096];

	/* passphrase */
	logic [447:0] kbd; //56 character max passcode

	/* encrypted AES keys */
	//logic [4095:128] rsa_in;
        //assign rsa_in = 'b0;
	logic [4095:0] aes; //buffer

	/* decrypted AES keys */
	logic [4095:0] rsa_o;
	logic [127:0] aes_d; //output of AES module
	assign aes_d = rsa_o[127:0];

	/* counts */
	integer count; //register


	/* AES Submodule */
	logic aes_kb_done; //AES for kb 
	logic aes_kb_valid; //AES valid for kb
	
	logic aes_done; //done decrypting NECESSARY?
	logic aes_valid; //data valid

	logic modexp_done; //modexp done NECESSARY?
	logic modexp_valid; //modexp valid

	//logic start_aes_decrypt;
	logic [127:0] aes_in;
	logic [127:0] key_in;
	logic [127:0] aes_out;


	aes_kb aes_kb_inst(.in_buf(key_for_rsa),.key(aes_for_rsa),
		.valid(aes_kb_valid), .done(aes_kb_done), 
		.start(start_kb_decrypt), .kb(kbd), .*);
	aes aes_inst(.key(key_in), .aes_in(aes_in), .data_out(aes_out), .*);
	modexp modexp_inst (.exp(exp), .mod(mod), .key_i(aes), 
		.done(modexp_done), .valid(modexp_valid), 
		.start(start_rsa_decrypt), .key_o(rsa_o),.*);




	/* STATE MACHINE */
	always_ff @(posedge clk) begin
		if(rst) begin //reset
			state <= 3'b000;
			led_pass_o <= 1'b0;
			led_fail_o <= 1'b0;
			aes_ready_o <= 1'b0;
			rsa_ready_o <= 1'b1;
			count<=0;
		end else if(!stall) begin
			case(state)
				3'b000: begin //get all RSA stuff
					if(count==65) begin //(4096+4096+128)/128
						state <= 3'b001;
						count <= 0;
						rsa_ready_o<=1'b0;
					end else begin
						/* TODO */
						if(rsa_valid_i) begin
							count <= count + 1;
						end
					end
				end

				3'b001: begin //buffer keyboard input 
					if(count == 56|| (ps2_done && ps2_valid_i)) begin
						//$display("DUT input buff %d", input_buff);
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
					end else if(aes_kb_done && !aes_kb_valid) begin
						//start_aes_decrypt <= 1'b1;
						led_fail_o <=1'b1;
						count <= 0;
						//state <= 3'b001; 
						state <= 3'b011; //REMOVE
						start_rsa_decrypt <= 1'b0;
					end
				end

				3'b011: begin //decrypt 4096 RSA exp and 4096 RSA mod
					//start_aes_decrypt <= 1'b0;
					if(count == 101) begin //64-101 are good  TODO FIX
						state <= 3'b100;
						count <= 0;
						aes_ready_o <= 1'b1;
					end else begin
						count <= count + 1;
					end
				end

				3'b100: begin //buffer encrypted AES keys
					if(count == 32) begin //only takes 1 cycle now
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
					if(count==32) begin //CHANGE to count from 48 to 
						state <= 3'b110;
						count <= 0;
					end else begin
						count <= count + 1;
					end
				end

				3'b110: begin /* send to AES data module */
					//if(count == 8) begin
					if(out_ready_i) begin
						state <= 3'b111;
						count <= 0;
					end else begin 
					//	if(out_ready_i) begin
					//		count <= count + 1;
					//	end
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
			input_buff <= 'b0;
			kbd <= 'b0;
			aes <= 'b0;
			aes_in <= 'b0;
			key_in <= 'b0;
		end else if(!stall) begin
			case(state) 
				3'b000: begin 
					/* buffer encrypted RSA stuff */
					if(rsa_valid_i==1'b1) begin
						input_buff[count*128+:128] <= rsa_data_i;
					end
				end
				
				3'b001: begin //buffer keyboard input
					/* keyboard input */
					if(ps2_done && ps2_valid_i) begin
						//TODO Padding 
						//pad zeros up to 448
						if(count<56) begin
							case(count)
								0: kbd <= 'b0;
								1: kbd[447:8] <= 'b0;
								2: kbd[447:16] <= 'b0;
								3: kbd[447:24] <= 'b0;
								4: kbd[447:32] <= 'b0;
								5: kbd[447:40] <= 'b0;
								6: kbd[447:48] <= 'b0;
								7: kbd[447:56] <= 'b0;
								8: kbd[447:64] <= 'b0;
								9: kbd[447:72] <= 'b0;
								10: kbd[447:80] <= 'b0;
								11: kbd[447:88] <= 'b0;
								12: kbd[447:96] <= 'b0;
								13: kbd[447:104] <= 'b0;
								14: kbd[447:112] <= 'b0;
								15: kbd[447:120] <= 'b0;
								16: kbd[447:128] <= 'b0;
								17: kbd[447:136] <= 'b0;
								18: kbd[447:144] <= 'b0;
								19: kbd[447:152] <= 'b0;
								20: kbd[447:160] <= 'b0;
								21: kbd[447:168] <= 'b0;
								22: kbd[447:176] <= 'b0;
								23: kbd[447:184] <= 'b0;
								24: kbd[447:192] <= 'b0;
								25: kbd[447:200] <= 'b0;
								26: kbd[447:208] <= 'b0;
								27: kbd[447:216] <= 'b0;
								28: kbd[447:224] <= 'b0;
								29: kbd[447:232] <= 'b0;
								30: kbd[447:240] <= 'b0;
								31: kbd[447:248] <= 'b0;
								32: kbd[447:256] <= 'b0;
								33: kbd[447:264] <= 'b0;
								34: kbd[447:272] <= 'b0;
								35: kbd[447:280] <= 'b0;
								36: kbd[447:288] <= 'b0;
								37: kbd[447:296] <= 'b0;
								38: kbd[447:304] <= 'b0;
								39: kbd[447:312] <= 'b0;
								40: kbd[447:320] <= 'b0;
								41: kbd[447:328] <= 'b0;
								42: kbd[447:336] <= 'b0;
								43: kbd[447:344] <= 'b0;
								44: kbd[447:352] <= 'b0;
								45: kbd[447:360] <= 'b0;
								46: kbd[447:368] <= 'b0;
								47: kbd[447:376] <= 'b0;
								48: kbd[447:384] <= 'b0;
								49: kbd[447:392] <= 'b0;
								50: kbd[447:400] <= 'b0;
								51: kbd[447:408] <= 'b0;
								52: kbd[447:416] <= 'b0;
								53: kbd[447:424] <= 'b0;
								54: kbd[447:432] <= 'b0;
								55: kbd[447:440] <= 'b0;

							endcase
						end
						//top 64 bits are equal to length in bits mod (2^64)   but we can ignore mod

					end else if(ps2_valid_i&&!ps2_done&&!ps2_reset) begin //don't buffer the enter key
						kbd[(8*count)+:8] <= ps2_data_i; 
					end else if(ps2_valid_i && ps2_reset) begin
						kbd <= 'b0; //reset buffer
					end
				end

				3'b010: begin //decrypt AES key from KB (validate input)
					/* NONE */
					if(aes_kb_done && aes_kb_valid) begin
						key_in <= aes_for_rsa;
					end
				end
				
				3'b011: begin //decrypt 4096 RSA exp and 4096 RSA mod
					/* decrypt RSA */
					if(count<32) begin //decrypt exp
						aes_in <= exp_enc[(count*128)+:128];
					end else if(count<64) begin //decrypt mod
						aes_in <= mod_enc[((count-32)*128)+:128];
					end	
					if(count>=38) begin 
						output_buff[(count*128)+:128] <= aes_out; // 128 bit chunks
					end


				end
				
				3'b100: begin //buffer encrypted AES keys
					/* Encrypted AES Key */
					if(aes_valid_i) begin
						aes[(count*128)+:128] <= aes_data_i;
					end
				end
				
				3'b101: begin /* decrypt AES key */
					/* NONE */
					/* decrpyt AES key */
				end
				
				3'b110: begin /* send to AES data module */
					/* Output Key */
					if(out_ready_i) begin
						out_data_o <= aes_d;
						out_valid_o <= 1'b1;
					end
				end
				
				3'b111: begin /* wait to go back to state 4 */
					/* NONE */
					/* wait for downstream to be ready again */
				end
			endcase
		end
	end



endmodule
