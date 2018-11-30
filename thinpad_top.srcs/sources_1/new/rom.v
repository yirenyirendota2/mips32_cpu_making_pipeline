`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2018 04:41:01 AM
// Design Name: 
// Module Name: rom
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


module inst_rom(

	   input wire                   ce,
	   input wire[`InstAddrBus]		addr,
	   output reg[`InstBus]			inst
	
    );

	reg[`InstBus]  inst_mem[0:`InstMemNum-1];
	reg[`InstAddrBus] real_addr;
        
	initial begin
	   $readmemh ( "inst_rom.data", inst_mem );
    end

  	always @ (*) begin
		real_addr = addr - `PCStart;
	end 

	always @ (*) begin
		if (ce == `ChipDisable) begin
			inst <= `ZeroWord;
	    end else begin
		    // inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
		    inst <= inst_mem[real_addr[`InstMemNumLog2+1:2]];
		end
	end

endmodule
