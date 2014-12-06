SPI_TOP = spi_top.sv
SPI_BENCH = spi_tb.sv
SPI_OUTPUT = spitestbench.exe

MODULES = spi_read.sv \
			spi_ifc.sv

.PHONY: all
all: spibench

help:
	@echo "The following make targets are supported:" ;\
	echo " spibench - builds the testbench";\
	echo " wave     - convert vcd to vpd";\
	echo " clean    - cleans testbench and intermediate files" ;\
	echo " help     - show this information";\

spibench: 
	vcs -full64 -PP -sverilog +define+SV +define+VPD -notice $(SPI_TOP) $(SPI_BENCH) $(MODULES) -o $(SPI_OUTPUT) 

wave:
	vcs -vpd2vcd vcdplus.vpd waveform.vcd
	gtkwave waveform.vcd &

clean:
	rm -rf *.o *~ *.vpd sim* csrc DVEfiles *daidir *exe *.key
