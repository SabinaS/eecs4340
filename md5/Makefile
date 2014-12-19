.PHONY: all
all: md5bench

help:
	@echo "The following make targets are supported:" ;\
	echo " wave   - convert vcd to vpd";\
	echo " clean  - cleans testbench and intermediate files" ;\
	echo " help   - show this information";\

md5bench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice ./*.sv ../memory/*.sv ../memory/altsyncram.v -o md5testbench.exe 

wave:
	vcs -vpd2vcd vcdplus.vpd waveform.vcd
	gtkwave waveform.vcd &

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *exe *.key *.exe.vdb
	make -C rsa/ clean
	make -C md5/ clean
