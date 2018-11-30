`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2018 09:27:31 AM
// Design Name: 
// Module Name: regfile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module regfile(
    input wire              clk,
    input wire              rst,
    
    // write
    input wire              we,
    input wire[`RegAddrBus] waddr,
    input wire[`RegBus]     wdata,
    
    // read 1
    input wire              re1,
    input wire[`RegAddrBus] raddr1,
    output reg[`RegBus]     rdata1,

    // read 2
    input wire              re2,
    input wire[`RegAddrBus] raddr2,
    output reg[`RegBus]     rdata2,

    output reg[`RegBus]     reg19
);

    // 32 registers
    reg[`RegBus]            regs[0:`RegNum-1];
    
    // write
    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            if ((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
                regs[waddr] <= wdata;
            end
        end
    end
    
    // read 1
    always @ (*) begin
        if (rst == `RstEnable || raddr1 == `RegNumLog2'h0) begin
            rdata1 <= `ZeroWord;
        end else if (raddr1 == waddr && we == `WriteEnable) begin
            rdata1 <= wdata;
        end else begin
            rdata1 <= regs[raddr1];
        end
    end

    // read 2
    always @ (*) begin
        if (rst == `RstEnable || raddr2 == `RegNumLog2'h0) begin
            rdata2 <= `ZeroWord;
        end else if (raddr2 == waddr && we == `WriteEnable) begin
            rdata2 <= wdata;
        end else begin
            rdata2 <= regs[raddr2];
        end
    end
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            reg19 <= `ZeroWord;
        end else begin
            reg19 <= regs[5'h13];
        end
    end
    
endmodule
