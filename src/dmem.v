`timescale 1ns/1ps

module dmem #(
    parameter MEM_WORDS = 256
) (
    input         clk,
    input         mem_read,
    input         mem_write,
    input  [31:0] addr,
    input  [31:0] write_data,
    output [31:0] read_data
);
    reg [31:0] mem [0:MEM_WORDS-1];
    integer i;

    initial begin
        for (i = 0; i < MEM_WORDS; i = i + 1)
            mem[i] = 32'd0;
    end

    assign read_data = mem_read ? mem[addr[31:2]] : 32'd0;

    always @(posedge clk) begin
        if (mem_write)
            mem[addr[31:2]] <= write_data;
    end

    task clear_mem;
        begin
            for (i = 0; i < MEM_WORDS; i = i + 1)
                mem[i] = 32'd0;
        end
    endtask
endmodule
