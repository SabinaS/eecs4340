class transaction;
    // vars
		rand bit reset;
    
    // Checking the reset functionality
    function bit check_reset(logic [6:0] status_leds, logic [2:0] dat_spi_card_o, 
    	logic [2:0] key_spi_card_o, logic ps2_dat);
    	
    	status_leds = '0; 
    	dat_spi_card_o = '0;
    	key_spi_card_o = '0; 
    	ps2_dat = '0; 
    	
    	return((status_leds == '0) && (dat_spi_card_o == '0) && (key_spi_card_o == '0) 
    		&& (ps2_dat == '0));
        
    endfunction 
    
    
    function void golden_result();
    	// TODO later
    endfunction
    
    
endclass 



class testing_env;
    rand int unsigned rn;

    bit reset;
    
    int reset_thresh;

    int iter;

    function void read_config(string filename);
        int file, chars_returned, seed, value;
        string param;
        file = $fopen(filename, "r");

        while(!$feof(file)) begin
            chars_returned = $fscanf(file, "%s %d", param, value);
            if("RANDOM_SEED" == param) begin
                seed = value;
                $srandom(seed);
            end else if("ITERATIONS" == param) begin
                iter = value;
            end else if("RESET_PROB" == param) begin
                reset_thresh = value;
            end
            else begin
                $display("Invalid parameter");
                $exit();
            end
        end
    endfunction

    function bit get_reset();
        return((rn%1000)<reset_thresh);
    endfunction

endclass




program mfe_tb (mfe_ifc.bench ds);

    transaction t; 
    testing_env v;
    
    int failures = 0; 
		bit reset;
    
    initial begin
	t = new();
	v = new();
	v.read_config("config.txt");

	// Drive inputs for next cycles
	ds.cb.rst <= t.reset; 


	repeat(10) begin
	ds.cb.rst <= 1'b1;
	@(ds.cb);
	end
	ds.cb.rst <= 1'b0;
	@(ds.cb);

	// Iterate iter number of cycles 
	repeat (v.iter) begin
	v.randomize();
	if(reset) begin
	    ds.cb.rst <= 1'b1;
	    $display("%t : %s \n", $realtime, "Driving Reset");
	end else begin
		ds.cb.rst <= 1'b0;
		// TODO later
	end
	end

	@(ds.cb);

	if(reset) begin
		$display("%t : %s \n", $realtime,t.check_reset(ds.cb.status_leds, 
			ds.cb.dat_spi_card_o, ds.cb.key_spi_card_o, 
			ds.cb.ps2_dat)?"Pass-reset":"Fail-reset");
	end 
            
            
        //TODO: Test whether results are as expected (golden_output)
        
    end
endprogram

