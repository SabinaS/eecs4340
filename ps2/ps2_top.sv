'timescale 1ns/1ns

module ps2_top (
	clk, rst,

);

/* Inputs */
input clk, rst;

/* Outputs */

always_ff @(posedge clk) begin

	/* Reset */
	if (rst) begin
		/* ToDo */
	end 
	if (init) begin
		/* Todo */
	end 
end

endmodule
