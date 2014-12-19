.PHONY: all
all: md5bench

help:
	@echo "The following make targets are supported:" ;\
	echo " wave   - convert vcd to vpd";\
	echo " clean  - cleans testbench and intermediate files" ;\
	echo " help   - show this information";\

md5bench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice ./*.sv ../memory/*.sv ../memory/altsyncram.v -o md5testbench.exe 

md5bench_coverage:
	vcs -full64 -cm line+tgl+cond+fsm+branch+assert -debug_pp -sverilog -notice +lint=all,noVCDE +define+SV +define+VPD ./*.sv ../memory/*.sv ../memory/altsyncram.v -o md5testbench.exe 
	./md5testbench.exe
	/proj/castl/development/synopsys64/vcs/bin//urg -dir md5testbench.exe.vdb/
	firefox urgReport/dashboard.html

wave:
	vcs -vpd2vcd vcdplus.vpd waveform.vcd
	gtkwave waveform.vcd &

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *exe *.key *.exe.vdb
