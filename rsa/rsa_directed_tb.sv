/* Project: DAU
 * Owner: Tim Paine
 */
module rsa_directed_test();

  logic clk;
  logic rst;
  logic stall;
  logic aes_valid_i, rsa_valid_i;
  logic aes_ready_o, rsa_ready_o;
  logic [127:0] aes_data_i, rsa_data_i;

  logic [7:0] ps2_data_i; 
  logic ps2_done, ps2_reset, ps2_valid_i;

  logic [127:0] out_data_o;
  logic out_valid_o;
  logic out_ready_i;

  logic led_pass_o, led_fail_o;
 
  rsa rsa_inst(.*);


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


