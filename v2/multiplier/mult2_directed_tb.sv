`timescale 1ns/1ns

/* 
 * Owner: Tim Paine
 */
module mult2_directed_test();

  logic clk;
  logic rst;
  logic [4096] a, b;
  logic [4096] o;
  integer i; 

  multiplier2 multiplier2_inst(.*);


  initial begin
    $vcdpluson();
    clk = 0;
    rst = 1;

    //reset   
    #1 clk = 1;
    #1 clk = 0;
    rst = 0;
    
    a = 'd02;
    b = 'd02;
    for(i=0;i<4096;i++) begin
    #1 clk = 1;
    #1 clk = 0;
    end

    #1 $finish;
  end

  initial  begin
     $display("a\tb\to");
     $monitor("%d,%d,%d", a,b,o);
  end


endmodule


