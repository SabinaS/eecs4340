
// Inverse Standard Round Module

module inv_std_round (/*AUTOARG*/
   // Outputs
   state_out,
   // Inputs
   state_in, roundkey, clk, rst
   );

input [0:127] state_in, roundkey;
 
input      clk, rst;
   
output [0:127] state_out;

wire [0:127] sub_out, sub_in, shift_out, col_in,
	     addkey_in, addkey_out;



inv_shift_rows shiftRows(.state_in(state_in), .state_out(shift_out));

pipereg pr1 (.din(shift_out), .dout(sub_in), .clk(clk), .rst(rst));


inv_sub_bytes subBytes (.state_in(sub_in), .state_out(sub_out));

pipereg pr2 (.din(sub_out), .dout(addkey_in), .clk(clk), .rst(rst)); 


add_roundkey addRoundKey(.state_in(addkey_in), .state_out(addkey_out), .key(roundkey));

pipereg pr3 (.din(addkey_out), .dout(col_in), .clk(clk), .rst(rst));


inv_mix_columns mixColumns (.state_in(col_in), .state_out(state_out));



endmodule


