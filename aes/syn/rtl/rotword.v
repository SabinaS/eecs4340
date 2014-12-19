

module rotword(/*AUTOARG*/
   // Outputs
   out_word,
   // Inputs
   in_word
   );

input [0:31] in_word;

output [0:31] out_word;


assign out_word [0:7] = in_word [8:15];
assign out_word [8:15] = in_word [16:23];
assign out_word [16:23] = in_word [24:31];
assign out_word [24:31] = in_word [0:7];



endmodule
