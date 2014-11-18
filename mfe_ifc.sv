`timescale 1ns/1ns

interface mfe_ifc(input bit clk);

	logic               rst;
	logic [6:0]					status_leds;

	logic								spi_clk;
	logic [2:0]					dat_spi_card_o;
	logic								dat_spi_card_i;
	logic [2:0]					key_spi_card_o;
	logic								key_spi_card_i;
	logic [2:0]					out_spi_card_o;
	logic								out_spi_card_i;

	logic								ps2_clk;
	wire 								ps2_dat;


	// note that the outputs and inputs are reversed from the dut
	clocking cb @(posedge clk);
		output rst, dat_spi_card_i, key_spi_card_i, out_spi_card_i;
		input status_leds, spi_clk, dat_spi_card_o, key_spi_card_o, out_spi_card_o, ps2_clk;
		inout  ps2_dat;
	endclocking

	modport bench (clocking cb);

	modport dut (
		input clk, rst,dat_spi_card_i,key_spi_card_i,out_spi_card_i,
		output status_leds, spi_clk,dat_spi_card_o,
		output key_spi_card_o, out_spi_card_o,ps2_clk,
		inout ps2_dat
	);
endinterface
