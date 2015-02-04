
// aes_core module

module aes_core (/*AUTOARG*/
   // Outputs
   data_out_0, data_out_1, data_out_2, data_out_3,
   // Inputs
   clk, rst, data_in_0, data_in_1, data_in_2, data_in_3, key_0, key_1, key_2, key_3, sel
   );


input [0:31] data_in_0, data_in_1, data_in_2, data_in_3;
input clk, rst, sel;
input [0:31] key_0, key_1, key_2, key_3; 

output [0:31] data_out_0, data_out_1, data_out_2, data_out_3;

wire [0:127] encr_data; // cyphertext output
wire [0:127] decr_data; // cleartext output
wire [0:127] data_out;

aespipe encr_pipe (.clk(clk),
		   .rst(rst), 
		   .key({key_0, key_1, key_2, key_3}),
		   .data_in({data_in_0, data_in_1, data_in_2, data_in_3}),
		   .aesdata(encr_data));

inv_aespipe decr_pipe ( .clk(clk),
		        .rst(rst),
			.key({key_0, key_1, key_2, key_3}),
		 	.aes_in({data_in_0, data_in_1, data_in_2, data_in_3}),
			.data_out(decr_data));


assign data_out = (sel ? decr_data : encr_data);

assign data_out_0 = data_out[0:31];
assign data_out_1 = data_out[32:63];
assign data_out_2 = data_out[64:95];
assign data_out_3 = data_out[96:127];

endmodule
