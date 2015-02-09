

// Standard Round Module

module std_round (/*AUTOARG*/
   // Outputs
   state_out,
   // Inputs
   state_in, roundkey, clk, rst
   );

input [0:127] state_in, roundkey;
 
input      clk, rst;
   
output [0:127] state_out;

wire [0:127] sub_out, shift_in, shift_out, col_in, col_out,
	     addkey_in;


sub_bytes subBytes (.state_in(state_in), .state_out(sub_out));

pipereg pr1 (.din(sub_out), .dout(shift_in), .clk(clk), .rst(rst)); 

shift_rows shiftRows(.state_in(shift_in), .state_out(shift_out));

pipereg pr2 (.din(shift_out), .dout(col_in), .clk(clk), .rst(rst));

mix_columns mixColumns (.state_in(col_in), .state_out(col_out));

pipereg pr3 (.din(col_out), .dout(addkey_in), .clk(clk), .rst(rst));

add_roundkey addRoundKey(.state_in(addkey_in), .state_out(state_out), .key(roundkey));





endmodule


