class transaction;
    // vars
    
    // Checking the reset functionality
    function bit check_reset(status_leds, dat_card, key_card, out_card);
        
    endfunction 
    
    
    function void golden_result();
    
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

    function bit get_read();
        return((rn%1000)<read_thresh);
    endfunction

    function bit get_reset();
        return((rn%1000)<reset_thresh);
    endfunction

endclass




program tb (mfe.bench ds);

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
                ds.cb.reset <= 1'b1;
                @(ds.cb);
            end
            ds.cb.reset <= 1'b0;
            @(ds.cb);
            
            // Iterate iter number of cycles 
            repeat (v.iter) begin
                v.randomize();
                if(reset) begin
                    ds.cb.reset <= 1'b1;
                    $display("%t : %s \n", $realtime, "Driving Reset");
                end else begin
                        ds.cb.reset <= 1'b0;
                        //READ/DECRYPT stuff
                end
            end
            
            //Test whether results are as expected (golden_output)
        
    end
endprogram

