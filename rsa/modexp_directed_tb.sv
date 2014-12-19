/* 
 * Owner: Tim Paine
 */
module modexp_directed_test();

  logic clk;
  logic rst;
  logic stall;
  logic [4095:0] exp, mod; //would actually want to chunk this
  logic [127:0] key_i;
  logic start;
  logic [127:0] key_o;
  logic done, valid;

 
  modexp modexp_inst(.*);


  initial begin
    $vcdpluson();
    clk = 0;
    rst = 1;

    //reset   
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
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 $finish;
  end

  //initial  begin
   //  $display("");
    // $monitor("%h,%h,%h", key_o, pay_o, dne_o);
  //end


endmodule


