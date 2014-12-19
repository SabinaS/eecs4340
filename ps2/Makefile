PS2_TOP = ps2_top.sv
PS2_OUTPUT = ps2testbench.exe

MODULES = ps2_converter.sv \
			debounce.sv \
			ps2_ifc.sv

.PHONY: all
all: ps2bench

help:
	@echo "The following make targets are supported:" ;\
	echo " ps2bench - builds the testbench";\
	echo " wave     - convert vcd to vpd";\
	echo " clean    - cleans testbench and intermediate files" ;\
	echo " help     - show this information";\

ps2bench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice $(PS2_TOP) $(MODULES) -o $(PS2_OUTPUT) 

wave:
	vcs -vpd2vcd vcdplus.vpd waveform.vcd
	gtkwave waveform.vcd &

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *exe *.key
