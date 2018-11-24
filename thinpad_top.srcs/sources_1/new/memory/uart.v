`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/17 21:16:53
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
    input wire clk,
    input wire data_ready, tbre, tsre,
    output wire wrn, rdn,
    inout wire[31:0] uart_data,
    input wire[31:0] cpu_input_data,
    output wire[31:0] cpu_output_data,
    input wire uart_enable,
    input wire write_or_read,//write = 1, read = 0;
    output wire write_finished,
    output wire read_finished
    );

reg temp_wrn;
reg temp_rdn;
reg[31:0] temp_uart_data;
reg temp_write_finished;
reg temp_read_finished;
reg[31:0] temp_cpu_output_data;
assign wrn = temp_wrn;
assign rdn = temp_rdn;
assign uart_data = temp_uart_data;
assign write_finished = temp_write_finished;
assign read_finished = temp_read_finished;
assign cpu_output_data = temp_cpu_output_data;

/* cycle of write and cycle of read */
reg[2:0] write_cycle = 3'b000;
reg[2:0] read_cycle = 3'b000;

always@(posedge clk) begin
    if(clk) begin
        if(~uart_enable) begin
            if(write_or_read) begin
                case(write_cycle)
                    3'b000: begin
                        temp_uart_data <= cpu_input_data;
                        temp_wrn <= 1'b1;
                        temp_rdn <= 1'b1;  
                        write_cycle <= write_cycle + 1'b1;
                    end
                    3'b001: begin
                        temp_wrn <= 1'b0;
                        temp_rdn <= 1'b1;
                        write_cycle <= write_cycle + 1'b1;
                    end
                    3'b010: begin
                        temp_wrn <= 1'b1;
                        temp_rdn <= 1'b1;
                        write_cycle <= write_cycle + 1'b1;  
                    end
                    3'b011: begin
                        if(tbre) begin
                            write_cycle <= write_cycle + 1'b1;  
                        end
                        else begin
                            write_cycle <= write_cycle - 1'b1;  //tbre no ready return to last state
                        end  
                    end
                    3'b100: begin
                        if(tsre) begin
                            //finish write cycle
                            temp_write_finished <= 1'b1;
                        end
                    end
                    default: begin
                        write_cycle <= 3'b000;
                    end
                endcase
            end
            else begin
                case(read_cycle)  
                    3'b000: begin
                        temp_uart_data <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                        temp_wrn <= 1'b1;
                        temp_rdn <= 1'b1;
                        read_cycle <= read_cycle + 1'b1;
                    end
                    3'b001: begin
                        if(data_ready) begin
                            temp_rdn <= 1'b0;  
                            temp_wrn <= 1'b1;
                            read_cycle <= read_cycle + 1'b1;
                        end  
                        else begin
                            read_cycle <= read_cycle - 1'b1;
                        end
                    end
                    3'b010: begin
                        temp_cpu_output_data = temp_uart_data;
                        temp_rdn = 1'b1;
                        temp_wrn = 1'b1;
                        temp_read_finished = 1'b1;  
                    end
                    default: begin
                        read_cycle <= 3'b000;  
                    end
                endcase
            end
        end  
        else begin
            temp_wrn <= 1'b1;
            temp_rdn <= 1'b1;  
            temp_write_finished <= 1'b0;
            temp_read_finished <= 1'b0;
            write_cycle <= 3'b000;
            read_cycle <= 3'b000;
        end
    end
end

endmodule
