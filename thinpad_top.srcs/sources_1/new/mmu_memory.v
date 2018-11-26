`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: huangbingjian 
// 
// Create Date: 2018/11/25 16:34:40
// Design Name: 
// Module Name: mmu_memory
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

module mmu_memory (
    //cpu signal
    input wire control_enable,//enable mmu = 1, disable = 0
    input wire data_write_or_read,//write = 1, read = 0
    input wire[31:0] instruction_input_addr,
    output reg[31:0] instruction_output_data,
    input wire[3:0] data_be_n,
    input wire[31:0] data_input_addr,
    input wire[31:0] data_input_data,
    output reg[31:0] data_output_data,
    output reg pause_signal,//=1 if data conflict with instruction

    input wire clk_50M,           //50MHz 时钟输入
   
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
    

/* uart variables */

wire ext_uart_ready;
wire ext_uart_busy;
reg[7:0] uart_input_data = 8'b00000000;
wire[7:0] uart_output_data;
reg uart_write_or_read = 1'b1;
reg uart_enable = 1'b0;
wire uart_write_finished;
wire uart_read_finished;
/* uart module */
uart directUart(
    .clk_50M(clk_50M),
    .rxd(rxd),
    .txd(txd),
    .ext_uart_ready(ext_uart_ready),
    .ext_uart_busy(ext_uart_busy),
    .input_data(uart_input_data), 
    .output_data(uart_output_data),
    .write_or_read(uart_write_or_read),//write = 1, read = 0
    .enable(uart_enable),
    .write_finished(uart_write_finished),
    .read_finished(uart_read_finished)
    );


/* basememory variables */
reg baseram_enable = 1'b0;
reg baseram_write_or_read;
reg[31:0] baseram_input_data = 32'h00000000;
wire[31:0] baseram_output_data;
reg[19:0] baseram_addr = 20'h00000;
reg[3:0] base_cpu_be_n = 4'b1111;
wire baseram_finished;
/* baseram module */
memory baseRam(
    //clock
    .clk(clk_50M),
    //RAM信号
    .ram_data(base_ram_data),  //RAM数据，低8位与CPLD串口控制器共享
    .ram_addr(base_ram_addr), //RAM地址
    .ram_be_n(base_ram_be_n),  //RAM字节使能，低有效。如果不使用字节使能，请保持为0
    .ram_ce_n(base_ram_ce_n),       //RAM片选，低有效
    .ram_oe_n(base_ram_oe_n),       //RAM读使能，低有效
    .ram_we_n(base_ram_we_n),       //RAM写使能，低有效
    //控制信号
    .write_or_read(baseram_write_or_read),//write = 1, read = 0;
    .ram_enable(baseram_enable),
    //CPU的信号
    .cpu_input_data(baseram_input_data),
    .cpu_output_data(baseram_output_data),
    .cpu_addr(baseram_addr),
    .cpu_be_n(base_cpu_be_n),
    .finished(baseram_finished)
    );

/* extmemory variables */
reg extram_enable = 1'b0;
reg extram_write_or_read;
reg[31:0] extram_input_data = 32'h00000000;
wire[31:0] extram_output_data;
reg[19:0] extram_addr = 20'h00000;
reg[3:0] ext_cpu_be_n = 4'b1111;
wire extram_finished;
/* extram module */
memory extRam(
    //clock
    .clk(clk_50M),
    //RAM信号
    .ram_data(ext_ram_data),  //RAM数据，低8位与CPLD串口控制器共享
    .ram_addr(ext_ram_addr), //RAM地址
    .ram_be_n(ext_ram_be_n),  //RAM字节使能，低有效。如果不使用字节使能，请保持为0
    .ram_ce_n(ext_ram_ce_n),       //RAM片选，低有效
    .ram_oe_n(ext_ram_oe_n),       //RAM读使能，低有效
    .ram_we_n(ext_ram_we_n),       //RAM写使能，低有效
    //控制信号
    .write_or_read(extram_write_or_read),//write = 1, read = 0;
    .ram_enable(extram_enable),
    //CPU的信号
    .cpu_input_data(extram_input_data),
    .cpu_output_data(extram_output_data),
    .cpu_addr(extram_addr),
    .cpu_be_n(ext_cpu_be_n),
    .finished(extram_finished)
    );



//variables
reg start;

always @(posedge clk_50M) begin
    if(control_enable) begin
        if(~start) begin
            //deal with instruction memory first
            if(data_input_addr >= 32'h80000000 && data_input_addr <= 32'h803FFFFF) begin//conflict
                pause_signal <= 1'b1;  
                baseram_addr <= data_input_addr[21:2];
                baseram_enable <= 1'b1;
                baseram_write_or_read <= data_write_or_read;
                base_cpu_be_n <= data_be_n;
                //set others disabled
                extram_enable <= 1'b0;
                uart_enable <= 1'b0;            
            end
            else begin//no conflict
                pause_signal <= 1'b0;
                if(instruction_input_addr >= 32'h80000000 && instruction_input_addr <= 32'h803FFFFF) begin
                    baseram_addr <= instruction_input_addr [21:2];//take 20 bits
                    baseram_enable <= 1'b1;
                    baseram_write_or_read <= 1'b0;//read instructions
                end
                else begin
                    baseram_enable <= 1'b0;  
                end
                if(data_input_addr >= 32'h80400000 && data_input_addr <= 32'h807FFFFF) begin
                    //data from ext memory
                    extram_addr <= data_input_addr[21:2];
                    extram_input_data <= data_input_data;
                    extram_write_or_read <= data_write_or_read;
                    ext_cpu_be_n <= data_be_n;
                    extram_enable <= 1'b1;
                    //set others disabled
                    uart_enable <= 1'b0;
                end
                else if(data_input_addr[31:4] == 28'hBFD003F) begin
                    //data from uart  
                    if(data_input_addr[3:0] == 4'h8) begin
                        //data
                        uart_enable <= 1'b1;
                        uart_input_data <= data_input_data[7:0];
                        uart_write_or_read <= data_write_or_read;
                    end
                    //set others disabled
                    extram_enable <= 1'b0;
                end
            end
            start <= 1'b1;
        end
        else begin
            if(pause_signal) begin
                //pause means IM is used for data
                data_output_data <= baseram_output_data;  
            end
            else begin
                instruction_output_data <= baseram_output_data;
                if(data_input_addr >= 32'h80400000 && data_input_addr <= 32'h807FFFFF) begin
                    data_output_data <= extram_output_data;
                end
                else if(data_input_addr[31:4] == 28'hBFD003F) begin
                    if(data_input_addr[3:0] == 4'h8) begin
                        data_output_data = {24'h000000, uart_output_data};
                    end
                    else if(data_input_addr[3:0] == 4'hC) begin
                        data_output_data = {6'b000000, ext_uart_ready, ~ext_uart_busy};
                    end
                end
            end
            base_cpu_be_n <= 4'b1111;
            ext_cpu_be_n <= 4'b1111;
            start <= 1'b0;
        end
    end
    else begin
        baseram_enable <= 1'b0;
        extram_enable <= 1'b0;
        uart_enable <= 1'b0; 
        base_cpu_be_n <= 4'b1111;
        ext_cpu_be_n <= 4'b1111;
        start <= 1'b0;
    end
end



endmodule
