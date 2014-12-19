`timescale 1ns/1ns

interface ps2_ifc(input bit clk):
	
	logic rst;
	
	clocking cb @(posedge clk);
		/* ToDo */
	endclocking 

	modport bench (clocking cb);

	modport dut(
		/* ToDo */
	);

endinterface 
