RSA_TOP = rsa_top.sv
RSA_BENCH = rsa_tb.sv
RSA_IFC = rsa_ifc.sv
RSA_OUTPUT = rsa_testbench.exe

NATIVE_FILES = rsa_tb.c

# need to go up a dir first.  don't ask.
NATIVE_LIBS = -L../tb_aux/ -laesdecrypt -lssl -lcrypto

MODULES = rsa.sv \
          modexp.sv \
          aes_kb.sv \
          rsa_tb_adapter.sv \
          ../md5/md5.sv \
          ../md5/md5_chunk_cruncher.sv \
          ../md5/*calc.sv \
          ../md5/md5_padder_length.sv \
          ../md5/md5_leftrotate.sv \
          ../memory/*.sv \
          ../memory/altsyncram.v \
          ../aes/aes.sv \
          ../aes/*.v

.PHONY: all
all: rsabench

help:
	@echo "The following make targets are supported:" ;\
	echo " spibench - builds the testbench";\
	echo " wave     - convert vcd to vpd";\
	echo " clean    - cleans testbench and intermediate files" ;\
	echo " help     - show this information";\

modexpbench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice \
		modexp.sv modexp_ifc.sv modexp_tb.sv modexp_tb_adapter.sv modexp_top.sv -o modexp_test.exe

modexpbench_directed: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice \
		modexp.sv modexp_directed_tb.sv -o modexp_test_directed.exe

modexpbench_coverage:
	vcs -full64 -cm line+tgl+cond+fsm+branch+assert -debug_pp -sverilog -notice +lint=all,noVCDE +define+SV +define+VPD modexp.sv modexp_ifc.sv modexp_tb.sv modexp_tb_adapter.sv modexp_top.sv -o modexp_test.exe
	./modexp_test.exe
	/sim/synopsys/vcs/bin/urg -dir modexp_test.exe.vdb/
	firefox urgReport/dashboard.html

modexpdirbench_coverage:
	vcs -full64 -cm line+tgl+cond+fsm+branch+assert -debug_pp -sverilog -notice +lint=all,noVCDE +define+SV +define+VPD modexp.sv modexp_directed_tb.sv -o modexp_test_directed.exe
	./modexp_test_directed.exe
	/sim/synopsys/vcs/bin/urg -dir modexp_test_directed.exe.vdb/

rsabench: aes_lib
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice $(RSA_TOP) $(RSA_IFC) $(RSA_BENCH) \
		$(MODULES) $(NATIVE_FILES) $(NATIVE_LIBS) -o $(RSA_OUTPUT)

rsadirbench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice rsa.sv modexp.sv aes_kb.sv ../md5/md5.sv ../md5/md5_chunk_cruncher.sv ../md5/*calc.sv ../md5/md5_leftrotate.sv ../md5/md5_padder_length.sv ../memory/*.sv ../memory/altsyncram.v ../aes/aes.sv ../aes/*.v rsa_directed_tb.sv -o rsadir.exe

aes_lib:
	make -C tb_aux/

wave:
	vcs -vpd2vcd vcdplus.vpd waveform.vcd
	gtkwave waveform.vcd &

clean:
	make -C tb_aux/ clean
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *.exe *.key vc_hdrs.h
