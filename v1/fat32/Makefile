FAT_TOP = fat_top.sv
FAT_BENCH = fat_tb.sv
FAT_OUTPUT = fattestbench.exe

MODULES_ALL = $(wildcard *.sv)
MODULES_SANS_TOP = $(patsubst fat_top.sv,,$(MODULES_ALL))
MODULES = $(patsubst fat_tb.sv,,$(MODULES_SANS_TOP))

.PHONY: all
all: fatbench

help:
	@echo "The following make targets are supported:" ;\
	echo " fatbench - builds the testbench";\
	echo " wave     - convert vcd to vpd";\
	echo " clean    - cleans testbench and intermediate files" ;\
	echo " help     - show this information";\

fatbench: 
	vcs -full64 -cm_tgl mda -cm line+tgl+cond+fsm+branch+assert -debug_pp +lint=all,noVCDE -sverilog +define+SV +define+VPD -notice $(FAT_TOP) $(FAT_BENCH) $(MODULES) -o $(FAT_OUTPUT) 

wave:
	vcs -vpd2vcd vcdplus.vpd waveform.vcd
	gtkwave waveform.vcd &

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *exe *.key
