`timescale 1ns/1ns

module rsa_decryptor(
	clk, rst,
	key_i, key_valid_i, key_ready_o,
	dat_i, dat_valid_i, dat_ready_o,
	ps2_i, ps2_valid_i, ps2_ready_o, 
	key_read_o, dat_read_o,
	key_o, key_valid_o, led_pass_o, led_fail_o
);
	//key -> rsa key
	//ps2 -> keyboard
	//dat -> data block
	input clk, rst;
	// key_valid_i: the in from the key_fs is valid
	// dat_valid_i, the in from the dat_fs is valid
	// ps2_valid_i, the character from the keyboard module is valid
	input key_valid_i, dat_valid_i, ps2_valid_i;
	// The data from key_fs
	input [31:0] key_i;
	// The data from the dat_fs
	input [31:0] dat_i;
	// The data from the keyboard
	input [15:0] ps2_i; 
	// key_ready_o: backpressure to the key fs telling it to stall reading
	// dat_ready_o: backpressure to the data fs telling it to stall reading
	// ps2_ready_o: backpressure to the keyboard telling it not to send data. it
	//  is currently ignored
	output key_ready_o, dat_ready_o, ps2_ready_o;
	// key_read_o: the read operation signal to the key_fs
	// dat_read_o: the read operation signale to the dat_fs
	output key_read_o, dat_read_o;
	// key_o: data to the aes decryption module
	output [31:0] key_o;
	// whether the data on key_o is valid
	output key_valid_o;
	// Status signals to the status block
	output led_pass_o, led_fail_o;

endmodule
