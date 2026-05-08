IVERILOG ?= iverilog
VVP ?= vvp
YOSYS ?= yosys
GTKWAVE ?= gtkwave

SRC = src/riscv_top.v src/fetch.v src/decode.v src/execute.v src/mem_stage.v \
      src/writeback.v src/alu.v src/regfile.v src/control.v src/hazard.v \
      src/imem.v src/dmem.v src/if_id_reg.v src/id_ex_reg.v src/ex_mem_reg.v \
      src/mem_wb_reg.v

.PHONY: all test synth wave clean

all: test

test:
	sh scripts/run_sim.sh

synth:
	mkdir -p results
	$(YOSYS) -s scripts/synth.ys > results/synthesis_report.txt
	@echo "Wrote results/synthesis_report.txt"

wave:
	@if command -v $(GTKWAVE) >/dev/null 2>&1; then \
		$(GTKWAVE) results/waveform.vcd; \
	else \
		echo "GTKWave not found. Open results/waveform.vcd with a waveform viewer."; \
	fi

clean:
	rm -f *.vvp
	rm -f results/sim_log.csv results/simulation_report.txt results/synthesis_report.txt
	rm -f results/waveform.vcd
