`timescale 1ns/1ps

module execute (
    input  [31:0] pc,
    input  [31:0] rs1_data,
    input  [31:0] rs2_data,
    input  [31:0] imm,
    input  [31:0] ex_mem_alu_result,
    input  [31:0] mem_wb_write_data,
    input  [1:0]  forward_a,
    input  [1:0]  forward_b,
    input         alu_src,
    input         branch,
    input         jump,
    input         lui,
    input  [3:0]  alu_ctrl,
    output [31:0] alu_result,
    output [31:0] store_data,
    output [31:0] pc_target,
    output        pc_src
);
    wire [31:0] operand_a =
        (forward_a == 2'b10) ? ex_mem_alu_result :
        (forward_a == 2'b01) ? mem_wb_write_data :
        rs1_data;

    wire [31:0] forwarded_rs2 =
        (forward_b == 2'b10) ? ex_mem_alu_result :
        (forward_b == 2'b01) ? mem_wb_write_data :
        rs2_data;

    wire [31:0] operand_b = alu_src ? imm : forwarded_rs2;
    wire [31:0] raw_alu_result;
    wire zero;

    alu u_alu (
        .a(operand_a),
        .b(operand_b),
        .alu_ctrl(alu_ctrl),
        .result(raw_alu_result),
        .zero(zero)
    );

    assign store_data = forwarded_rs2;
    assign pc_target = pc + imm;
    assign pc_src = jump | (branch & zero);
    assign alu_result = lui ? imm :
                        jump ? (pc + 32'd4) :
                        raw_alu_result;
endmodule
