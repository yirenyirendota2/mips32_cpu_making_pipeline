`include "defines.v"

module mem_wb(

	input	wire										clk,
	input wire										rst,
	input wire[5:0]               stall,	
  input wire                    flush,	
	input wire[`RegAddrBus]       mem_wd,
	input wire                    mem_wreg,
	input wire[31:0]					 mem_wdata,
	input wire[31:0]           mem_hi,
	input wire[31:0]           mem_lo,
	input wire                    mem_whilo,	
	
	input wire                  mem_LLbit_we,
	input wire                  mem_LLbit_value,	

	input wire                   mem_cp0_we,
	input wire[4:0]              mem_cp0_write_addr,
	input wire[31:0]          mem_cp0_data,			

	output reg[`RegAddrBus]      wb_wd,
	output reg                   wb_wreg,
	output reg[31:0]					 wb_wdata,
	output reg[31:0]          wb_hi,
	output reg[31:0]          wb_lo,
	output reg                   wb_whilo,

	output reg                  wb_LLbit_we,
	output reg                  wb_LLbit_value,

	output reg                   wb_cp0_we,
	output reg[4:0]              wb_cp0_write_addr,
	output reg[31:0]          wb_cp0_data								       
	
);


	always @ (posedge clk) begin
		if(rst == 1'b1) begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= 1'b0;
		  wb_wdata <= `ZeroWord;	
		  wb_hi <= `ZeroWord;
		  wb_lo <= `ZeroWord;
		  wb_whilo <= 1'b0;
		  wb_LLbit_we <= 1'b0;
		  wb_LLbit_value <= 1'b0;		
			wb_cp0_we <= 1'b0;
			wb_cp0_write_addr <= 5'b00000;
			wb_cp0_data <= `ZeroWord;			
		end else if(flush == 1'b1 ) begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= 1'b0;
		  wb_wdata <= `ZeroWord;
		  wb_hi <= `ZeroWord;
		  wb_lo <= `ZeroWord;
		  wb_whilo <= 1'b0;
		  wb_LLbit_we <= 1'b0;
		  wb_LLbit_value <= 1'b0;	
//			wb_cp0_we <= 1'b0;
			             wb_cp0_write_addr <= mem_cp0_write_addr;
						wb_cp0_data <= mem_cp0_data;			  		
			wb_cp0_we <= mem_cp0_we;

			//wb_cp0_write_addr <= 5'b00000;
//			wb_cp0_data <= `ZeroWord;				  				  	  	
		end else if(stall[4] == 1'b1 && stall[5] == 1'b0) begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= 1'b0;
		  wb_wdata <= `ZeroWord;
		  wb_hi <= `ZeroWord;
		  wb_lo <= `ZeroWord;
		  wb_whilo <= 1'b0;	
		  wb_LLbit_we <= 1'b0;
		  wb_LLbit_value <= 1'b0;	
			wb_cp0_we <= 1'b0;
			wb_cp0_write_addr <= 5'b00000;
			wb_cp0_data <= `ZeroWord;					  		  	  	  
		end else if(stall[4] == 1'b0) begin
			wb_wd <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;
			wb_hi <= mem_hi;
			wb_lo <= mem_lo;
			wb_whilo <= mem_whilo;		
		  wb_LLbit_we <= mem_LLbit_we;
		  wb_LLbit_value <= mem_LLbit_value;		
			wb_cp0_we <= mem_cp0_we;
			wb_cp0_write_addr <= mem_cp0_write_addr;
			wb_cp0_data <= mem_cp0_data;			  		
		end    //if
	end      //always
			

endmodule