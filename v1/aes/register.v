

// 32-bit register consisting of 32 1-bit D-flipflops

module register_32(/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   din, en, clk, rst
   );

input [0:31] din;
input en; // enable line

input clk, rst;

output [0:31] dout; 

flipflop ff [0:31] (.din(din), .dout(dout), .en(en), .clk(clk), .rst(rst));

endmodule
