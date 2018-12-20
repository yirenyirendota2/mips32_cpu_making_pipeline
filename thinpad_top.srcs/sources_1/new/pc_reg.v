/*
PC模块
*/
`define RegBus 31:0
`define InstAddrBus 31:0
`define ChipEnable 1'b1
`define ChipDisable 1'b0
`define PCStart 32'h80000000 

module pc_reg(

	input wire	clk,
	input wire	rst,

	// 来自指令存储器的冲突暂停信号   1为暂停
	input wire inst_pause, 
	
	input wire[5:0]               stall,
	input wire                    flush,
	 input wire[31:0]           new_pc,

	
	 input wire                    branch_flag_i,
	 input wire[31:0]           branch_target_address_i,
	
	output reg[`InstAddrBus]	  pc,
	output reg                    ce
	
);

	always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <= `PCStart;		
		end else begin
			/*
			if (inst_pause == 1) begin
			  pc <= pc;
			end else 
			*/
			if(flush == 1'b1) begin
				pc <= new_pc;
			end else if(stall[0] == 1'b0) begin
				if(branch_flag_i == `Branch) begin
					pc <= branch_target_address_i;
				end else begin
		  		pc <= pc + 4'h4;
		  	end
			end
		end
	end

	always @ (posedge clk) begin
		if (rst == 1'b1) begin
			ce <= `ChipDisable;
		end else begin
			ce <= `ChipEnable;
		end
	end

endmodule