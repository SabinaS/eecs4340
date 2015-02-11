MULT_TOP = mult_top.sv
MULT_BENCH = mult_tb.sv
MULT_IFC = mult_ifc.sv
MULT_OUTPUT = mult_testbench.exe

MODULES = multiplier.sv 

.PHONY: all
all: multbench

help:
	@echo "The following make targets are supported:" ;\
	echo " spibench - builds the testbench";\
	echo " wave     - convert vcd to vpd";\
	echo " clean    - cleans testbench and intermediate files" ;\
	echo " help     - show this information";\

multbench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice $(MULT_TOP) $(MULT_IFC) $(MULT_BENCH) \
		$(MODULES) -o $(MULT_OUTPUT)

multdirbench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice multiplier.sv  mult_directed_tb.sv -o multdir.exe

multbench_coverage_directed:
	vcs -full64 -cm line+tgl+cond+fsm+branch+assert -debug_pp -sverilog -notice +lint=all,noVCDE +define+SV +define+VPD $(MULT_DIRECTED_FILES) -o $(MULT_OUTPUT)
	./$(MULT_OUTPUT) -cm line+cond+tgl+fsm+branch+assert > coverage_run_out
	/sim/synopsys/vcs/bin/urg -dir $(MULT_OUTPUT).vdb/
	firefox urgReport/dashboard.html

wave:
	vcs -vpd2vcd vcdplus.vpd waveform.vcd
	gtkwave waveform.vcd &

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *.exe *.exe.vdb *.key vc_hdrs.h urgReport
