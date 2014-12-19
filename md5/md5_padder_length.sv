`timescale 1ns/1ns

/* module for performing modular exponentiation */
module modexp(
  in, out
);
    input logic [447:0] in;
    output logic [63:0] out;

    integer i;

    always_comb begin
        for(i = 447; i>0; i=i-1) begin
            if(in[i]) begin //at the largest 1
                out = i;
                break;
            end
        end

    end

endmodule
