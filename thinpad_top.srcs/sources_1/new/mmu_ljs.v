`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: liujiashuo
// 
// Create Date: 2018/11/27 14:55:29
// Design Name: 
// Module Name: mmu_ljs
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
`include "defines.v"

module mmu_ljs(
     //cpu signal
    input wire[31:0] inst_addr,         // IM输入的地址
    input wire rom_ce_i,                // IM使能

    output reg[31:0] inst_o,            // IM输出的32位指令
    output reg stall_req_o,             // IM结构冲突流水线暂停信号

    input wire               mem_we_i,  // 读写使能
    input wire[`DataAddrBus] mem_addr_i,// 数据读写地址
    input wire[3:0]          mem_sel_i, // 字节使能信号
    input wire[`DataBus]     data_i,    // 输入的数据
    input wire               mem_ce_i,  // DM使能
	output reg[`DataBus]     data_o     // 输出数据

     // 时钟信号
    input wire clk_50M,
    input wire rst, 

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd  //直连串口接收端
    );




endmodule
