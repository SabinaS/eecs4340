`timescale 1ns/1ns

module md5unit (
    input logic clk,
    input logic [1:0] reset,
    input logic [1:0] start,

    input logic write,
    input logic [31:0] writedata,
    input logic [4:0]  writeaddr,

    output logic [127:0] digest0,
    output logic [127:0] digest1,

    output logic [1:0] done
);

logic [1:0] m_write;
assign m_write[0] = write && !writeaddr[4];
assign m_write[1] = write && writeaddr[4];

logic [5:0] cc_iaddr [1:0];
logic [3:0] cc_gaddr [1:0];

logic [127:0] cc_digest [1:0];
assign digest0 = cc_digest[0];
assign digest1 = cc_digest[1];

logic [31:0] cc_mdata [1:0];
logic [4:0]  cc_sdata [1:0];
logic [31:0] cc_kdata [1:0];

genvar i;
generate
    for (i = 0; i < 2; i = i + 1) begin : mccgen
        md5_chunk_cruncher cc (
            .clk (clk),
            .reset (reset[i]),
            .start (start[i]),
            .done (done[i]),
            .digest (cc_digest[i]),
            .iaddr (cc_iaddr[i]),
            .kdata (cc_kdata[i]),
            .sdata (cc_sdata[i]),
            .gaddr (cc_gaddr[i]),
            .mdata (cc_mdata[i])
        );

        mdataram mram (
            .clock (clk),
            .data (writedata),
            .wraddress (writeaddr[3:0]),
            .wren (m_write[i]),
            .rdaddress (cc_gaddr[i]),
            .q (cc_mdata[i])
        );
    end
endgenerate

sdatarom srom (
    .clock (clk),
    .address_a (cc_iaddr[0]),
    .address_b (cc_iaddr[1]),
    .q_a (cc_sdata[0]),
    .q_b (cc_sdata[1])
);

kdatarom krom (
    .clock (clk),
    .address_a (cc_iaddr[0]),
    .address_b (cc_iaddr[1]),
    .q_a (cc_kdata[0]),
    .q_b (cc_kdata[1])
);

endmodule