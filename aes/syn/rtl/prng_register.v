/**Columbia University CASTL**/
/**Spring 2011**/
/**Yipeng Huang, Rachid Jeitani**/
/**AES Research*/

/*
A register that stores 64 bits.
*/
module prng_register (
	/*AUTOARG*/
   // Outputs
   q,
   // Inputs
   clk, enable, reset, set
   );

//Basic inputs
input clk, enable, reset;

input [31:0] set;
output [31:0] q;

prng_ff ffs [31:0] (.clk(clk), .reset(reset), .enable(enable), .set(set), .q(q));

endmodule