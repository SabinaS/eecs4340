module rsa_decryptor(
	clk, rst,
	key_i, key_valid_i, key_ready_o,
	dat_i, dat_valid_i, dat_ready_o,
	ps2_i, ps2_valid_i, ps2_ready_o, 
	key_o, key_valid_o, led_pass_o, led_fail_o
);
	input clk, rst;
	input key_valid_i, dat_valid_i, ps2_valid_i;
	input [31:0] key_i;
	input [31:0] dat_i;
	input [31:0] ps2_i; 
	output key_ready_o, dat_ready_o, ps2_ready_o;
	output [31:0] key_o;
	output key_valid_o;
	output led_pass_o, led_fail_o;

endmodule
