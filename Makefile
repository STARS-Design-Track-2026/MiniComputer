export PATH := /home/shay/a/ece270/bin:$(PATH)
export LD_LIBRARY_PATH := /home/shay/a/ece270/lib:$(LD_LIBRARY_PATH)

YOSYS=yosys
NEXTPNR=nextpnr-ice40
SHELL=bash

PROJ	    = minicomp
PINMAP 	    = support/pinmap.pcf
TCLPREF     = addwave.gtkw
SRCDIR      = src
SRC_MODULES = $(SRCDIR)/pc.sv $(SRCDIR)/regfile.sv $(SRCDIR)/memory.sv \
              $(SRCDIR)/alu.sv $(SRCDIR)/uart_peripheral.sv $(SRCDIR)/minicomp.sv

FPGA_TOP	= top
SRC         = src
ICE         = support/ice40hx8k.sv
CHK         = check.bin
DEM         = demo.bin
JSON        = ll.json
SUP         = support/cells_*.v
UART        = uart/uart.v uart/uart_tx.v uart/uart_rx.v
FILES       = $(ICE) $(SRC) $(SRC_MODULES) $(UART)
TRACE       = $(PROJ).vcd
BUILD       = ./build
BUILD_VER   = $(BUILD)/verilator
TESTS       = tests

VERFLAGS    = --cc --build -j 0 -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -I$(CURDIR)

DEVICE  = 8k
TIMEDEV = hx8k
FOOTPRINT = ct256

all: cram

#########################
# Check code and synthesize design into a JSON netlist
$(BUILD)/$(FPGA_TOP).json : $(ICE) $(SRC)/* $(PINMAP)
	# lint with Verilator
	verilator --lint-only --top-module top -Werror-latch -y $(SRC) $(SRC)/top.sv
	# if build folder doesn't exist, create it
	mkdir -p $(BUILD)
	# synthesize using Yosys
	$(YOSYS) -p "read_verilog -sv -noblackbox $(ICE) $(UART) $(SRC)/*; synth_ice40 -top ice40hx8k; write_json -noscopeinfo $(BUILD)/$(FPGA_TOP).json"

# Place and route design using nextpnr
$(BUILD)/$(FPGA_TOP).asc : $(BUILD)/$(FPGA_TOP).json
	# Place and route using nextpnr
	$(NEXTPNR) --hx8k --package ct256 --placer-heap-cell-placement-timeout 0 --pcf $(PINMAP) --asc $(BUILD)/$(FPGA_TOP).asc --json $(BUILD)/$(FPGA_TOP).json 2> >(sed -e 's/^.* 0 errors$$//' -e '/^Info:/d' -e '/^[ ]*$$/d' 1>&2)

# Convert to bitstream using IcePack
$(BUILD)/$(FPGA_TOP).bin : $(BUILD)/$(FPGA_TOP).asc
	# Convert to bitstream using IcePack
	icepack $(BUILD)/$(FPGA_TOP).asc $(BUILD)/$(FPGA_TOP).bin

#########################
# ice40 Specific Targets
check: $(CHK)
	iceprog -S $(CHK)
	
demo:  $(DEM)
	iceprog -S $(DEM)

flash: $(BUILD)/$(FPGA_TOP).bin
	iceprog $(BUILD)/$(FPGA_TOP).bin

cram: $(BUILD)/$(FPGA_TOP).bin
	iceprog -S $(BUILD)/$(FPGA_TOP).bin

time: $(BUILD)/$(FPGA_TOP).asc
	icetime -p $(PINMAP) -P $(FOOTPRINT) -d $(TIMEDEV) $<

#########################
# Clean Up
clean:
	rm -rf build/ mapped/ *.log waves/*.vcd

#########################
# Verification — one target per submodule

# $(call verify_module, name, srcs, tb)
define verify_module
@echo "==> $(1)"
@mkdir -p $(BUILD_VER)/$(1)
@echo "  Compiling..."
@verilator $(VERFLAGS) --top-module $(1) --trace-fst --trace-max-array 65536 --trace-max-width 65536 --Mdir $(BUILD_VER)/$(1) $(2) --exe $(3) >/dev/null
@echo "  Simulating..."
@$(BUILD_VER)/$(1)/V$(1)
endef

verify_pc: $(SRCDIR)/pc.sv $(TESTS)/tb_pc.cpp
	$(call verify_module,pc,\
		$(CURDIR)/$(SRCDIR)/pc.sv,\
		$(CURDIR)/$(TESTS)/tb_pc.cpp)

verify_regfile: $(SRCDIR)/regfile.sv $(TESTS)/tb_regfile.cpp
	$(call verify_module,regfile,\
		$(CURDIR)/$(SRCDIR)/regfile.sv,\
		$(CURDIR)/$(TESTS)/tb_regfile.cpp)

verify_memory: $(SRCDIR)/memory.sv $(TESTS)/tb_memory.cpp
	$(call verify_module,memory,\
		$(CURDIR)/$(SRCDIR)/memory.sv,\
		$(CURDIR)/$(TESTS)/tb_memory.cpp)

verify_alu: $(SRCDIR)/alu.sv $(TESTS)/tb_alu.cpp
	$(call verify_module,alu,\
		$(CURDIR)/$(SRCDIR)/alu.sv,\
		$(CURDIR)/$(TESTS)/tb_alu.cpp)

verify_uart_peripheral: $(SRCDIR)/uart_peripheral.sv $(TESTS)/tb_uart_peripheral.cpp
	$(call verify_module,uart_peripheral,\
		$(CURDIR)/$(SRCDIR)/uart_peripheral.sv,\
		$(CURDIR)/$(TESTS)/tb_uart_peripheral.cpp)

verify_minicomp: $(SRC_MODULES) $(TESTS)/tb_minicomp.cpp
    mkdir -p waves
	$(call verify_module,minicomp,\
		$(addprefix $(CURDIR)/,$(SRC_MODULES)),\
		$(CURDIR)/$(TESTS)/tb_minicomp.cpp)

verify_all: verify_alu verify_pc verify_regfile verify_memory \
            verify_uart_peripheral verify_minicomp
	@echo "All Verilator tests passed."

verify_verilator: verify_all
