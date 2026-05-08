`timescale 1ns/1ps

module riscv_top (
    input clk,
    input reset,
    output [31:0] debug_pc,
    output [31:0] debug_wb_data,
    output [4:0]  debug_wb_rd,
    output        debug_wb_reg_write
);
    wire [31:0] if_pc, if_instr;
    wire [31:0] if_id_pc, if_id_instr;

    wire [4:0] id_rs1, id_rs2, id_rd;
    wire [31:0] id_rs1_data, id_rs2_data, id_imm;
    wire id_reg_write, id_mem_read, id_mem_write, id_mem_to_reg;
    wire id_alu_src, id_branch, id_jump, id_lui;
    wire [3:0] id_alu_ctrl;

    wire [31:0] id_ex_pc, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
    wire [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    wire id_ex_reg_write, id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg;
    wire id_ex_alu_src, id_ex_branch, id_ex_jump, id_ex_lui;
    wire [3:0] id_ex_alu_ctrl;

    wire [31:0] ex_alu_result, ex_store_data, ex_pc_target;
    wire ex_pc_src;

    wire [31:0] ex_mem_alu_result, ex_mem_store_data;
    wire [4:0] ex_mem_rd;
    wire ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg;

    wire [31:0] mem_read_data;

    wire [31:0] mem_wb_alu_result, mem_wb_mem_read_data;
    wire [4:0] mem_wb_rd;
    wire mem_wb_reg_write, mem_wb_mem_to_reg;
    wire [31:0] wb_write_data;

    wire stall;
    wire [1:0] forward_a, forward_b;
    wire flush_decode = stall | ex_pc_src;

    fetch u_fetch (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .pc_src(ex_pc_src),
        .pc_target(ex_pc_target),
        .pc(if_pc),
        .instr(if_instr)
    );

    if_id_reg u_if_id_reg (
        .clk(clk),
        .reset(reset),
        .enable(~stall),
        .flush(ex_pc_src),
        .pc_in(if_pc),
        .instr_in(if_instr),
        .pc_out(if_id_pc),
        .instr_out(if_id_instr)
    );

    decode u_decode (
        .clk(clk),
        .reset(reset),
        .instr(if_id_instr),
        .wb_reg_write(mem_wb_reg_write),
        .wb_rd(mem_wb_rd),
        .wb_data(wb_write_data),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(id_rd),
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data),
        .imm(id_imm),
        .reg_write(id_reg_write),
        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .mem_to_reg(id_mem_to_reg),
        .alu_src(id_alu_src),
        .branch(id_branch),
        .jump(id_jump),
        .lui(id_lui),
        .alu_ctrl(id_alu_ctrl)
    );

    hazard u_hazard (
        .if_id_rs1(id_rs1),
        .if_id_rs2(id_rs2),
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .id_ex_rd(id_ex_rd),
        .id_ex_mem_read(id_ex_mem_read),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .stall(stall),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    id_ex_reg u_id_ex_reg (
        .clk(clk),
        .reset(reset),
        .flush(flush_decode),
        .pc_in(if_id_pc),
        .rs1_data_in(id_rs1_data),
        .rs2_data_in(id_rs2_data),
        .imm_in(id_imm),
        .rs1_in(id_rs1),
        .rs2_in(id_rs2),
        .rd_in(id_rd),
        .reg_write_in(id_reg_write),
        .mem_read_in(id_mem_read),
        .mem_write_in(id_mem_write),
        .mem_to_reg_in(id_mem_to_reg),
        .alu_src_in(id_alu_src),
        .branch_in(id_branch),
        .jump_in(id_jump),
        .lui_in(id_lui),
        .alu_ctrl_in(id_alu_ctrl),
        .pc_out(id_ex_pc),
        .rs1_data_out(id_ex_rs1_data),
        .rs2_data_out(id_ex_rs2_data),
        .imm_out(id_ex_imm),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .rd_out(id_ex_rd),
        .reg_write_out(id_ex_reg_write),
        .mem_read_out(id_ex_mem_read),
        .mem_write_out(id_ex_mem_write),
        .mem_to_reg_out(id_ex_mem_to_reg),
        .alu_src_out(id_ex_alu_src),
        .branch_out(id_ex_branch),
        .jump_out(id_ex_jump),
        .lui_out(id_ex_lui),
        .alu_ctrl_out(id_ex_alu_ctrl)
    );

    execute u_execute (
        .pc(id_ex_pc),
        .rs1_data(id_ex_rs1_data),
        .rs2_data(id_ex_rs2_data),
        .imm(id_ex_imm),
        .ex_mem_alu_result(ex_mem_alu_result),
        .mem_wb_write_data(wb_write_data),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .alu_src(id_ex_alu_src),
        .branch(id_ex_branch),
        .jump(id_ex_jump),
        .lui(id_ex_lui),
        .alu_ctrl(id_ex_alu_ctrl),
        .alu_result(ex_alu_result),
        .store_data(ex_store_data),
        .pc_target(ex_pc_target),
        .pc_src(ex_pc_src)
    );

    ex_mem_reg u_ex_mem_reg (
        .clk(clk),
        .reset(reset),
        .alu_result_in(ex_alu_result),
        .store_data_in(ex_store_data),
        .rd_in(id_ex_rd),
        .reg_write_in(id_ex_reg_write),
        .mem_read_in(id_ex_mem_read),
        .mem_write_in(id_ex_mem_write),
        .mem_to_reg_in(id_ex_mem_to_reg),
        .alu_result_out(ex_mem_alu_result),
        .store_data_out(ex_mem_store_data),
        .rd_out(ex_mem_rd),
        .reg_write_out(ex_mem_reg_write),
        .mem_read_out(ex_mem_mem_read),
        .mem_write_out(ex_mem_mem_write),
        .mem_to_reg_out(ex_mem_mem_to_reg)
    );

    mem_stage u_mem_stage (
        .clk(clk),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .alu_result(ex_mem_alu_result),
        .store_data(ex_mem_store_data),
        .mem_read_data(mem_read_data)
    );

    mem_wb_reg u_mem_wb_reg (
        .clk(clk),
        .reset(reset),
        .alu_result_in(ex_mem_alu_result),
        .mem_read_data_in(mem_read_data),
        .rd_in(ex_mem_rd),
        .reg_write_in(ex_mem_reg_write),
        .mem_to_reg_in(ex_mem_mem_to_reg),
        .alu_result_out(mem_wb_alu_result),
        .mem_read_data_out(mem_wb_mem_read_data),
        .rd_out(mem_wb_rd),
        .reg_write_out(mem_wb_reg_write),
        .mem_to_reg_out(mem_wb_mem_to_reg)
    );

    writeback u_writeback (
        .mem_to_reg(mem_wb_mem_to_reg),
        .alu_result(mem_wb_alu_result),
        .mem_read_data(mem_wb_mem_read_data),
        .write_data(wb_write_data)
    );

    assign debug_pc = if_pc;
    assign debug_wb_data = wb_write_data;
    assign debug_wb_rd = mem_wb_rd;
    assign debug_wb_reg_write = mem_wb_reg_write;
endmodule
