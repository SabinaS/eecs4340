`timescale 1ns/1ns

interface mfe_ifc(input bit clk);

	logic rst;

	//status leds
	logic [6:0] status_leds;


	//clock for spi
	logic spi_clk;

	//spi to private key SD
	logic [2:0] key_spi_card_o;
	logic key_spi_card_i;

	//memory map the val k^e
	logic [31:0] mm_val_i;
	logic mm_val_valid_i;
	logic mm_val_ready_o; 

	//memory map the val k (so we can exponentiate it via the random var)
	logic [31:0] mm_base_i;
	logic mm_base_valid_i;
	logic mm_base_ready_o; 
	
	//memory map the output k^e/k^random 
	logic [31:0] mm_out_o;
	logic mm_out_valid_o;
	logic mm_out_ready_i;

	//memory map the private key*random number
	logic [31:0] mm_exp_o;
	logic mm_exp_valid_o;
	logic mm_exp_ready_i;



	//clock and data for keyboard (for later)
	// logic ps2_clk;
	// wire ps2_dat;


	// note that the outputs and inputs are reversed from the dut
	clocking cb @(posedge clk);
		output rst, key_spi_card_i, mm_val_i, mm_val_valid_i,
		mm_base_i, mm_base_valid_i, mm_out_ready_i,
		mm_exp_ready_i;
		input status_leds, spi_clk, key_spi_card_o,
		mm_val_ready_o, mm_base_ready_o, mm_out_o,
		mm_out_valid_o, mm_exp_o, mm_exp_valid_o;
	endclocking

	modport bench (clocking cb);

	modport dut (
		input clk, rst,key_spi_card_i,
		mm_val_i, mm_val_valid_i,
		mm_base_i, mm_base_valid_i,
		mm_out_ready_i, mm_exp_ready_i,
		output spi_clk, key_spi_card_o, 
		mm_val_ready_o, mm_base_ready_o,
		mm_out_o, mm_out_valid_o,
		mm_exp_valid_o, mm_exp_o
	);
endinterface
