RSA_TOP = rsa_top.sv
RSA_BENCH = rsa_tb.sv
RSA_IFC = rsa_ifc.sv
RSA_OUTPUT = rsa_testbench.exe

NATIVE_FILES = rsa_tb.c

NATIVE_LIBS = -lssl -lcrypto

MODULES = rsa_decryptor.sv \
          modexp.sv \
          aes_kb.sv \
          rsa_tb_adapter.sv

.PHONY: all
all: spibench

help:
	@echo "The following make targets are supported:" ;\
	echo " spibench - builds the testbench";\
	echo " wave     - convert vcd to vpd";\
	echo " clean    - cleans testbench and intermediate files" ;\
	echo " help     - show this information";\

spibench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice $(RSA_TOP) $(RSA_IFC) $(RSA_BENCH) \
		$(MODULES) $(NATIVE_FILES) $(NATIVE_LIBS) -o $(RSA_OUTPUT)

wave:
	vcs -vpd2vcd vcdplus.vpd waveform.vcd
	gtkwave waveform.vcd &

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *.exe *.key vc_hdrs.h
