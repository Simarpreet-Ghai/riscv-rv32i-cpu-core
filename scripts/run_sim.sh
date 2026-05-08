#!/usr/bin/env sh
set -eu

mkdir -p results
rm -f results/sim_log.csv results/waveform.vcd
printf "test,status,cycles,program\n" > results/sim_log.csv

BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/riscv_cpu_core_sim.XXXXXX")
trap 'rm -rf "$BUILD_DIR"' EXIT

SRC="src/riscv_top.v src/fetch.v src/decode.v src/execute.v src/mem_stage.v src/writeback.v src/alu.v src/regfile.v src/control.v src/hazard.v src/imem.v src/dmem.v src/if_id_reg.v src/id_ex_reg.v src/ex_mem_reg.v src/mem_wb_reg.v"

echo "Running ALU unit test"
iverilog -g2012 -o "$BUILD_DIR/tb_alu.vvp" sim/tb_alu.v src/alu.v
vvp "$BUILD_DIR/tb_alu.vvp"

echo "Running register file unit test"
iverilog -g2012 -o "$BUILD_DIR/tb_regfile.vvp" sim/tb_regfile.v src/regfile.v
vvp "$BUILD_DIR/tb_regfile.vvp"

echo "Running control unit test"
iverilog -g2012 -o "$BUILD_DIR/tb_control.vvp" sim/tb_control.v src/control.v
vvp "$BUILD_DIR/tb_control.vvp"

echo "Running integration test: add_test"
iverilog -g2012 -o "$BUILD_DIR/tb_riscv.vvp" sim/tb_riscv.v $SRC
vvp "$BUILD_DIR/tb_riscv.vvp" +PROGRAM=tests/add_test.mem +TESTNAME=add_test +CYCLES=80

echo "Running integration test: fibonacci"
vvp "$BUILD_DIR/tb_riscv.vvp" +PROGRAM=tests/fibonacci.mem +TESTNAME=fibonacci +CYCLES=160

echo "Running integration test: bubble_sort"
vvp "$BUILD_DIR/tb_riscv.vvp" +PROGRAM=tests/bubble_sort.mem +TESTNAME=bubble_sort +CYCLES=160

python3 scripts/parse_results.py
