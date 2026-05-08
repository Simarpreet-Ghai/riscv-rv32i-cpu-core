`timescale 1ns/1ps

module writeback (
    input         mem_to_reg,
    input  [31:0] alu_result,
    input  [31:0] mem_read_data,
    output [31:0] write_data
);
    assign write_data = mem_to_reg ? mem_read_data : alu_result;
endmodule
