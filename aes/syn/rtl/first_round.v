// First Round Module

module first_round (/*AUTOARG*/
   // Outputs
   state_out,
   // Inputs
   state_in, roundkey_0, roundkey_1, clk, rst
   );

input [0:127] state_in, roundkey_0, roundkey_1;
 
input clk, rst;
   
output [0:127] state_out;

wire [0:127] addkey0_out, sub_in, sub_out, shift_in, shift_out, 
	     col_in, col_out, addkey1_in;



add_roundkey addRoundKey0 (.state_in(state_in), .state_out(addkey0_out), .key(roundkey_0));

pipereg pr0 (.din(addkey0_out), .dout(sub_in), .clk(clk), .rst(rst));

sub_bytes subBytes (.state_in(sub_in), .state_out(sub_out));

pipereg pr1 (.din(sub_out), .dout(shift_in), .clk(clk), .rst(rst)); 

shift_rows shiftRows(.state_in(shift_in), .state_out(shift_out));

pipereg pr2 (.din(shift_out), .dout(col_in), .clk(clk), .rst(rst));

mix_columns mixColumns (.state_in(col_in), .state_out(col_out));

pipereg pr3 (.din(col_out), .dout(addkey1_in), .clk(clk), .rst(rst));

add_roundkey addRoundKey(.state_in(addkey1_in), .state_out(state_out), .key(roundkey_1));





endmodule


