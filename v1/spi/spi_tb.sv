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

parameter COMMAND_SIZE          = 6 * 8;
parameter R1_SIZE               = 8;
parameter R3_SIZE               = 8 * 5;
program spi_tb (spi_ifc.bench ds);

    transaction t; 
    testing_env v;

    int ss_divider = 0;
    int ss_toggle_value = 100000000;
    int last_ss_difference = 0;

    assign mosi = ds.cb.to_slave_o[1];
    assign sclk = ds.cb.to_slave_o[0];
    assign sclk_posedge = (ss_divider == ss_toggle_value / 2 - 1) && !sclk;
    assign ss = ds.cb.to_slave_o[2];

    int failures = 0;
    int command_count = 0;
    bit first_command = 0;
    bit first_command_recv = 0;
    bit second_command = 0;
    bit second_command_recv = 0;
    bit prev_mosi = 1;
    bit prev_sclk = 1;
    bit reset;

    logic [COMMAND_SIZE-1:0] command = 0;
    int command_pos = 0;
    logic [R1_SIZE-1:0] r1_response;
    int r1_pos = R1_SIZE - 1;
    logic [R3_SIZE-1:0] r3_response;
    int r3_pos = 0;
    logic [R3_SIZE-1:0] r7_response;
    int r7_pos = R3_SIZE-1;

    initial begin
        t = new();
        v = new();
        // v.read_config("config.txt");

        ds.cb.rst <= 1'b1;
        ds.cb.from_slave_i <= '1;
        @(ds.cb);
        ds.cb.rst <= 1'b0;

        $display("tb: MILLISECOND_MHZ: %d, SCLK_WAIT: %d, CLK_MHZ: %d, SPI_CYCLE_INIT: %d", MILLISECOND_MHZ, SCLK_WAIT, CLK_MHZ, SPI_CYCLE_INIT);
        repeat (SCLK_WAIT * SPI_CYCLE_INIT * 2 + MILLISECOND_MHZ + 48 * SPI_CYCLE_INIT * 2 + SPI_CYCLE_INIT * 2 * 8 + SPI_CYCLE_INIT * 48 * 2 + SPI_CYCLE_INIT * 40 * 3) begin
            // if ($time == SCLK_WAIT * SPI_CYCLE_INIT * 2 + MILLISECOND_MHZ)
            //     $vcdpluson;
            // mosi = ds.cb.to_slave_o[1];
            if (sclk_posedge) begin
                // CMD0, respond with R1
                if (!second_command) begin
                    if (first_command && command_pos < 47) begin
                        command = {command[COMMAND_SIZE-2:0], mosi};
                        $display("first_command: mosi @%d ns: %d",$time, mosi);
                        command_pos++;
                    end else if (command_pos >= 47 && !first_command_recv) begin
                        $display("first_command: %b", command);
                        first_command_recv = 1;
                        r1_response = 1;
                        command_pos = 0;
                        first_command = 0;
                    end else if (first_command_recv) begin
                        if (r1_pos >= 0) begin
                            $display("first_command: r1_response[%d] = %d",r1_pos, r1_response[r1_pos]);
                            ds.cb.from_slave_i <= r1_response[r1_pos];
                            r1_pos--;
                        end else ds.cb.from_slave_i <= '1;
                    end
                end

                // CMD8, respond with R7
                if (first_command_recv) begin
                    if (second_command && command_pos < 47) begin
                        command = {command[COMMAND_SIZE-2:0], mosi};
                        $display("second_command: mosi @%d ns: %d",$time, mosi);
                        command_pos++;
                    end else if (command_pos >= 47 && !second_command_recv) begin
                        $display("second_command: %b", command);
                        second_command_recv = 1;
                        r7_response = 'h1AA;
                        // r7_response[R3_SIZE-2] = 1;
                        command_pos = 0;
                        second_command = 0;
                    end else if (second_command_recv) begin
                        if (r7_pos >= 0) begin
                            $display("second_command: r7_response[%d] = %d",r7_pos, r7_response[r7_pos]);
                            ds.cb.from_slave_i <= r7_response[r7_pos];
                            r7_pos--;
                        end else ds.cb.from_slave_i <= '1;
                    end
                end
            end
            @(ds.cb);
            last_ss_difference++;
            ss_divider++;
            // Reset ss_divider
            if (prev_sclk != sclk)
                ss_divider = 1;
            // Record the last spi clock period
            if (!prev_sclk && sclk) begin
                ss_toggle_value = last_ss_difference;
                last_ss_difference = 0;
            end
            if (!prev_mosi && mosi) begin
                if (command_count == 1) begin
                    $display("Command received: %d", command_count);
                    first_command = 1;
                end
                if (command_count == 6) begin
                    $display("Command received: %d", command_count);
                    command = 0;
                    second_command = 1;
                end
                command_count++;
            end
            prev_mosi = mosi;
            prev_sclk = sclk;
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
