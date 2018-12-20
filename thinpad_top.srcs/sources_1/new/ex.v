`include "defines.v"

module ex(

	input wire	rst,
	
	//alu模块
	input wire[7:0]         aluop_i,
	input wire[2:0]        alusel_i,
	input wire[31:0]           reg1_i,
	input wire[31:0]           reg2_i,
	input wire[4:0]       wd_i,
	input wire                    wreg_i,
	input wire[31:0]           inst_i,
	input wire[31:0]              except_type_i,
	input wire[31:0]          current_inst_address_i,
	
	//HI/LO模块ֵ
	input wire[31:0]           hi_i,
	input wire[31:0]           lo_i,
	input wire[31:0]           wb_hi_i,
	input wire[31:0]           wb_lo_i,
	input wire                    wb_whilo_i,
	
	//mem模块
	input wire[31:0]           mem_hi_i,
	input wire[31:0]           mem_lo_i,
	input wire                    mem_whilo_i,

	input wire[63:0]     hilo_temp_i,
	input wire[1:0]               cnt_i,

	//div模块
	input wire[63:0]     div_result_i,
	input wire                    div_ready_i,

	//link address
	input wire[31:0]           link_address_i,
	input wire                    is_in_delayslot_i,	

	//CP0模块  
	input wire                    mem_cp0_we,
	input wire[4:0]               mem_cp0_write_addr,
	input wire[31:0]           mem_cp0_data,
	
    input wire                    wb_cp0_we,
	input wire[4:0]               wb_cp0_write_addr,
	input wire[31:0]           wb_cp0_data,

	//ֵCP0 REG
	input wire[31:0]           cp0_data_i,
	output reg[4:0]               cp0_read_addr_o,
	output reg                    cp0_we_o,
	output reg[4:0]               cp0_write_addr_o,
	output reg[31:0]           cp0_data_o,
	
	// 输出到wb阶段
	output reg[4:0]       wd_o,
	output reg                    wreg_o,
	output reg[31:0]			  wdata_o,

	output reg[31:0]           hi_o,
	output reg[31:0]           lo_o,
	output reg                    whilo_o,
	
	output reg[63:0]     hilo_temp_o,
	output reg[1:0]               cnt_o,

	output reg[31:0]           div_opdata1_o,
	output reg[31:0]           div_opdata2_o,
	output reg                    div_start_o,
	output reg                    signed_div_o,

	//
	output wire[7:0]        aluop_o,
	output wire[31:0]          mem_addr_o,
	output wire[31:0]          reg2_o,
	
	output wire[31:0]             except_type_o,
	output wire                   is_in_delayslot_o,
	output wire[31:0]          current_inst_address_o,	

	// 流水线暂停请求
	output reg					  stallreq       			
);

	reg[31:0] logicout;
	reg[31:0] shiftres;
	reg[31:0] moveres;
	reg[31:0] arithmeticres;
	reg[63:0] mulres;	
	reg[31:0] HI;
	reg[31:0] LO;
	wire[31:0] reg2_i_mux;
	wire[31:0] reg1_i_not;	
	wire[31:0] result_sum;
	wire ov_sum;
	wire reg1_eq_reg2;
	wire reg1_lt_reg2;
	wire[31:0] opdata1_mult;
	wire[31:0] opdata2_mult;
	wire[63:0] hilo_temp;
	reg[63:0] hilo_temp1;
	reg stallreq_for_madd_msub;			
	reg stallreq_for_div;
	reg trapassert;
	reg ovassert;

  //aluop_o
  assign aluop_o = aluop_i;
  
  //mem_addr拼接ַ
  assign mem_addr_o = reg1_i + {{16{inst_i[15]}},inst_i[15:0]};

  assign reg2_o = reg2_i;
 
  assign except_type_o = {except_type_i[31:12],ovassert,trapassert,except_type_i[9:8],8'h00};
  
  assign is_in_delayslot_o = is_in_delayslot_i;
  assign current_inst_address_o = current_inst_address_i;

	always @ (*) begin
		if(rst == 1'b1) begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_OR_OP:			begin
					logicout <= reg1_i | reg2_i;
				end
				`EXE_AND_OP:		begin
					logicout <= reg1_i & reg2_i;
				end
				`EXE_NOR_OP:		begin
					logicout <= ~(reg1_i |reg2_i);
				end
				`EXE_XOR_OP:		begin
					logicout <= reg1_i ^ reg2_i;
				end
				default:				begin
					logicout <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always

	always @ (*) begin
		if(rst == 1'b1) begin
			shiftres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLL_OP:			begin
					shiftres <= reg2_i << reg1_i[4:0] ;
				end
				`EXE_SRL_OP:		begin
					shiftres <= reg2_i >> reg1_i[4:0];
				end
				`EXE_SRA_OP:		begin
					shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]})) 
												| reg2_i >> reg1_i[4:0];
				end
				default:				begin
					shiftres <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always

	assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) ||
											 (aluop_i == `EXE_SLT_OP)|| (aluop_i == `EXE_TLT_OP) ||
	                       (aluop_i == `EXE_TLTI_OP) || (aluop_i == `EXE_TGE_OP) ||
	                       (aluop_i == `EXE_TGEI_OP)) 
											 ? (~reg2_i)+1 : reg2_i;

	assign result_sum = reg1_i + reg2_i_mux;										 

	assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||
									((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));  
									
	assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP) || (aluop_i == `EXE_TLT_OP) ||
	                       (aluop_i == `EXE_TLTI_OP) || (aluop_i == `EXE_TGE_OP) ||
	                       (aluop_i == `EXE_TGEI_OP)) ?
												 ((reg1_i[31] && !reg2_i[31]) || 
												 (!reg1_i[31] && !reg2_i[31] && result_sum[31])||
			                   (reg1_i[31] && reg2_i[31] && result_sum[31]))
			                   :	(reg1_i < reg2_i);
  
  assign reg1_i_not = ~reg1_i;
							
	always @ (*) begin
		if(rst == 1'b1) begin
			arithmeticres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLT_OP, `EXE_SLTU_OP:		begin
					arithmeticres <= reg1_lt_reg2 ;
				end
				`EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:		begin
					arithmeticres <= result_sum; 
				end
				`EXE_SUB_OP, `EXE_SUBU_OP:		begin
					arithmeticres <= result_sum; 
				end		
				// 计算前导0和1
				`EXE_CLZ_OP:		begin
					arithmeticres <= reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
													 reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
													 reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
													 reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
													 reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
													 reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
													 reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
													 reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
													 reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
													 reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
													 reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
				end
				`EXE_CLO_OP:		begin
					arithmeticres <= (reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 : reg1_i_not[29] ? 2 :
													 reg1_i_not[28] ? 3 : reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
													 reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 : reg1_i_not[23] ? 8 : 
													 reg1_i_not[22] ? 9 : reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
													 reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 : reg1_i_not[17] ? 14 : 
													 reg1_i_not[16] ? 15 : reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 : 
													 reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 : reg1_i_not[11] ? 20 :
													 reg1_i_not[10] ? 21 : reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 : 
													 reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 : reg1_i_not[5] ? 26 : 
													 reg1_i_not[4] ? 27 : reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 : 
													 reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32) ;
				end
				default:				begin
					arithmeticres <= `ZeroWord;
				end
			endcase
		end
	end

	always @ (*) begin
		if(rst == 1'b1) begin
			trapassert <= `TrapNotAssert;
		end else begin
			trapassert <= `TrapNotAssert;
			case (aluop_i)
				`EXE_TEQ_OP, `EXE_TEQI_OP:		begin
					if( reg1_i == reg2_i ) begin
						trapassert <= `TrapAssert;
					end
				end
				`EXE_TGE_OP, `EXE_TGEI_OP, `EXE_TGEIU_OP, `EXE_TGEU_OP:		begin
					if( ~reg1_lt_reg2 ) begin
						trapassert <= `TrapAssert;
					end
				end
				`EXE_TLT_OP, `EXE_TLTI_OP, `EXE_TLTIU_OP, `EXE_TLTU_OP:		begin
					if( reg1_lt_reg2 ) begin
						trapassert <= `TrapAssert;
					end
				end
				`EXE_TNE_OP, `EXE_TNEI_OP:		begin
					if( reg1_i != reg2_i ) begin
						trapassert <= `TrapAssert;
					end
				end
				default:				begin
					trapassert <= `TrapNotAssert;
				end
			endcase
		end
	end

  
	assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) ||
													(aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP))
													&& (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;

  assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) ||
													(aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP))
													&& (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;	

  assign hilo_temp = opdata1_mult * opdata2_mult;																				

	always @ (*) begin
		if(rst == 1'b1) begin
			mulres <= {`ZeroWord,`ZeroWord};
		end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP) ||
									(aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP))begin
			if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin
				mulres <= ~hilo_temp + 1;
			end else begin
			  mulres <= hilo_temp;
			end
		end else begin
				mulres <= hilo_temp;
		end
	end

  //HI/LO相关
	always @ (*) begin
		if(rst == 1'b1) begin
			{HI,LO} <= {`ZeroWord,`ZeroWord};
		end else if(mem_whilo_i == 1'b1) begin
			{HI,LO} <= {mem_hi_i,mem_lo_i};
		end else if(wb_whilo_i == 1'b1) begin
			{HI,LO} <= {wb_hi_i,wb_lo_i};
		end else begin
			{HI,LO} <= {hi_i,lo_i};			
		end
	end	

  always @ (*) begin
    stallreq = stallreq_for_madd_msub || stallreq_for_div;
  end

  //MADD MADDU MSUB MSUBUָ
	always @ (*) begin
		if(rst == 1'b1) begin
			hilo_temp_o <= {`ZeroWord,`ZeroWord};
			cnt_o <= 2'b00;
			stallreq_for_madd_msub <= 1'b0;
		end else begin
			
			case (aluop_i) 
				`EXE_MADD_OP, `EXE_MADDU_OP:		begin
					if(cnt_i == 2'b00) begin
						hilo_temp_o <= mulres;
						cnt_o <= 2'b01;
						stallreq_for_madd_msub <= 1'b1;
						hilo_temp1 <= {`ZeroWord,`ZeroWord};
					end else if(cnt_i == 2'b01) begin
						hilo_temp_o <= {`ZeroWord,`ZeroWord};						
						cnt_o <= 2'b10;
						hilo_temp1 <= hilo_temp_i + {HI,LO};
						stallreq_for_madd_msub <= 1'b0;
					end
					else begin
						hilo_temp_o <= hilo_temp_o;
						cnt_o <= cnt_o;
						stallreq_for_madd_msub <= stallreq_for_madd_msub;
						hilo_temp1 <= hilo_temp1;  
					end
				end
				`EXE_MSUB_OP, `EXE_MSUBU_OP:		begin
					if(cnt_i == 2'b00) begin
						hilo_temp_o <=  ~mulres + 1 ;
						cnt_o <= 2'b01;
						stallreq_for_madd_msub <= 1'b1;
					end else if(cnt_i == 2'b01)begin
						hilo_temp_o <= {`ZeroWord,`ZeroWord};						
						cnt_o <= 2'b10;
						hilo_temp1 <= hilo_temp_i + {HI,LO};
						stallreq_for_madd_msub <= 1'b0;
					end	
					else begin
						hilo_temp_o <= hilo_temp_o;
						cnt_o <= cnt_o;
						stallreq_for_madd_msub <= stallreq_for_madd_msub;
						hilo_temp1 <= hilo_temp1;  
					end			
				end
				default:	begin
					hilo_temp_o <= {`ZeroWord,`ZeroWord};
					cnt_o <= 2'b00;
					stallreq_for_madd_msub <= 1'b0;				
					hilo_temp1 <= hilo_temp1;
				end
			endcase
		end
	end	

  //DIV DIVUָ
	always @ (*) begin
		if(rst == 1'b1) begin
			stallreq_for_div <= 1'b0;
	    div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;
		end else begin
			stallreq_for_div <= 1'b0;
	    div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;	
			case (aluop_i) 
				`EXE_DIV_OP:		begin
					if(div_ready_i == `DivResultNotReady) begin
	    			div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStart;
						signed_div_o <= 1'b1;
						stallreq_for_div <= 1'b1;
					end else if(div_ready_i == `DivResultReady) begin
	    			div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b1;
						stallreq_for_div <= 1'b0;
					end else begin						
	    			div_opdata1_o <= `ZeroWord;
						div_opdata2_o <= `ZeroWord;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= 1'b0;
					end					
				end
				`EXE_DIVU_OP:		begin
					if(div_ready_i == `DivResultNotReady) begin
	    			div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStart;
						signed_div_o <= 1'b0;
						stallreq_for_div <= 1'b1;
					end else if(div_ready_i == `DivResultReady) begin
	    			div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= 1'b0;
					end else begin						
	    			div_opdata1_o <= `ZeroWord;
						div_opdata2_o <= `ZeroWord;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= 1'b0;
					end					
				end
				default: begin
				end
			endcase
		end
	end	

	//MFHI MFLO MOVN MOVZָ
	always @ (*) begin
		if(rst == 1'b1) begin
	  	moveres <= `ZeroWord;
	  end else begin
	   moveres <= `ZeroWord;
	   case (aluop_i)
	   	`EXE_MFHI_OP:		begin
	   		moveres <= HI;
	   	end
	   	`EXE_MFLO_OP:		begin
	   		moveres <= LO;
	   	end
	   	`EXE_MOVZ_OP:		begin
	   		moveres <= reg1_i;
	   	end
	   	`EXE_MOVN_OP:		begin
	   		moveres <= reg1_i;
	   	end
	   	`EXE_MFC0_OP:		begin
	   	  cp0_read_addr_o <= inst_i[15:11];
	   		moveres <= cp0_data_i;
	   		if( mem_cp0_we == 1'b1 &&
	   				  mem_cp0_write_addr == inst_i[15:11] ) begin
	   				moveres <= mem_cp0_data;
	   		end else if( wb_cp0_we == 1'b1 &&
	   				 							 wb_cp0_write_addr == inst_i[15:11] ) begin
	   				moveres <= wb_cp0_data;
	   		end
	   	end	   	
	   	default : begin
	   	end
	   endcase
	  end
	end	 

 always @ (*) begin
	 wd_o <= wd_i;
	 	 	 	
	 if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || 
	      (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
	 	wreg_o <= 1'b0;
	 	ovassert <= 1'b1;
	 end else begin
	  wreg_o <= wreg_i;
	  ovassert <= 1'b0;
	 end
	 
	 case ( alusel_i ) 
	 	`EXE_RES_LOGIC:		begin
	 		wdata_o <= logicout;
	 	end
	 	`EXE_RES_SHIFT:		begin
	 		wdata_o <= shiftres;
	 	end	 	
	 	`EXE_RES_MOVE:		begin
	 		wdata_o <= moveres;
	 	end	 	
	 	`EXE_RES_ARITHMETIC:	begin
	 		wdata_o <= arithmeticres;
	 	end
	 	`EXE_RES_MUL:		begin
	 		wdata_o <= mulres[31:0];
	 	end	 	
	 	`EXE_RES_JUMP_BRANCH:	begin
	 		wdata_o <= link_address_i;
	 	end	 	
	 	default:					begin
	 		wdata_o <= `ZeroWord;
	 	end
	 endcase
 end	

	always @ (*) begin
		if(rst == 1'b1) begin
			whilo_o <= 1'b0;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;		
		end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin
			whilo_o <= 1'b1;
			hi_o <= mulres[63:32];
			lo_o <= mulres[31:0];			
		end else if((aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MADDU_OP)) begin
			whilo_o <= 1'b1;
			hi_o <= hilo_temp1[63:32];
			lo_o <= hilo_temp1[31:0];
		end else if((aluop_i == `EXE_MSUB_OP) || (aluop_i == `EXE_MSUBU_OP)) begin
			whilo_o <= 1'b1;
			hi_o <= hilo_temp1[63:32];
			lo_o <= hilo_temp1[31:0];		
		end else if((aluop_i == `EXE_DIV_OP) || (aluop_i == `EXE_DIVU_OP)) begin
			whilo_o <= 1'b1;
			hi_o <= div_result_i[63:32];
			lo_o <= div_result_i[31:0];							
		end else if(aluop_i == `EXE_MTHI_OP) begin
			whilo_o <= 1'b1;
			hi_o <= reg1_i;
			lo_o <= LO;
		end else if(aluop_i == `EXE_MTLO_OP) begin
			whilo_o <= 1'b1;
			hi_o <= HI;
			lo_o <= reg1_i;
		end else begin
			whilo_o <= 1'b0;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
		end				
	end			

	always @ (*) begin
		if(rst == 1'b1) begin
			cp0_write_addr_o <= 5'b00000;
			cp0_we_o <= 1'b0;
			cp0_data_o <= `ZeroWord;
		end else if(aluop_i == `EXE_MTC0_OP) begin
			cp0_write_addr_o <= inst_i[15:11];
			cp0_we_o <= 1'b1;
			cp0_data_o <= reg1_i;
	  end else begin
			cp0_write_addr_o <= 5'b00000;
			cp0_we_o <= 1'b0;
			cp0_data_o <= `ZeroWord;
		end				
	end		

endmodule