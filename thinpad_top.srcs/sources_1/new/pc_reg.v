
// Module:  pc_reg
// File:    pc_reg.v
// Author:  liujiashuo
// E-mail:  leishangwen@163.com
// Description: 指令指针寄存器PC
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module pc_reg(

	input wire clk,
	input wire rst,

	// 来自指令存储器的冲突暂停信号   1为暂停
	input wire inst_pause, 

	//来自控制模块的信息
	input wire[5:0] stall,

	//来自译码阶段的信息
	input wire branch_flag_i,
	input wire[`RegBus] branch_target_address_i,
	
	output reg[`InstAddrBus] pc,
	output reg ce
	
);

	always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <= 32'h80000000;
		end else if (inst_pause == 1) begin   //  收到了指令存储器的暂停信号，pc值不变，因为指令取不出来
		  pc <= pc ;
		end else if(stall[0] == `NoStop) begin
		  	if(branch_flag_i == `Branch) begin
					pc <= branch_target_address_i;
				end else begin
		  		pc <= pc + 4'h4;
		  	end
		end
	end

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;
		end else begin
			ce <= `ChipEnable;
		end
	end

endmodule