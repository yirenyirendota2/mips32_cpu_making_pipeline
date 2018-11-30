`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2018 10:42:40 AM
// Design Name: 
// Module Name: inst_real_rom
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


module inst_real_rom(
       input wire                   ce,
	   input wire[`InstAddrBus]		addr,
	   
	   input wire[`RegBus]            rom_data_i,       
       output reg[`RegBus]            rom_addr_o,
	   
	   output reg[`InstBus]			inst
	
    );

	reg[`InstAddrBus] real_addr;

  	always @ (*) begin
		real_addr = addr - `PCStart;
	end 

	always @ (*) begin
		if (ce == `ChipDisable) begin
		    // done nothing
	    end else begin
	        rom_addr_o = real_addr[`InstMemNumLog2+1:2];
		end
	end
	
	always @ (*) begin
	   if (ce == `ChipDisable) begin
	       inst <= `ZeroWord;
	   end else begin
	       inst <= rom_data_i;
	   end
	end
endmodule