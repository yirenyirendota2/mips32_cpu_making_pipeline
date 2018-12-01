`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2018 09:11:03 AM
// Design Name: 
// Module Name: mmu
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


module mmu(
    input wire clk,
    input wire rst,
    
    output reg[31:0]             rom_data_o,       
    input wire[31:0]            rom_addr_i,
    input wire                     rom_ce_i,
    
    output reg[31:0]             ram_data_o,
    input wire[31:0]            ram_addr_i,
    input wire[31:0]            ram_data_i,
    input wire                     ram_we_i,
    input wire[3:0]                ram_sel_i,
    input wire                ram_ce_i,
    
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output reg[19:0] base_ram_addr, //BaseRAM地址
    output reg[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output reg base_ram_ce_n,       //BaseRAM片选，低有效
    output reg base_ram_oe_n,       //BaseRAM读使能，低有效
    output reg base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output reg[19:0] ext_ram_addr, //ExtRAM地址
    output reg[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output reg ext_ram_ce_n,       //ExtRAM片选，低有效
    output reg ext_ram_oe_n,       //ExtRAM读使能，低有效
    output reg ext_ram_we_n       //ExtRAM写使能，低有效
    );
    
    reg[2:0] status, status_clk;
    
    // ext -> rom
    always @ (*) begin
        if (rom_ce_i == `ChipEnable) begin
            ext_ram_we_n <= `SRAMDisable;
            ext_ram_oe_n <= `SRAMEnable;
            ext_ram_ce_n <= `SRAMEnable;
            ext_ram_be_n <= 4'b0000;
            ext_ram_addr <= rom_addr_i;
        end else begin
            ext_ram_we_n <= `SRAMDisable;
            ext_ram_oe_n <= `SRAMDisable;
            ext_ram_ce_n <= `SRAMDisable;
            ext_ram_be_n <= 4'b0000;
        end
    end 
    
    always @ (*) begin
        if (rom_ce_i == `ChipEnable) begin
            rom_data_o <= ext_ram_data;
        end else begin
            rom_data_o <= 32'h00000000;
        end
    end 
    
    // base -> ram
    
   
    assign base_ram_data = (ram_ce_i == `ChipEnable && ram_we_i == `WriteEnable) ? ram_data_i : 32'hZZZZZZZZ;
    
    always @ (posedge clk or posedge rst) begin
        if (rst == `RstEnable) begin
            status = `sram_nop;
        end else begin
            status = status_clk;
        end
    end
    
   
    always @ (*) begin
           
            case (status)
                `sram_nop: begin
                    if (ram_ce_i == `ChipDisable) begin
                        base_ram_ce_n = `SRAMDisable;
                        base_ram_oe_n = `SRAMDisable;
                        base_ram_we_n = `SRAMDisable;
                        status_clk = `sram_nop;
                    end else begin
                        if (ram_we_i == `WriteEnable) begin
                            base_ram_ce_n = `SRAMEnable;
                            base_ram_we_n = `SRAMEnable;
                            base_ram_oe_n = `SRAMDisable;
                            base_ram_be_n = ~ram_sel_i;
                            base_ram_addr = ram_addr_i[21:2];
                            status_clk = `sram_write1;
                        end else begin
                            base_ram_ce_n = `SRAMEnable;
                            base_ram_we_n = `SRAMDisable;
                            base_ram_oe_n = `SRAMEnable;
                            base_ram_be_n = 3'b000;
                            base_ram_addr = ram_addr_i[21:2];
                            status_clk = `sram_read1;
                        end
                    end
                end
                `sram_write1: begin
                    base_ram_ce_n = `SRAMDisable;
                    base_ram_we_n = `SRAMDisable;
                    status_clk = `sram_write2; 
                end
                `sram_write2: begin
                    if (ram_ce_i == `ChipDisable) begin
                                        base_ram_ce_n = `SRAMDisable;
                                        base_ram_oe_n = `SRAMDisable;
                                        base_ram_we_n = `SRAMDisable;
                                        status_clk = `sram_nop;
                                    end else begin
                                        if (ram_we_i == `WriteEnable) begin
                                            base_ram_ce_n = `SRAMEnable;
                                            base_ram_we_n = `SRAMEnable;
                                            base_ram_oe_n = `SRAMDisable;
                                            base_ram_be_n = ~ram_sel_i;
                                            base_ram_addr = ram_addr_i[21:2];
                                            status_clk = `sram_write1;
                                        end else begin
                                            base_ram_ce_n = `SRAMEnable;
                                            base_ram_we_n = `SRAMDisable;
                                            base_ram_oe_n = `SRAMEnable;
                                            base_ram_be_n = 3'b000;
                                            base_ram_addr = ram_addr_i[21:2];
                                            status_clk = `sram_read1;
                                        end
                                    end
                end
                `sram_read1:begin 
                    status_clk = `sram_read2;
                    ram_data_o = base_ram_data;
                end
                `sram_read2:begin
                   if (ram_ce_i == `ChipDisable) begin
                                        base_ram_ce_n = `SRAMDisable;
                                        base_ram_oe_n = `SRAMDisable;
                                        base_ram_we_n = `SRAMDisable;
                                        status_clk = `sram_nop;
                                    end else begin
                                        if (ram_we_i == `WriteEnable) begin
                                            base_ram_ce_n = `SRAMEnable;
                                            base_ram_we_n = `SRAMEnable;
                                            base_ram_oe_n = `SRAMDisable;
                                            base_ram_be_n = ~ram_sel_i;
                                            base_ram_addr = ram_addr_i[21:2];
                                            status_clk = `sram_write1;
                                        end else begin
                                            base_ram_ce_n = `SRAMEnable;
                                            base_ram_we_n = `SRAMDisable;
                                            base_ram_oe_n = `SRAMEnable;
                                            base_ram_be_n = 3'b000;
                                            base_ram_addr = ram_addr_i[21:2];
                                            status_clk = `sram_read1;
                                        end
                                    end
                end
            endcase

    end
    
    
endmodule
