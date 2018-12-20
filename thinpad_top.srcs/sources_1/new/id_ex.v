/*
ID_EX阶段
*/
`include "defines.v"

module id_ex(

	input wire	clk,
	input wire	rst,

	//来自控制模块
	input wire[5:0]				 stall_signal,
	input wire                   flush,
	
	//������׶δ��ݵ���Ϣ
	input wire[`AluOpBus]         id_aluop,
	input wire[`AluSelBus]        id_alusel,
	input wire[31:0]           id_reg1,
	input wire[31:0]           id_reg2,
	input wire[`RegAddrBus]       id_wd,
	input wire                    id_wreg,
	input wire[31:0]           id_link_address,
	input wire                    id_is_in_delayslot,
	input wire                    next_inst_in_delayslot_i,		
	input wire[31:0]           id_inst,		
	input wire[31:0]           id_current_inst_address,
	input wire[31:0]              id_excepttype,
	
	//���ݵ�ִ�н׶ε���Ϣ
	output reg[`AluOpBus]         ex_aluop,
	output reg[`AluSelBus]        ex_alusel,
	output reg[31:0]           ex_reg1,
	output reg[31:0]           ex_reg2,
	output reg[`RegAddrBus]       ex_wd,
	output reg                    ex_wreg,
	output reg[31:0]           ex_link_address,
  output reg                    ex_is_in_delayslot,
	output reg                    is_in_delayslot_o,
	output reg[31:0]           ex_inst,
	output reg[31:0]              ex_excepttype,
	output reg[31:0]          ex_current_inst_address	
	
);

	always @ (posedge clk) begin
		if (rst == 1'b1) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= 1'b0;
			ex_link_address <= `ZeroWord;
			ex_is_in_delayslot <= `NotInDelaySlot;
	    is_in_delayslot_o <= `NotInDelaySlot;		
	    ex_inst <= `ZeroWord;	
	    ex_excepttype <= `ZeroWord;
	    ex_current_inst_address <= `ZeroWord;
		end else if(flush == 1'b1 ) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= 1'b0;
			ex_excepttype <= `ZeroWord;
			ex_link_address <= `ZeroWord;
			ex_inst <= `ZeroWord;
			ex_is_in_delayslot <= `NotInDelaySlot;
	    ex_current_inst_address <= `ZeroWord;	
	    is_in_delayslot_o <= `NotInDelaySlot;		    
		end else if(stall_signal[2] == 1'b1 && stall_signal[3] == 1'b0) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= 1'b0;	
			ex_link_address <= `ZeroWord;
			ex_is_in_delayslot <= `NotInDelaySlot;
	    ex_inst <= `ZeroWord;			
	    ex_excepttype <= `ZeroWord;
	    ex_current_inst_address <= `ZeroWord;	
		end else if(stall_signal[2] == 1'b0) begin		
			ex_aluop <= id_aluop;
			ex_alusel <= id_alusel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;		
			ex_link_address <= id_link_address;
			ex_is_in_delayslot <= id_is_in_delayslot;
	    is_in_delayslot_o <= next_inst_in_delayslot_i;
	    ex_inst <= id_inst;			
	    ex_excepttype <= id_excepttype;
	    ex_current_inst_address <= id_current_inst_address;		
		end
	end
	
endmodule