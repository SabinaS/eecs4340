`timescale 1ns/1ns

module rsa_tb_adapter(
	rsa_ifc.dut dut 
);

	rsa_decryptor magical_box (
		.clk(dut.clk),
		.rst(dut.rst),
		.stall(dut.stall),
		
		.rsa_data_i(dut.rsa_data_i),
		.rsa_valid_i(dut.rsa_valid_i),
		.rsa_ready_o(dut.rsa_ready_o),
		
		.aes_data_i(dut.aes_data_i),
		.aes_valid_i(dut.aes_valid_i),
		.aes_ready_o(dut.aes_ready_o),

		.ps2_data_i(dut.ps2_data_i),
		.ps2_valid_i(dut.ps2_valid_i),
		.ps2_done(dut.ps2_done),
		.ps2_reset(dut.ps2_reset),

		.out_data_o(dut.out_data_o),
		.out_valid_o(dut.out_valid_o),
		.out_ready_i(dut.out_ready_i),

		.led_pass_o(dut.led_pass_o),
		.led_fail_o(dut.led_fail_o)
	); 
endmodule
