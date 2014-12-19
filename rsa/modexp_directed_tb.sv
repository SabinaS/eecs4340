`timescale 1ns/1ns

/* 
 * Owner: Tim Paine
 */
module modexp_directed_test();

  logic clk;
  logic rst;
  logic stall;
  logic [4095:0] exp, mod; //would actually want to chunk this
  logic [4095:0] key_i;
  logic start;
  logic [4095:0] modexp_out;
  logic [127:0] key_o;
  logic done, valid;
  integer i;
 
  assign key_o = modexp_out[127:0];

  modexp modexp_inst(.key_o(modexp_out), .*);

  initial begin
    $vcdpluson();
    clk = 0;
    stall = 0;
    rst = 1;
    

    //reset   
    #1 clk = 1;
    #1 clk = 0;
    rst = 0;
    key_i = 'b00001;
    exp = 'b00001;
    mod = 'b00001;
    start = 1;
    for(i=0;i<5000;i=i+1) begin
    #1 clk = 1;
    #1 clk = 0;
    end
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 $finish;
  end

  initial  begin
     $display("done \t valid \t key_o");
     $monitor("%h,%h,%h", done, valid, key_o);
  end


endmodule


