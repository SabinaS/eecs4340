module key_expansion (/*AUTOARG*/
   // Outputs
   roundkey_0, roundkey_1, roundkey_2, roundkey_3, roundkey_4,
   roundkey_5, roundkey_6, roundkey_7, roundkey_8, roundkey_9,
   roundkey_10,
   // Inputs
   key, clk, rst
   );
   
  
  input [0:127] key;
  input clk, rst;

  output [0:127] roundkey_0;
  output [0:127] roundkey_1;
  output [0:127] roundkey_2;
  output [0:127] roundkey_3;
  output [0:127] roundkey_4;
  output [0:127] roundkey_5;
  output [0:127] roundkey_6;
  output [0:127] roundkey_7;
  output [0:127] roundkey_8;
  output [0:127] roundkey_9;
  output [0:127] roundkey_10;

 wire [0:127] rk1_out, rk2_in, rk2_out, rk3_in, rk3_out, rk4_in, rk4_out,
	      rk5_in, rk5_out, rk6_in, rk6_out, rk7_in, rk7_out, rk8_in, rk8_out,
	      rk9_in, rk9_out, rk10_in;




  assign roundkey_0 = key; // first round key is the encryption key itself

  gen_key1 rk1 (.prev_key(key), .next_key(rk1_out));
  pipereg pr1 (.din(rk1_out), .dout(rk2_in), .clk(clk), .rst(rst));

  gen_key2 rk2 (.prev_key(rk2_in), .next_key(rk2_out));
  pipereg pr2 (.din(rk2_out), .dout(rk3_in), .clk(clk), .rst(rst));

  gen_key3 rk3 (.prev_key(rk3_in), .next_key(rk3_out));
  pipereg pr3 (.din(rk3_out), .dout(rk4_in), .clk(clk), .rst(rst));

  gen_key4 rk4 (.prev_key(rk4_in), .next_key(rk4_out));
  pipereg pr4 (.din(rk4_out), .dout(rk5_in), .clk(clk), .rst(rst));

  gen_key5 rk5 (.prev_key(rk5_in), .next_key(rk5_out));
  pipereg pr5 (.din(rk5_out), .dout(rk6_in), .clk(clk), .rst(rst));

  gen_key6 rk6 (.prev_key(rk6_in), .next_key(rk6_out));
  pipereg pr6 (.din(rk6_out), .dout(rk7_in), .clk(clk), .rst(rst));

  gen_key7 rk7 (.prev_key(rk7_in), .next_key(rk7_out));
  pipereg pr7 (.din(rk7_out), .dout(rk8_in), .clk(clk), .rst(rst));

  gen_key8 rk8 (.prev_key(rk8_in), .next_key(rk8_out));
  pipereg pr8 (.din(rk8_out), .dout(rk9_in), .clk(clk), .rst(rst));

  gen_key9 rk9 (.prev_key(rk9_in), .next_key(rk9_out));
  pipereg pr9 (.din(rk9_out), .dout(rk10_in), .clk(clk), .rst(rst));
	
  gen_key10 rk10 (.prev_key(rk10_in), .next_key(roundkey_10));

   assign roundkey_1 = rk1_out;
   assign roundkey_2 = rk2_out;
   assign roundkey_3 = rk3_out;
   assign roundkey_4 = rk4_out;
   assign roundkey_5 = rk5_out;
   assign roundkey_6 = rk6_out;
   assign roundkey_7 = rk7_out;
   assign roundkey_8 = rk8_out;
   assign roundkey_9 = rk9_out;


  
endmodule
