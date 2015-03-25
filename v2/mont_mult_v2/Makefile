.PHONY: all
all: bench

help:
	@echo "The following make targets are supported:" ;\
	echo " bench - builds the testbench";\
	echo " wave     - convert vcd to vpd";\
	echo " clean    - cleans testbench and intermediate files" ;\
	echo " help     - show this information";\

bench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice ./*.v  -o tb.exe

wave:
	vcs -vpd2vcd vcdplus.vpd waveform.vcd
	gtkwave waveform.vcd &

clean:
	rm -rf *.o *~ *.vcd *.vpd sim* csrc DVEfiles *daidir *.ver *.exe *.exe.vdb *.key vc_hdrs.h urgReport
