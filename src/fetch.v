`timescale 1ns/1ps

module fetch (
    input         clk,
    input         reset,
    input         stall,
    input         pc_src,
    input  [31:0] pc_target,
    output reg [31:0] pc,
    output [31:0] instr
);
    imem u_imem (
        .addr(pc),
        .instr(instr)
    );

    always @(posedge clk) begin
        if (reset)
            pc <= 32'd0;
        else if (!stall) begin
            if (pc_src)
                pc <= pc_target;
            else
                pc <= pc + 32'd4;
        end
    end
endmodule
