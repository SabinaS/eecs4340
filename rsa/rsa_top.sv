`timescale 1ns/1ns
// the timescale directive tells the compiler the clock period and the
// precision that needs to be displayed in the VCD dump file

module rsa_top;

  // clock generator
  bit clk = 1;
  always #5 clk = ~clk;

  // command to generate the VCD dump file that you open with DVE
  initial $vcdpluson;

	rsa_ifc IFC(clk); // instantiate the interface file
	rsa_tb bench (IFC.bench);
	rsa dut (
		.rst(IFC.dut.rst),
		.stall(IFC.dut.stall),
		
		.rsa_data_i(IFC.dut.rsa_data_i),
		.rsa_valid_i(IFC.dut.rsa_valid_i),
		.rsa_output_o(IFC.dut.rsa_output_o),
		
		.aes_data_i(IFC.dut.aes_data_i),
		.aes_valid_i(IFC.dut.aes_valid_i),
		.aes_output_o(IFC.dut.aes_output_o),

		.ps2_data_i(IFC.dut.ps2_data_i),
		.ps2_valid_i(IFC.dut.ps2_valid_i),
		.ps2_done(IFC.dut.ps2_done),
		.ps2_reset(IFC.dut.ps2_reset),

		.led_pass_o(IFC.dut.led_pass_o),
		.led_fail_o(IFC.dut.led_fail_o)
  ); 

endmodule
