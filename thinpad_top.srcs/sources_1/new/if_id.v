/*
IF_ID模块
*/
`define InstAddrBus 31:0
`define InstBus 31:0
`define ZeroWord 32'h00000000
`define Stop 1'b1
`define NoStop 1'b0

module if_id(

	input wire	clk,
	input wire	rst,

	// 来自指令储存器的暂停信号
	input wire inst_pause, 

	//来自控制模块
	input wire[5:0]               stall_signal,	
	input wire                    flush,

	input wire[`InstAddrBus]	  if_pc,
	input wire[`InstBus]          if_inst,
	output reg[`InstAddrBus]      id_pc,
	output reg[`InstBus]          id_inst  
	
);

	always @ (posedge clk) begin
		if (rst ==  1'b1) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end else if(flush == 1'b1 ) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;					
		end else if(stall_signal[1] == 1'b1 && stall_signal[2] == 1'b0) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;	
	    end else if(stall_signal[1] == 1'b0) begin
		  id_pc <= if_pc;
		  id_inst <= if_inst;
		end
	end

endmodule