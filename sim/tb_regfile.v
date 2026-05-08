`timescale 1ns/1ps

module tb_regfile;
    reg clk;
    reg reset;
    reg we;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [31:0] wd;
    wire [31:0] rd1;
    wire [31:0] rd2;
    integer failures;

    regfile dut (
        .clk(clk),
        .reset(reset),
        .we(we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    always #5 clk = ~clk;

    task check_value;
        input [31:0] got;
        input [31:0] expected;
        input [8*24-1:0] name;
        begin
            if (got !== expected) begin
                $display("FAIL tb_regfile %0s expected=%h got=%h", name, expected, got);
                failures = failures + 1;
            end else begin
                $display("PASS tb_regfile %0s", name);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        we = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        wd = 0;
        failures = 0;

        #12 reset = 0;

        rd = 5'd5;
        wd = 32'h12345678;
        we = 1;
        #10 we = 0;
        rs1 = 5'd5;
        #1 check_value(rd1, 32'h12345678, "write_read_x5");

        rd = 5'd0;
        wd = 32'hffffffff;
        we = 1;
        #10 we = 0;
        rs1 = 5'd0;
        rs2 = 5'd5;
        #1 check_value(rd1, 32'd0, "x0_stays_zero");
        check_value(rd2, 32'h12345678, "x5_unchanged");

        if (failures == 0)
            $display("PASS tb_regfile");
        else
            $display("FAIL tb_regfile failures=%0d", failures);
        $finish;
    end
endmodule
