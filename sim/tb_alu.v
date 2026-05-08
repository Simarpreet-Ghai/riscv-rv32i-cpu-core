`timescale 1ns/1ps

module tb_alu;
    reg [31:0] a;
    reg [31:0] b;
    reg [3:0] alu_ctrl;
    wire [31:0] result;
    wire zero;
    integer failures;

    alu dut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    task check;
        input [3:0] op;
        input [31:0] in_a;
        input [31:0] in_b;
        input [31:0] expected;
        input [8*16-1:0] name;
        begin
            alu_ctrl = op;
            a = in_a;
            b = in_b;
            #1;
            if (result !== expected) begin
                $display("FAIL tb_alu %0s expected=%h got=%h", name, expected, result);
                failures = failures + 1;
            end else begin
                $display("PASS tb_alu %0s", name);
            end
        end
    endtask

    initial begin
        failures = 0;
        check(4'b0000, 32'd10, 32'd7,  32'd17, "ADD");
        check(4'b0001, 32'd10, 32'd7,  32'd3,  "SUB");
        check(4'b0010, 32'hf0f0, 32'h0ff0, 32'h00f0, "AND");
        check(4'b0011, 32'hf0f0, 32'h0ff0, 32'hfff0, "OR");
        check(4'b0100, 32'hf0f0, 32'h0ff0, 32'hff00, "XOR");
        check(4'b0101, 32'hffffffff, 32'd1, 32'd1, "SLT");
        check(4'b0110, 32'd1, 32'd4, 32'd16, "SLL");
        check(4'b0111, 32'd16, 32'd2, 32'd4, "SRL");

        if (failures == 0)
            $display("PASS tb_alu");
        else
            $display("FAIL tb_alu failures=%0d", failures);
        $finish;
    end
endmodule
