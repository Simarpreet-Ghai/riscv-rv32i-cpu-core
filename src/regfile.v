`timescale 1ns/1ps

module regfile (
    input         clk,
    input         reset,
    input         we,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,
    input  [31:0] wd,
    output [31:0] rd1,
    output [31:0] rd2
);
    reg [31:0] regs [0:31];
    integer i;

    assign rd1 = (rs1 == 5'd0) ? 32'd0 :
                 (we && (rd == rs1) && (rd != 5'd0)) ? wd :
                 regs[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'd0 :
                 (we && (rd == rs2) && (rd != 5'd0)) ? wd :
                 regs[rs2];

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end else begin
            if (we && (rd != 5'd0))
                regs[rd] <= wd;
            regs[0] <= 32'd0;
        end
    end
endmodule
