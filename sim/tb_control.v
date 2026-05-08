`timescale 1ns/1ps

module tb_control;
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire alu_src;
    wire branch;
    wire jump;
    wire lui;
    wire [3:0] alu_ctrl;
    integer failures;

    control dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .jump(jump),
        .lui(lui),
        .alu_ctrl(alu_ctrl)
    );

    task check_control;
        input expected_reg_write;
        input expected_mem_read;
        input expected_mem_write;
        input expected_mem_to_reg;
        input expected_alu_src;
        input expected_branch;
        input expected_jump;
        input expected_lui;
        input [3:0] expected_alu_ctrl;
        input [8*16-1:0] name;
        begin
            #1;
            if (reg_write !== expected_reg_write ||
                mem_read !== expected_mem_read ||
                mem_write !== expected_mem_write ||
                mem_to_reg !== expected_mem_to_reg ||
                alu_src !== expected_alu_src ||
                branch !== expected_branch ||
                jump !== expected_jump ||
                lui !== expected_lui ||
                alu_ctrl !== expected_alu_ctrl) begin
                $display("FAIL tb_control %0s", name);
                failures = failures + 1;
            end else begin
                $display("PASS tb_control %0s", name);
            end
        end
    endtask

    initial begin
        failures = 0;

        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000;
        check_control(1,0,0,0,0,0,0,0,4'b0000,"ADD");
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0100000;
        check_control(1,0,0,0,0,0,0,0,4'b0001,"SUB");
        opcode = 7'b0110011; funct3 = 3'b111; funct7 = 7'b0000000;
        check_control(1,0,0,0,0,0,0,0,4'b0010,"AND");
        opcode = 7'b0110011; funct3 = 3'b110; funct7 = 7'b0000000;
        check_control(1,0,0,0,0,0,0,0,4'b0011,"OR");
        opcode = 7'b0110011; funct3 = 3'b100; funct7 = 7'b0000000;
        check_control(1,0,0,0,0,0,0,0,4'b0100,"XOR");
        opcode = 7'b0110011; funct3 = 3'b010; funct7 = 7'b0000000;
        check_control(1,0,0,0,0,0,0,0,4'b0101,"SLT");
        opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000;
        check_control(1,0,0,0,1,0,0,0,4'b0000,"ADDI");
        opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000;
        check_control(1,1,0,1,1,0,0,0,4'b0000,"LW");
        opcode = 7'b0100011; funct3 = 3'b010; funct7 = 7'b0000000;
        check_control(0,0,1,0,1,0,0,0,4'b0000,"SW");
        opcode = 7'b1100011; funct3 = 3'b000; funct7 = 7'b0000000;
        check_control(0,0,0,0,0,1,0,0,4'b0001,"BEQ");
        opcode = 7'b1101111; funct3 = 3'b000; funct7 = 7'b0000000;
        check_control(1,0,0,0,0,0,1,0,4'b0000,"JAL");
        opcode = 7'b0110111; funct3 = 3'b000; funct7 = 7'b0000000;
        check_control(1,0,0,0,0,0,0,1,4'b0000,"LUI");

        if (failures == 0)
            $display("PASS tb_control");
        else
            $display("FAIL tb_control failures=%0d", failures);
        $finish;
    end
endmodule
