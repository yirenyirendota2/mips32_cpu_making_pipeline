`include "defines.v"

module ex_mem(

	input	wire										clk,
	input wire										rst,

	//���Կ���ģ�����Ϣ
	input wire[5:0]							 stall,	
	input wire                   flush,
	
	input wire[`RegAddrBus]       ex_wd,
	input wire                    ex_wreg,
	input wire[31:0]					 ex_wdata, 	
	input wire[31:0]           ex_hi,
	input wire[31:0]           ex_lo,
	input wire                    ex_whilo, 	

      input wire[`AluOpBus]        ex_aluop,
	input wire[31:0]          ex_mem_addr,
	input wire[31:0]          ex_reg2,

	input wire[`DoubleRegBus]     hilo_i,	
	input wire[1:0]               cnt_i,	

	input wire                   ex_cp0_we,
	input wire[4:0]              ex_cp0_write_addr,
	input wire[31:0]          	ex_cp0_data,	

  input wire[31:0]             ex_except_type,
	input wire                   ex_is_in_delayslot,
	input wire[31:0]          	ex_current_inst_address,
	
	//�͵��ô�׶ε���Ϣ
	output reg[`RegAddrBus]      mem_wd,
	output reg                   mem_wreg,
	output reg[31:0]					 mem_wdata,
	output reg[31:0]          mem_hi,
	output reg[31:0]          mem_lo,
	output reg                   mem_whilo,

  //Ϊʵ�ּ��ء��ô�ָ������
  output reg[`AluOpBus]        mem_aluop,
	output reg[31:0]          mem_mem_addr,
	output reg[31:0]          mem_reg2,
	
	output reg                   mem_cp0_we,
	output reg[4:0]              mem_cp0_write_addr,
	output reg[31:0]          mem_cp0_data,
	
	output reg[31:0]            mem_except_type,
  output reg                  mem_is_in_delayslot,
	output reg[31:0]         mem_current_inst_address,
		
	output reg[`DoubleRegBus]    hilo_o,
	output reg[1:0]              cnt_o	
	
	
);


	always @ (posedge clk) begin
		if(rst == 1'b1) begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= 1'b0;
		  mem_wdata <= `ZeroWord;	
		  mem_hi <= `ZeroWord;
		  mem_lo <= `ZeroWord;
		  mem_whilo <= 1'b0;		
	    hilo_o <= {`ZeroWord, `ZeroWord};
			cnt_o <= 2'b00;	
  		mem_aluop <= `EXE_NOP_OP;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;	
			mem_cp0_we <= 1'b0;
			mem_cp0_write_addr <= 5'b00000;
			mem_cp0_data <= `ZeroWord;	
			mem_except_type <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
	    mem_current_inst_address <= `ZeroWord;
		end else if(flush == 1'b1 ) begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= 1'b0;
		  mem_wdata <= `ZeroWord;
		  mem_hi <= `ZeroWord;
		  mem_lo <= `ZeroWord;
		  mem_whilo <= 1'b0;
  		mem_aluop <= `EXE_NOP_OP;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;
			mem_cp0_we <= 1'b0;
			mem_cp0_write_addr <= 5'b00000;
			mem_cp0_data <= `ZeroWord;
			mem_except_type <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
	    mem_current_inst_address <= `ZeroWord;
	    hilo_o <= {`ZeroWord, `ZeroWord};
			cnt_o <= 2'b00;	    	    				
		end else if(stall[3] == 1'b1 && stall[4] == 1'b0) begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= 1'b0;
		  mem_wdata <= `ZeroWord;
		  mem_hi <= `ZeroWord;
		  mem_lo <= `ZeroWord;
		  mem_whilo <= 1'b0;
	    hilo_o <= hilo_i;
			cnt_o <= cnt_i;	
  		mem_aluop <= `EXE_NOP_OP;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;		
			mem_cp0_we <= 1'b0;
			mem_cp0_write_addr <= 5'b00000;
			mem_cp0_data <= `ZeroWord;	
			mem_except_type <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
	    mem_current_inst_address <= `ZeroWord;						  				    
		end else if(stall[3] == 1'b0) begin
			mem_wd <= ex_wd;
			mem_wreg <= ex_wreg;
			mem_wdata <= ex_wdata;	
			mem_hi <= ex_hi;
			mem_lo <= ex_lo;
			mem_whilo <= ex_whilo;	
	    hilo_o <= {`ZeroWord, `ZeroWord};
			cnt_o <= 2'b00;	
  		mem_aluop <= ex_aluop;
			mem_mem_addr <= ex_mem_addr;
			mem_reg2 <= ex_reg2;
			mem_cp0_we <= ex_cp0_we;
			mem_cp0_write_addr <= ex_cp0_write_addr;
			mem_cp0_data <= ex_cp0_data;	
			mem_except_type <= ex_except_type;
			mem_is_in_delayslot <= ex_is_in_delayslot;
	    mem_current_inst_address <= ex_current_inst_address;						
		end else begin
	    hilo_o <= hilo_i;
			cnt_o <= cnt_i;											
		end    //if
	end      //always
			

endmodule