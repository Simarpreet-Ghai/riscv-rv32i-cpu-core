`timescale 1ns/1ps

module if_id_reg (
    input         clk,
    input         reset,
    input         enable,
    input         flush,
    input  [31:0] pc_in,
    input  [31:0] instr_in,
    output reg [31:0] pc_out,
    output reg [31:0] instr_out
);
    always @(posedge clk) begin
        if (reset || flush) begin
            pc_out <= 32'd0;
            instr_out <= 32'h00000013;
        end else if (enable) begin
            pc_out <= pc_in;
            instr_out <= instr_in;
        end
    end
endmodule
