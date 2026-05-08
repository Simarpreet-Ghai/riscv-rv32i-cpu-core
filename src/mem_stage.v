`timescale 1ns/1ps

module mem_stage (
    input         clk,
    input         mem_read,
    input         mem_write,
    input  [31:0] alu_result,
    input  [31:0] store_data,
    output [31:0] mem_read_data
);
    dmem u_dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(alu_result),
        .write_data(store_data),
        .read_data(mem_read_data)
    );
endmodule
