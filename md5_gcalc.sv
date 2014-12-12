`timescale 1ns/1ns

module md5_gcalc (
    input logic  [5:0] i,
    output logic [3:0] g
);

logic  doshift;
logic  sub;
logic   [1:0] shiftby;
logic   [2:0] addon;

logic  [3:0] shift_res = (doshift) ? i[3:0] << shiftby : 4'b0;
logic [3:0] mult_res = (sub) ? shift_res - i[3:0] : shift_res + i[3:0];
assign g = mult_res + addon;

always @(*) begin
    case (i[5:4])
        // 0 <= i <= 15
        2'b00: begin
            // g = i
            doshift <= 1'b0;
            sub <= 1'b0;
            shiftby <= 2'b0;
            addon <= 3'd0;
        end
        // 16 <= i <= 31
        2'b01: begin
            // g = 5 * i + 1
            doshift <= 1'b1;
            sub <= 1'b0;
            shiftby <= 2'b10;
            addon <= 3'd1;
        end
        // 32 <= i <= 47
        2'b10: begin
            // g = 3 * i + 5
            doshift <= 1'b1;
            sub <= 1'b0;
            shiftby <= 2'b01;
            addon <= 3'd5;
        end
        // 48 <= i <= 63
        2'b11: begin
            // g = 7 * i
            doshift <= 1'b1;
            sub <= 1'b1;
            shiftby <= 2'b11;
            addon <= 3'd0;
        end
    endcase
end

endmodule