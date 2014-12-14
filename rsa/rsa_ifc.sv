`timescale 1ns/1ns

interface rsa_ifc (input bit clk);
	logic             rst, stall;

	logic [31:0]      rsa_data_i, aes_data_i, out_data_o;
	logic [7:0]       ps2_data_i;
	logic             rsa_valid_i, aes_valid_i, out_valid_o, ps2_valid_i;
	logic             rsa_ready_o, aes_ready_o, out_ready_i;
	logic             ps2_done, ps2_reset;

	logic             led_pass_o, led_fail_o;

	clocking cb @(posedge clk);
		output rst, stall;
		output rsa_data_i, aes_data_i, ps2_data_i;
		output rsa_valid_i, aes_valid_i, ps2_valid_i;
		output out_ready_i;
		output ps2_done, ps2_reset;

		input out_data_o;
		input out_valid_o;
		input rsa_ready_o, aes_ready_o;
		input led_pass_o, led_fail_o;
	endclocking

	modport bench (clocking cb);

	modport dut (
		input clk, rst, stall,
		input rsa_data_i, aes_data_i, ps2_data_i,
		input rsa_valid_i, aes_valid_i, ps2_valid_i,
		input out_ready_i,
		input ps2_done, ps2_reset,

		output out_data_o,
		output out_valid_o,
		output rsa_ready_o, aes_ready_o,
		output led_pass_o, led_fail_o
	);


endinterface
