`timescale 1ns/1ns

module gcalc_tb ();

logic [5:0] i;
logic [3:0] g;

md5_gcalc gc (
    .i (i),
    .g (g)
);

initial begin
    i = 6'd3;
    #20000 assert (g == 6'd3);
    i = 6'd17;
    #20000 assert (g == 6'd6);
    i = 6'd37;
    #20000 assert (g == 6'd4);
    i = 6'd52;
    #20000 assert (g == 6'd12);
end


initial  begin
 $display("i\tg");
 $monitor("%h,%h", i, g);
end


endmodule
