`timescale 1ns/1ps

module decode (
    input         clk,
    input         reset,
    input  [31:0] instr,
    input         wb_reg_write,
    input  [4:0]  wb_rd,
    input  [31:0] wb_data,
    output [4:0]  rs1,
    output [4:0]  rs2,
    output [4:0]  rd,
    output [31:0] rs1_data,
    output [31:0] rs2_data,
    output reg [31:0] imm,
    output        reg_write,
    output        mem_read,
    output        mem_write,
    output        mem_to_reg,
    output        alu_src,
    output        branch,
    output        jump,
    output        lui,
    output [3:0]  alu_ctrl
);
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    assign rd  = instr[11:7];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];

    regfile u_regfile (
        .clk(clk),
        .reset(reset),
        .we(wb_reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(wb_rd),
        .wd(wb_data),
        .rd1(rs1_data),
        .rd2(rs2_data)
    );

    control u_control (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .jump(jump),
        .lui(lui),
        .alu_ctrl(alu_ctrl)
    );

    always @(*) begin
        case (opcode)
            7'b0010011,
            7'b0000011: imm = {{20{instr[31]}}, instr[31:20]};
            7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7],
                                instr[30:25], instr[11:8], 1'b0};
            7'b1101111: imm = {{11{instr[31]}}, instr[31], instr[19:12],
                                instr[20], instr[30:21], 1'b0};
            7'b0110111: imm = {instr[31:12], 12'd0};
            default:    imm = 32'd0;
        endcase
    end
endmodule
