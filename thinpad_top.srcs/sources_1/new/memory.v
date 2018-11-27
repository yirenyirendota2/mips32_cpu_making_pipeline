`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: Bingjian Huang
// 
// Create Date: 2018/11/17 16:52:59
// Design Name: 
// Module Name: memory
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


module memory(
    //clock
    input wire clk,
    //RAM信号
    inout wire[31:0] ram_data,  //RAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] ram_addr, //RAM地址
    output wire[3:0] ram_be_n,  //RAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ram_ce_n,       //RAM片选，低有效
    output wire ram_oe_n,       //RAM读使能，低有效
    output wire ram_we_n,       //RAM写使能，低有效
    //控制信号
    input wire write_or_read,//write = 1, read = 0;
    input wire ram_enable,
    //CPU的信号
    input wire[31:0] cpu_input_data,
    output wire[31:0] cpu_output_data,
    input wire[19:0] cpu_addr,
    input wire[3:0] cpu_be_n,
    output wire finished
    );

//RAM信号
reg[31:0] temp_ram_data;  //RAM数据，低8位与CPLD串口控制器共享
reg[19:0] temp_ram_addr = 20'h00000; //RAM地址
reg[3:0] temp_ram_be_n = 4'b0000;  //RAM字节使能，低有效。如果不使用字节使能，请保持为0
reg temp_ram_ce_n = 1'b1;       //RAM片选，低有效
reg temp_ram_oe_n = 1'b1;       //RAM读使能，低有效
reg temp_ram_we_n = 1'b1;       //RAM写使能，低有效
//CPU的信号
reg[31:0] temp_cpu_data;
reg temp_finished = 1'b0;//start = 0, end = 1;

assign ram_data = temp_ram_data;
assign ram_addr = temp_ram_addr;
assign ram_be_n = temp_ram_be_n;
assign ram_ce_n = temp_ram_ce_n;
assign ram_oe_n = temp_ram_oe_n;
assign ram_we_n = temp_ram_we_n;
assign cpu_output_data = temp_cpu_data;
assign finished = temp_finished;

always@(posedge clk) begin
    if(clk) begin
        if(ram_enable) begin
            if(~temp_finished) begin//should start
                if(write_or_read) begin//read
                    temp_ram_data <= cpu_input_data;
                    temp_ram_addr <= cpu_addr;
                    temp_ram_ce_n <= 1'b0;
                    temp_ram_we_n <= 1'b0;
                    temp_ram_oe_n <= 1'b1;  
                    temp_ram_be_n <= ~cpu_be_n;
                end
                else begin//write
                    temp_ram_data <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                    temp_ram_addr <= cpu_addr;
                    temp_ram_ce_n <= 1'b0;
                    temp_ram_we_n <= 1'b1;
                    temp_ram_oe_n <= 1'b0;   
                    temp_ram_be_n <= ~cpu_be_n;
                end
                temp_finished <= 1'b1;
            end
            else begin//should end
                // temp_ram_ce_n <= 1'b1;
                // temp_ram_we_n <= 1'b1;
                // temp_ram_oe_n <= 1'b1;
                // temp_ram_be_n <= 4'b0000;
                if(~write_or_read) begin//read data;
                    temp_cpu_data <= ram_data;  
                end
                temp_finished <= 1'b0;
            end
        end
        else begin
            temp_ram_ce_n <= 1'b1;
            temp_ram_we_n <= 1'b1;
            temp_ram_oe_n <= 1'b1;  
            temp_finished <= 1'b0;
        end
    end
end

endmodule
