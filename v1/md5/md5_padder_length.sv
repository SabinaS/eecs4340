`timescale 1ns/1ns

module md5_padder_length(
  in, out
);
    input logic [447:0] in;
    output logic [63:0] out;

    integer i;

    always_comb begin
        for(i = 55; i>0; i=i-1) begin
            if(in[i*8 +: 8]) begin //at the largest 1
                out = (i+1) * 8;
                break;
            end
        end

    end

endmodule
