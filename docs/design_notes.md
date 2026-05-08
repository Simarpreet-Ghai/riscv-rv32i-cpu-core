# Design Notes

This is a simulation-focused Verilog CPU core for a tested **RV32I subset**. It
is intended to be readable for a student hardware portfolio project. It does not
claim FPGA deployment, timing closure, Fmax, or complete RV32I compatibility.

## Datapath

The datapath is organized as five pipeline-style stages:

1. Fetch reads an instruction from instruction memory using the current PC.
2. Decode reads register operands, generates immediates, and produces control signals.
3. Execute selects forwarded operands, runs the ALU, and resolves `BEQ`/`JAL`.
4. Memory performs word loads and stores through data memory.
5. Writeback selects either ALU result or memory data and writes the register file.

The top-level integration is in `src/riscv_top.v`. The stage modules are kept
small so the control and datapath wiring can be followed without a diagramming
tool.

## Pipeline Registers

The project includes explicit pipeline register modules:

- `if_id_reg.v`
- `id_ex_reg.v`
- `ex_mem_reg.v`
- `mem_wb_reg.v`

These registers carry instruction data, operands, destination registers, and
control signals between stages. Bubbles are inserted by clearing control signals
in the ID/EX register.

## Hazard Handling

`src/hazard.v` implements:

- EX/MEM to EX forwarding for ALU results.
- MEM/WB to EX forwarding for ALU and load results.
- A one-cycle load-use stall when the instruction in decode needs the result of
  a load currently in execute.

Branches and `JAL` are resolved in execute. When a branch or jump is taken, the
IF/ID and ID/EX pipeline registers are flushed. This means taken control-flow
instructions have a simple flush penalty.

Current limitations:

- No branch prediction.
- No exception, interrupt, CSR, or privilege support.
- Only word-addressed `LW`/`SW` behavior is tested.
- No unaligned access handling.

## Memories and Test Loading

`src/imem.v` stores 32-bit instruction words and is loaded by the testbench with
`$readmemh`. Test programs live in `tests/` and are hand-written machine-code
hex files.

`src/dmem.v` is a small word-addressed data memory. The integration testbench
clears it before each program and checks expected memory contents afterward.

The integration testbench accepts plusargs:

```sh
vvp tb_riscv.vvp +PROGRAM=tests/add_test.mem +TESTNAME=add_test +CYCLES=80
```

## Test Programs

- `add_test.mem` covers arithmetic, logic, `LUI`, `LW`, `SW`, `BEQ`, and `JAL`.
- `fibonacci.mem` uses a small loop to compute Fibonacci state and store results.
- `bubble_sort.mem` is a small three-element unrolled bubble-sort style program.
  It is intentionally modest so the machine code remains inspectable.
