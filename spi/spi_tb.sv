class transaction;
    // vars
        rand bit reset;
    
    // Checking the reset functionality
    function bit check_reset(logic [2:0] to_slave_o, logic ready_o,
        logic valid_o, logic ack_o, logic dat);
        
        to_slave_o = '0; 
        ready_o = '0;
        valid_o = '0; 
        ack_o = '0; 
        
        return((to_slave_o == '0) && (ready_o == '0) && (valid_o == '0) 
            && (ack_o == '0) && (dat == '0));
        
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

parameter CLK_MHZ               = 50;
parameter SCLK_WAIT             = 74;
parameter MILLISECOND_MHZ       = (CLK_MHZ * 1000000) / 1000;
parameter SPI_CYCLE_INIT        = (CLK_MHZ * 1000000) / 400000;
program spi_tb (spi_ifc.bench ds);

    transaction t; 
    testing_env v;

    bit mosi = ds.cb.to_slave_o[1];
    
    int failures = 0; 
    bit reset;
    
    initial begin
        t = new();
        v = new();
        // v.read_config("config.txt");

        ds.cb.rst <= 1'b1;
        @(ds.cb);
        ds.cb.rst <= 1'b0;
        @(ds.cb);

        $display("tb: MILLISECOND_MHZ: %d, SCLK_WAIT: %d, CLK_MHZ: %d, SPI_CYCLE_INIT: %d", MILLISECOND_MHZ, SCLK_WAIT, CLK_MHZ, SPI_CYCLE_INIT);
        repeat (SCLK_WAIT * SPI_CYCLE_INIT * 2 + MILLISECOND_MHZ + 48 * SPI_CYCLE_INIT * 2 + SPI_CYCLE_INIT * 48 * 2) begin
            // if ($time == SCLK_WAIT * SPI_CYCLE_INIT * 2 + MILLISECOND_MHZ)
            //     $vcdpluson;
            @(ds.cb);
        end

        // Iterate iter number of cycles 
        // repeat (v.iter) begin
        //     v.randomize();
        //     if(v.get_reset()) begin
        //         ds.cb.rst <= 1'b1;
        //         $display("%t : %s \n", $realtime, "Driving Reset");
        //     end else begin
        //         ds.cb.rst <= 1'b0;
        //         // TODO later
        //     end

        //     @(ds.cb);

        //     if(v.get_reset()) begin
        //         $display("%t : %s \n", $realtime,t.check_reset(ds.cb.to_slave_o, 
        //             ds.cb.ready_o, ds.cb.valid_o, ds.cb.ack_o,
        //             ds.cb.dat) ? "Pass-reset" : "Fail-reset");
        //     end 
        //     //TODO: Test whether results are as expected (golden_output)
        // end
    end
endprogram
