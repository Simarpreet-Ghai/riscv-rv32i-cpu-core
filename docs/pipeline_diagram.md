# Pipeline Diagram

The implemented CPU is organized as a simple five-stage pipeline-style datapath.

```text
        +---------+    +-----------+    +-----------+    +----------+    +-----------+
PC ---> | Fetch   | -> | Decode    | -> | Execute   | -> | Memory   | -> | Writeback |
        | imem    |    | regfile   |    | ALU       |    | dmem     |    | wb mux    |
        +---------+    +-----------+    +-----------+    +----------+    +-----------+
             |              |                |                |               |
             v              v                v                v               v
          IF/ID           ID/EX            EX/MEM           MEM/WB       register file
```

## Control Flow

```text
BEQ/JAL decision in Execute
        |
        +--> PC target sent back to Fetch
        +--> IF/ID and ID/EX flushed on taken branch or jump
```

## Data Hazards

```text
EX/MEM result  -----> Execute operand muxes
MEM/WB result  -----> Execute operand muxes

Load-use hazard:
    hold PC and IF/ID for one cycle
    insert bubble into ID/EX
```
