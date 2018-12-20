`timescale 1ns / 1ps

module regfile(
    input wire              clk,
    input wire              rst,
    
    // write
    input wire              we,
    input wire[`RegAddrBus] waddr,
    input wire[31:0]     wdata,
    
    // read 1
    input wire              re1,
    input wire[`RegAddrBus] raddr1,
    output reg[31:0]     rdata1,

    // read 2
    input wire              re2,
    input wire[`RegAddrBus] raddr2,
    output reg[31:0]     rdata2,

    output reg[31:0]     reg19
);

    // 32 registers
    reg[31:0]            regs[0:`RegNum-1];
    
    // write
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            if ((we == 1'b1) && (waddr != `RegNumLog2'h0)) begin
                regs[waddr] <= wdata;
            end
        end else begin
            regs[0] <= `ZeroWord;
            regs[1] <= `ZeroWord;
            regs[2] <= `ZeroWord;
            regs[3] <= `ZeroWord;
            regs[4] <= `ZeroWord;
            regs[5] <= `ZeroWord;
            regs[6] <= `ZeroWord;
            regs[7] <= `ZeroWord;
            regs[8] <= `ZeroWord;
            regs[9] <= `ZeroWord;
            regs[10] <= `ZeroWord;
            regs[11] <= `ZeroWord;
            regs[12] <= `ZeroWord;
            regs[13] <= `ZeroWord;
            regs[14] <= `ZeroWord;
            regs[15] <= `ZeroWord;
            regs[16] <= `ZeroWord;
            regs[17] <= `ZeroWord;
            regs[18] <= `ZeroWord;
            regs[19] <= `ZeroWord;
            regs[20] <= `ZeroWord;
            regs[21] <= `ZeroWord;
            regs[22] <= `ZeroWord;
            regs[23] <= `ZeroWord;
            regs[24] <= `ZeroWord;
            regs[25] <= `ZeroWord;
            regs[26] <= `ZeroWord;
            regs[27] <= `ZeroWord;
            regs[28] <= `ZeroWord;
            regs[29] <= `ZeroWord;
            regs[30] <= `ZeroWord;
            regs[31] <= `ZeroWord;
            
        end
    end
    
    // read 1
    always @ (*) begin
        if (rst == 1'b1 || raddr1 == `RegNumLog2'h0) begin
            rdata1 <= `ZeroWord;
        end else if (raddr1 == waddr && we == 1'b1) begin
            rdata1 <= wdata;
        end else begin
            rdata1 <= regs[raddr1];
        end
    end

    // read 2
    always @ (*) begin
        if (rst == 1'b1 || raddr2 == `RegNumLog2'h0) begin
            rdata2 <= `ZeroWord;
        end else if (raddr2 == waddr && we == 1'b1) begin
            rdata2 <= wdata;
        end else begin
            rdata2 <= regs[raddr2];
        end
    end
    
    always @ (*) begin
        if (rst == 1'b1) begin
            reg19 <= `ZeroWord;
        end else begin
            reg19 <= regs[5'h13];
        end
    end
    
endmodule
