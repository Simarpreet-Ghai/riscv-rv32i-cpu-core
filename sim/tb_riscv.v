`timescale 1ns/1ps

module tb_riscv;
    reg clk;
    reg reset;
    reg [1023:0] prog_file;
    reg [1023:0] testname;
    integer cycles;
    integer i;
    integer test_pass;
    integer log_fd;

    riscv_top uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    task check_reg;
        input [4:0] regnum;
        input [31:0] expected;
        begin
            if (uut.u_decode.u_regfile.regs[regnum] !== expected) begin
                $display("FAIL %0s x%0d expected=%0d got=%0d",
                         testname, regnum, expected, uut.u_decode.u_regfile.regs[regnum]);
                test_pass = 0;
            end
        end
    endtask

    task check_mem;
        input [31:0] byte_addr;
        input [31:0] expected;
        begin
            if (uut.u_mem_stage.u_dmem.mem[byte_addr[31:2]] !== expected) begin
                $display("FAIL %0s mem[%0d] expected=%0d got=%0d",
                         testname, byte_addr, expected,
                         uut.u_mem_stage.u_dmem.mem[byte_addr[31:2]]);
                test_pass = 0;
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        test_pass = 1;
        cycles = 80;
        prog_file = "tests/add_test.mem";
        testname = "add_test";

        if (!$value$plusargs("PROGRAM=%s", prog_file))
            prog_file = "tests/add_test.mem";
        if (!$value$plusargs("TESTNAME=%s", testname))
            testname = "add_test";
        if (!$value$plusargs("CYCLES=%d", cycles))
            cycles = 80;

        $dumpfile("results/waveform.vcd");
        $dumpvars(0, tb_riscv);

        uut.u_fetch.u_imem.load_mem(prog_file);
        uut.u_mem_stage.u_dmem.clear_mem();

        #20 reset = 0;
        for (i = 0; i < cycles; i = i + 1)
            @(posedge clk);
        #1;

        if (testname == "add_test") begin
            check_reg(5'd3, 32'd12);
            check_reg(5'd4, 32'd7);
            check_reg(5'd5, 32'h00010000);
            check_reg(5'd10, 32'd12);
            check_reg(5'd11, 32'd0);
            check_reg(5'd12, 32'd56);
            check_reg(5'd13, 32'd0);
            check_reg(5'd14, 32'd1);
            check_mem(32'd0, 32'd12);
        end else if (testname == "fibonacci") begin
            check_reg(5'd1, 32'd8);
            check_reg(5'd2, 32'd13);
            check_reg(5'd3, 32'd0);
            check_reg(5'd6, 32'd2);
            check_mem(32'd4, 32'd8);
            check_mem(32'd8, 32'd2);
        end else if (testname == "bubble_sort") begin
            check_reg(5'd8, 32'd1);
            check_reg(5'd9, 32'd2);
            check_reg(5'd10, 32'd3);
            check_mem(32'd16, 32'd1);
            check_mem(32'd20, 32'd2);
            check_mem(32'd24, 32'd3);
        end else begin
            $display("FAIL unknown testname %0s", testname);
            test_pass = 0;
        end

        if (test_pass)
            $display("PASS %0s cycles=%0d program=%0s", testname, cycles, prog_file);
        else
            $display("FAIL %0s cycles=%0d program=%0s", testname, cycles, prog_file);

        log_fd = $fopen("results/sim_log.csv", "a");
        $fwrite(log_fd, "%0s,%0s,%0d,%0s\n",
                testname, test_pass ? "PASS" : "FAIL", cycles, prog_file);
        $fclose(log_fd);

        $finish;
    end
endmodule
