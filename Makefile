MFE_TOP=mfe_top.sv
MFE_INTERFACE=mfe_ifc.sv
MFE_BENCH=mfe_tb.sv
MFE_DUT=mfe.sv
MFE_OUTPUT=mfetestbench.exe

MODULES = file_system.sv \
		rsa_decryptor.sv \
		aes_decryptor.sv \
		keyboard_driver.sv \
		status_driver.sv

.PHONY: all
all: mfebench

help:
	@echo "The following make targets are supported:" ;\
	echo " mfebench  - builds the testbench";\
	echo " wave   - convert vcd to vpd";\
	echo " clean  - cleans testbench and intermediate files" ;\
	echo " help   - show this information";\

mfebench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice $(MFE_TOP) $(MFE_INTERFACE) $(MFE_BENCH) $(MFE_DUT) $(MODULES) -o $(MFE_OUTPUT) 

md5bench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice md5/*.sv memory/*.sv memory/altsyncram.v -o md5testbench.exe 

rsabench: 
	make -C rsa/

modexpbench: 
	make modexp -C rsa/

wave:
	vcs -vpd2vcd vcdplus.vpd waveform.vcd
	gtkwave waveform.vcd &

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *exe *.key *.exe.vdb
	make -C rsa/ clean
