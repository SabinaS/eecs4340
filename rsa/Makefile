RSA_TOP = rsa_top.sv
RSA_BENCH = rsa_tb.sv
RSA_IFC = rsa_ifc.sv
RSA_OUTPUT = rsa_testbench.exe

MODULES = rsa_decryptor.sv \
          modexp.sv

.PHONY: all
all: spibench

help:
	@echo "The following make targets are supported:" ;\
	echo " spibench - builds the testbench";\
	echo " wave     - convert vcd to vpd";\
	echo " clean    - cleans testbench and intermediate files" ;\
	echo " help     - show this information";\

spibench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice $(RSA_TOP) $(RSA_IFC) $(RSA_BENCH) $(MODULES) -o $(RSA_OUTPUT) 

wave:
	vcs -vpd2vcd vcdplus.vpd waveform.vcd
	gtkwave waveform.vcd &

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *.exe *.key
