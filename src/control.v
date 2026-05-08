`timescale 1ns/1ps

module control (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg       reg_write,
    output reg       mem_read,
    output reg       mem_write,
    output reg       mem_to_reg,
    output reg       alu_src,
    output reg       branch,
    output reg       jump,
    output reg       lui,
    output reg [3:0] alu_ctrl
);
    localparam OP_RTYPE = 7'b0110011;
    localparam OP_ITYPE = 7'b0010011;
    localparam OP_LOAD  = 7'b0000011;
    localparam OP_STORE = 7'b0100011;
    localparam OP_BRANCH= 7'b1100011;
    localparam OP_JAL   = 7'b1101111;
    localparam OP_LUI   = 7'b0110111;

    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;
    localparam ALU_SLT = 4'b0101;
    localparam ALU_SLL = 4'b0110;
    localparam ALU_SRL = 4'b0111;

    always @(*) begin
        reg_write = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        mem_to_reg= 1'b0;
        alu_src   = 1'b0;
        branch    = 1'b0;
        jump      = 1'b0;
        lui       = 1'b0;
        alu_ctrl  = ALU_ADD;

        case (opcode)
            OP_RTYPE: begin
                reg_write = 1'b1;
                case ({funct7, funct3})
                    {7'b0000000, 3'b000}: alu_ctrl = ALU_ADD;
                    {7'b0100000, 3'b000}: alu_ctrl = ALU_SUB;
                    {7'b0000000, 3'b111}: alu_ctrl = ALU_AND;
                    {7'b0000000, 3'b110}: alu_ctrl = ALU_OR;
                    {7'b0000000, 3'b100}: alu_ctrl = ALU_XOR;
                    {7'b0000000, 3'b010}: alu_ctrl = ALU_SLT;
                    {7'b0000000, 3'b001}: alu_ctrl = ALU_SLL;
                    {7'b0000000, 3'b101}: alu_ctrl = ALU_SRL;
                    default: begin
                        reg_write = 1'b0;
                        alu_ctrl = ALU_ADD;
                    end
                endcase
            end
            OP_ITYPE: begin
                if (funct3 == 3'b000) begin
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    alu_ctrl = ALU_ADD;
                end
            end
            OP_LOAD: begin
                if (funct3 == 3'b010) begin
                    reg_write = 1'b1;
                    mem_read = 1'b1;
                    mem_to_reg = 1'b1;
                    alu_src = 1'b1;
                    alu_ctrl = ALU_ADD;
                end
            end
            OP_STORE: begin
                if (funct3 == 3'b010) begin
                    mem_write = 1'b1;
                    alu_src = 1'b1;
                    alu_ctrl = ALU_ADD;
                end
            end
            OP_BRANCH: begin
                if (funct3 == 3'b000) begin
                    branch = 1'b1;
                    alu_ctrl = ALU_SUB;
                end
            end
            OP_JAL: begin
                reg_write = 1'b1;
                jump = 1'b1;
            end
            OP_LUI: begin
                reg_write = 1'b1;
                lui = 1'b1;
            end
            default: begin
            end
        endcase
    end
endmodule
