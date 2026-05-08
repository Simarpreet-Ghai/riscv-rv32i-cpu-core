# RISC-V RV32I CPU Core - RTL Design & Simulation

This project is a student-readable Verilog implementation of a simulated
RISC-V CPU core. It implements and tests an **RV32I subset**, organized with
fetch, decode, execute, memory, writeback, pipeline registers, a register file,
an ALU, simple hazard/forwarding logic, instruction memory, and data memory.

It does not claim full RV32I support, FPGA deployment, timing closure, or Fmax.

## Supported RV32I Subset

Tested instructions:

- `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT`
- `ADDI`
- `LW`, `SW`
- `BEQ`
- `JAL`
- `LUI`

`SLL` and `SRL` are implemented in the ALU/control path and covered by the ALU
unit test. See `docs/isa_reference.md` for the exact supported and unsupported
instruction list.

## Tools

Free tools only:

- Icarus Verilog (`iverilog`)
- `vvp`
- GTKWave (`gtkwave`, optional for viewing waveforms)
- Yosys (`yosys`)
- Python 3

No RISC-V GCC toolchain is required. The programs in `tests/` are hand-written
machine-code `.mem` files.

## Folder Structure

```text
riscv-cpu-core/
├── src/       Verilog RTL
├── sim/       Verilog testbenches
├── tests/     Hand-written machine-code memory files
├── scripts/   Simulation, parsing, and synthesis scripts
├── docs/      Design and ISA notes
└── results/   Generated simulation and synthesis outputs
```

## Build and Run

Run all simulations:

```sh
make clean
make test
```

Run synthesis reporting:

```sh
make synth
```

Open the waveform, if GTKWave is installed:

```sh
make wave
```

## Expected Output

`make test` prints PASS/FAIL lines for the unit tests and integration tests.
The final report should show:

```text
Integration tests passed: 3/3
- add_test: PASS
- fibonacci: PASS
- bubble_sort: PASS
```

## Result Files

Generated files:

- `results/sim_log.csv`
- `results/simulation_report.txt`
- `results/synthesis_report.txt`
- `results/waveform.vcd`

Compiled `.vvp` files are temporary and ignored by git.

## Major File Guide

- `src/riscv_top.v`: connects all stages, pipeline registers, hazard logic, and writeback.
- `src/fetch.v`: PC update and instruction memory access.
- `src/decode.v`: register reads, immediate generation, and control decode.
- `src/execute.v`: ALU operation, forwarding operand selection, branch/JAL target logic.
- `src/mem_stage.v`: data memory access.
- `src/writeback.v`: writeback result mux.
- `src/hazard.v`: forwarding and load-use stall detection.
- `src/alu.v`: arithmetic and logic operations.
- `src/regfile.v`: 32-register file with hardwired `x0`.
- `sim/tb_riscv.v`: integration testbench with waveform and CSV logging.

## Known Limitations

- This is an RV32I subset, not a full RV32I implementation.
- Branch and jump decisions resolve in execute and flush younger instructions.
- No exceptions, interrupts, CSRs, privilege modes, or system instructions.
- No byte or halfword memory operations.
- No unaligned memory access handling.
- The bubble sort test is a small three-element unrolled program, not a general
  software benchmark.

## Future Improvements

- Add more RV32I instructions and tests.
- Add a simple assembler script for the supported subset.
- Add more hazard-focused integration tests.
- Add more detailed waveform viewing notes.
- Improve synthesis constraints and target-specific reporting without claiming
  FPGA deployment unless it is actually performed.
