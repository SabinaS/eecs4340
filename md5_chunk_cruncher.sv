`timescale 1ns/1ns

module md5_chunk_cruncher (
    input logic clk,
    input logic reset,
    input logic start,
    output logic done,

    output logic [127:0] digest,

    output logic [5:0]  iaddr,
    input  logic [31:0] kdata,
    input  logic [4:0]  sdata,

    output logic [3:0]  gaddr,
    input  logic [31:0] mdata
);

parameter INITA = 32'h67452301;
parameter INITB = 32'hefcdab89;
parameter INITC = 32'h98badcfe;
parameter INITD = 32'h10325476;

logic  [31:0] a0;
logic  [31:0] b0;
logic  [31:0] c0;
logic  [31:0] d0;

logic  [31:0] areg;
logic [31:0] breg;
logic  [31:0] creg;
logic  [31:0] dreg;

assign digest = {d0, c0, b0, a0};

logic  [5:0] ireg;

logic  [31:0] f;
logic  [31:0] freg;

logic   [31:0] adda;
logic  [31:0] addb;
logic  [31:0] adds = adda + addb;

logic  [31:0] t0;
logic  [31:0] t1;

logic  [31:0] rotated;

logic  [31:0] inext = ireg + 1'b1;
assign iaddr = ireg;

md5_fcalc fc (
    .sel (ireg[5:4]),
    .b (breg),
    .c (creg),
    .d (dreg),
    .f (f)
);

md5_gcalc gc (
    .i (ireg),
    .g (gaddr)
);

md5_leftrotate lr (
    .rotin (t0),
    .rotby (sdata),
    .rotout (rotated)
);

parameter CRUNCH   = 2'b00;
parameter FINALIZE = 2'b01;
parameter FINISHED = 2'b10;

logic  [1:0] stage;

assign done = (stage == FINISHED);

logic  [1:0] step;

always @(*) begin
    if (stage == CRUNCH) begin
        case (step)
            2'b00: begin
                adda <= areg;
                addb <= kdata;
            end
            2'b01: begin
                adda <= freg;
                addb <= mdata;
            end
            2'b10: begin
                adda <= t0;
                addb <= t1;
            end
            2'b11: begin
                adda <= breg;
                addb <= rotated;
            end
        endcase
    end else if (stage == FINALIZE) begin
        case (step)
            2'b00: begin
                adda <= a0;
                addb <= areg;
            end
            2'b01: begin
                adda <= b0;
                addb <= breg;
            end
            2'b10: begin
                adda <= c0;
                addb <= creg;
            end
            2'b11: begin
                adda <= d0;
                addb <= dreg;
            end
        endcase
    end else begin
        adda <= 32'd0;
        addb <= 32'd0;
    end
end

always @(posedge clk) begin
    if (reset) begin
        a0 <= INITA;
        b0 <= INITB;
        c0 <= INITC;
        d0 <= INITD;
        ireg <= 6'd00;
        stage <= FINISHED;
    end else if (start) begin
        areg <= a0;
        breg <= b0;
        creg <= c0;
        dreg <= d0;
        step <= 2'b00;
        stage <= CRUNCH;
    end else if (stage == CRUNCH) begin
        case (step)
            2'b00: begin
                freg <= f;
                // t0 = areg + kdata
                t0 <= adds;
                step <= 2'b01;
            end
            2'b01: begin
                // t1 = freg + mdata
                t1 <= adds;
                step <= 2'b10;
            end
            2'b10: begin
                // t0 = t0 + t1
                t0 <= adds;
                step <= 2'b11;
                ireg <= inext;
            end
            2'b11: begin
                areg <= dreg;
                // breg = breg + rotate(t0, sdata)
                breg <= adds;
                creg <= breg;
                dreg <= creg;
                if (ireg != 6'd0) begin
                    step <= 2'b00;
                end else begin
                    step <= 2'b00;
                    stage <= FINALIZE;
                end
            end
        endcase
    end else if (stage == FINALIZE) begin
        case (step)
            2'b00: begin
                // a0 += areg
                a0 <= adds;
                step <= 2'b01;
            end
            2'b01: begin
                // b0 += breg
                b0 <= adds;
                step <= 2'b10;
            end
            2'b10: begin
                // c0 += creg
                c0 <= adds;
                step <= 2'b11;
            end
            2'b11: begin
                // d0 += dreg
                d0 <= adds;
                stage <= FINISHED;
            end
        endcase
    end
end

endmodule