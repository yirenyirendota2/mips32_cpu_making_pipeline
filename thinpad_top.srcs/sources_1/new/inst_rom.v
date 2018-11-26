// Module:  inst_rom
// File:    inst_rom.v
// Author:  liujiashuo
// Description: Ö¸Áî´æ´¢Æ÷
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module inst_rom(

//	input	wire clk,
	input wire	ce,
	input wire[`InstAddrBus] addr,
	output reg[`InstBus] inst
	
);

	reg[`InstBus]  inst_mem[0:`InstMemNum-1];
	integer i;
	// initial $readmemh ( "inst_rom.data", inst_mem );

	initial begin
    $readmemh("C:/Users/liujiashuo/Desktop/mip32_cpu_making/thinpad_top.srcs/sources_1/new/inst_rom.data", inst_mem);       // ?????txt??????
    for(i=0;i<24;i=i+1)  
        $display("%h%h%h%h",inst_mem[i*4+0],inst_mem[i*4+1],inst_mem[i*4+2],inst_mem[i*4+3]);    // ?????????
	end

	always @ (*) begin
		if (ce == `ChipDisable) begin
			inst <= `ZeroWord;
	  end else begin
		  inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
		end
	end

endmodule