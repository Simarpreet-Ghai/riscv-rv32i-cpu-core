`timescale 1ns/1ps

module imem #(
    parameter MEM_WORDS = 256
) (
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:MEM_WORDS-1];
    integer i;

    initial begin
        for (i = 0; i < MEM_WORDS; i = i + 1)
            mem[i] = 32'h00000013; // addi x0, x0, 0
    end

    assign instr = mem[addr[31:2]];

    task load_mem;
        input [1023:0] filename;
        integer fd;
        integer idx;
        integer code;
        reg [31:0] word;
        begin
            for (i = 0; i < MEM_WORDS; i = i + 1)
                mem[i] = 32'h00000013;
            fd = $fopen(filename, "r");
            if (fd == 0) begin
                $display("ERROR: could not open instruction memory file %0s", filename);
            end else begin
                idx = 0;
                while (!$feof(fd) && (idx < MEM_WORDS)) begin
                    code = $fscanf(fd, "%h\n", word);
                    if (code == 1) begin
                        mem[idx] = word;
                        idx = idx + 1;
                    end
                end
                $fclose(fd);
            end
        end
    endtask
endmodule
