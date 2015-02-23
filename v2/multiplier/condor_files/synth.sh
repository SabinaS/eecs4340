#!/bin/bash

function cleanjunk {
    rm -fr *~
    rm -fr command.log default.svf default.vpad filenames.log
    rm -fr *_LIB ./pna_output ./alib ./legalizer_debug_plots ./work
    rm -fr *_port_map.*
    rm -fr net.acts
    rm -fr icc_output.txt
}

echo "*** `date`: Recording hostname ***"
hostname

echo "*** `date`: Cleaning up workspace ***"
cleanjunk

echo "*** `date`: Setting up environment ***"
source /proj/arcade/home/tkp2108/research/DPU/verilog/setup_synopsys.sh

echo "*** `date`: Invoking dc_shell ***"
dc_shell -f dsyn.tcl > dc_shell.out 2>&1

echo "*** `date`: Invoking icc_shell ***"
icc_shell -f psyn.tcl > icc_shell.out 2>&1

echo "*** `date`: Cleaning up after self ***"
cleanjunk
