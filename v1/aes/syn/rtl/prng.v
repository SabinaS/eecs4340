/**Columbia University CASTL**/
/**Spring 2011**/
/**Yipeng Huang, Rachid Jeitani**/
/**AES Research*/

// Split prng that is composed of two separate 32-bit generators
module prng (
	
	/*AUTOARG*/
	// Outputs
	key,
	// Inputs
	clk, enable, reset, seed
	);
	
	input clk, enable, reset;
	input [127:0] seed;
	output [127:0] key;
	
	wire half_clk_0, half_clk_1;
	wire [127:0] key_mid_0, key_mid_1;
	reg [1:0] counter;
	
	prng_single half_0 (.clk(half_clk_0), .enable(enable), .reset(reset), .seed(seed), .key(key_mid_0));
	prng_single half_1 (.clk(half_clk_1), .enable(enable), .reset(reset), .seed(seed), .key(key_mid_1));
	
	// Frequency divider
	always @(posedge clk) begin
		if(reset) counter <= 0;
		else counter <= counter+1;
	end
	
	assign half_clk_0 = counter[1];
	assign half_clk_1 = !counter[1];
	assign key = ({128{half_clk_0}} & key_mid_1) | ({128{half_clk_1}} & key_mid_0);
	
endmodule