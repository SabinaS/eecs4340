`timescale 1ns/1ns

module modexp_tb_adapter(
	modexp_ifc.dut dut 
);

	modexp magical_box (
		.clk(dut.clk),
		.rst(dut.rst),
		.stall(dut.stall),

		.exp(dut.exp),
		.mod(dut.mod),
		.key_i(dut.data_i),
		.key_o(dut.data_o),

		.start(dut.start),
		.done(dut.done),
		.valid(dut.valid)
	); 
endmodule
