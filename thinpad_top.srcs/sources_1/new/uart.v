`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: Bingjian Huang
// 
// Create Date: 2018/11/24 22:42:49
// Design Name: 
// Module Name: uart
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


module uart(
    input wire clk_50M,
    input wire rxd,
    output wire txd,
    inout wire ext_uart_ready,
    output wire ext_uart_busy,
    input wire[7:0] input_data, 
    output reg[7:0] output_data,
    input wire write_or_read,//write = 1, read = 0
    input wire enable,
    output reg write_finished,
    output reg read_finished
    );

//直连串口接收发送演示，从直连串口收到的数据再发送出去
wire [7:0] ext_uart_rx;
reg  [7:0] ext_uart_tx;
reg ext_uart_start;

async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块，9600无检验位
    ext_uart_r(
        .clk(clk_50M),                       //外部时钟信号
        .RxD(rxd),                           //外部串行信号输入
        .RxD_data_ready(ext_uart_ready),  //数据接收到标志
        .RxD_clear(ext_uart_ready),       //清除接收标志
        .RxD_data(ext_uart_rx)             //接收到的一字节数据
    );

async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
    ext_uart_t(
        .clk(clk_50M),                  //外部时钟信号
        .TxD(txd),                      //串行信号输出
        .TxD_busy(ext_uart_busy),       //发送器忙状态指示
        .TxD_start(ext_uart_start),    //开始发送信号
        .TxD_data(ext_uart_tx)        //待发送的数据
    );

always @(posedge clk_50M) begin
    if(enable) begin
        if(write_or_read) begin
            if(~ext_uart_busy) begin
                if(~write_finished) begin
                    ext_uart_tx <= input_data;
                    ext_uart_start <= 1'b1;
                    write_finished <= 1'b1;  
                end
                else begin
                    ext_uart_start <= 1'b0;
                end
            end
        end
        else begin
            if(ext_uart_ready) begin
                output_data <= ext_uart_rx;
                read_finished <= 1'b1;  
            end  
        end  
    end
    else begin
        write_finished <= 1'b0;
        read_finished <= 1'b0;
        ext_uart_start <= 1'b0;
        output_data <= 8'h00;
    end
end

// always @(posedge clk_50M) begin //接收到缓冲区ext_uart_buffer
//     if(ext_uart_ready)begin
//         ext_uart_buffer <= ext_uart_rx;
//         led_bits[7:0] <= ext_uart_rx;
//         ext_uart_avai <= 1;
//     end else if(!ext_uart_busy && ext_uart_avai)begin 
//         ext_uart_avai <= 0;
//     end
// end
// always @(posedge clk_50M) begin //将缓冲区ext_uart_buffer发送出去
//     if(one_second == 10000000) begin
//         one_second <= 8'b00000000;
//         if(!ext_uart_busy)begin 
//             ext_uart_tx <= ext_uart_buffer;
//             ext_uart_buffer <= ext_uart_buffer + 1'b1;
//             ext_uart_start <= 1'b1;
//         end 
//     end
//     else begin
//         one_second <= one_second + 1'b1;  
//         ext_uart_start <= 1'b0;
//     end
// end

endmodule
