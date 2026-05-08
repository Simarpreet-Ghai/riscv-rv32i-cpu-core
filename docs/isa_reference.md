# ISA Reference

This project implements a tested **RV32I subset**, not the full RV32I base ISA.

## Supported Instructions

| Instruction | Type | Opcode | funct3 | funct7 | Notes |
| --- | --- | --- | --- | --- | --- |
| ADD | R | `0110011` | `000` | `0000000` | `rd = rs1 + rs2` |
| SUB | R | `0110011` | `000` | `0100000` | `rd = rs1 - rs2` |
| AND | R | `0110011` | `111` | `0000000` | Bitwise and |
| OR | R | `0110011` | `110` | `0000000` | Bitwise or |
| XOR | R | `0110011` | `100` | `0000000` | Bitwise xor |
| SLT | R | `0110011` | `010` | `0000000` | Signed less-than |
| SLL | R | `0110011` | `001` | `0000000` | Implemented in ALU/control, lightly exercised by unit test |
| SRL | R | `0110011` | `101` | `0000000` | Implemented in ALU/control, lightly exercised by unit test |
| ADDI | I | `0010011` | `000` | n/a | Sign-extended 12-bit immediate |
| LW | I | `0000011` | `010` | n/a | Word load |
| SW | S | `0100011` | `010` | n/a | Word store |
| BEQ | B | `1100011` | `000` | n/a | Branch resolved in execute stage |
| JAL | J | `1101111` | n/a | n/a | Writes `PC + 4` to `rd` |
| LUI | U | `0110111` | n/a | n/a | Writes upper immediate |

## Unsupported Instructions

The rest of RV32I is currently unsupported, including `AUIPC`, `JALR`, `BNE`,
`BLT`, `BGE`, `BLTU`, `BGEU`, byte/halfword loads and stores, unsigned loads,
`SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, immediate shifts, `SLTU`, `SRA`,
`FENCE`, `ECALL`, `EBREAK`, and CSR/system behavior.

Unsupported encodings decode to a safe no-write/no-memory control pattern.
