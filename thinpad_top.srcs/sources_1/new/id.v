/*
译码模块
*/
`include "defines.v"

module id(

	input wire	rst,
	input wire[31:0] pc_i,
	input wire[31:0] inst_i,
	// EX阶段数据前推
	input wire[7:0]		  		  ex_aluop_i,

	input wire					  ex_wreg_i,
	input wire[31:0]			  ex_wdata_i,
	input wire[4:0]       		  ex_wd_i,
	
	// MEM阶段数据前推
	input wire					  mem_wreg_i,
	input wire[31:0]			  mem_wdata_i,
	input wire[4:0]       		  mem_wd_i,
	
	input wire[31:0]           	  reg1_data_i,
	input wire[31:0]              reg2_data_i,
	// 是否在delay slot
	input wire                    is_in_delayslot_i,


	output reg                    reg1_read_o,
	output reg                    reg2_read_o,     
	output reg[4:0]               reg1_addr_o,
	output reg[4:0]       		  reg2_addr_o, 	      
	
	output reg[7:0]         	  aluop_o,
	output reg[2:0]        		  alusel_o,
	output reg[31:0]           	  reg1_o,
	output reg[31:0]              reg2_o,
	output reg[4:0]               wd_o,
	output reg                    wreg_o,
	output wire[31:0]             inst_o,

	output reg                    next_inst_in_delayslot_o,
	
	output reg                    branch_flag_o,
	output reg[31:0]           	  branch_target_address_o,       
	output reg[31:0]              link_addr_o,
	output reg                    is_in_delayslot_o,

    output wire[31:0]             except_type_o,
    output wire[31:0]             current_inst_address_o,
	
	output wire                   stallreq	
);

  wire[5:0] op = inst_i[31:26];
  wire[4:0] op2 = inst_i[10:6];
  wire[5:0] op3 = inst_i[5:0];
  wire[4:0] op4 = inst_i[20:16];
  reg[31:0]	imm;
  reg instvalid;
  wire[31:0] pc_plus_8;
  wire[31:0] pc_plus_4;
  wire[31:0] imm_sll2_signedext;  

  reg stallreq_for_reg1_loadrelate;
  reg stallreq_for_reg2_loadrelate;
  wire pre_inst_is_load;
  reg except_type_is_syscall;
  reg except_type_is_eret;
  
  
  assign pc_plus_8 = pc_i + 8;
  assign pc_plus_4 = pc_i +4;
  assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00 };  
  assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
  assign pre_inst_is_load = ((ex_aluop_i == `EXE_LB_OP) || 
  													(ex_aluop_i == `EXE_LBU_OP)||
  													(ex_aluop_i == `EXE_LH_OP) ||
  													(ex_aluop_i == `EXE_LHU_OP)||
  													(ex_aluop_i == `EXE_LW_OP) ||
  													(ex_aluop_i == `EXE_LWR_OP)||
  													(ex_aluop_i == `EXE_LWL_OP)||
  													(ex_aluop_i == `EXE_LL_OP) ||
  													(ex_aluop_i == `EXE_SC_OP)) ? 1'b1 : 1'b0;

  assign inst_o = inst_i;
  assign except_type_o = {19'b0,except_type_is_eret,2'b0, instvalid, except_type_is_syscall,8'b0};
  assign current_inst_address_o = pc_i;
    
	always @ (*) begin	
		if (rst == 1'b1) begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= `NOPRegAddr;
			wreg_o <= 1'b0;
			instvalid <= 1'b0;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= 32'h0;	
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
			next_inst_in_delayslot_o <= `NotInDelaySlot;
			except_type_is_syscall <= `False_v;
			except_type_is_eret <= `False_v;								

	  end else begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[15:11];
			wreg_o <= 1'b0;
			instvalid <= 1'b1;	   
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[25:21];
			reg2_addr_o <= inst_i[20:16];		
			imm <= `ZeroWord;
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;	
			next_inst_in_delayslot_o <= `NotInDelaySlot;
			except_type_is_syscall <= `False_v;	
			except_type_is_eret <= `False_v;					 			
		  case (op)
		    `EXE_SPECIAL_INST:		begin
		    	case (op2)
		    		5'b00000:			begin
		    			case (op3)
		    				`EXE_OR:	begin
		    					wreg_o <= 1'b1;		aluop_o <= `EXE_OR_OP;
		  						alusel_o <= `EXE_RES_LOGIC; 	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
								end  
		    				`EXE_AND:	begin
		    					wreg_o <= 1'b1;		aluop_o <= `EXE_AND_OP;
		  						alusel_o <= `EXE_RES_LOGIC;	  reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= 1'b0;	
								end  	
		    				`EXE_XOR:	begin
		    					wreg_o <= 1'b1;		aluop_o <= `EXE_XOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= 1'b0;	
								end  				
		    				`EXE_NOR:	begin
		    					wreg_o <= 1'b1;		aluop_o <= `EXE_NOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= 1'b0;	
								end 
							`EXE_SLLV: begin
								wreg_o <= 1'b1;		aluop_o <= `EXE_SLL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
								end 
							`EXE_SRLV: begin
								wreg_o <= 1'b1;		aluop_o <= `EXE_SRL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
								end 					
							`EXE_SRAV: begin
								wreg_o <= 1'b1;		aluop_o <= `EXE_SRA_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;			
		  						end
							`EXE_MFHI: begin
								wreg_o <= 1'b1;		aluop_o <= `EXE_MFHI_OP;
		  						alusel_o <= `EXE_RES_MOVE;   reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
		  						instvalid <= 1'b0;	
		  					  	if (inst_i[25:21] != 5'b00000 || inst_i[20:16] != 5'b00000)
                                    instvalid <= 1'b1;
								end
							`EXE_MFLO: begin
								wreg_o <= 1'b1;		aluop_o <= `EXE_MFLO_OP;
		  						alusel_o <= `EXE_RES_MOVE;   reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
		  						instvalid <= 1'b0;	
		  						if (inst_i[25:21] != 5'b00000 || inst_i[20:16] != 5'b00000)
                                    instvalid <= 1'b1;
								end
							`EXE_MTHI: begin
								wreg_o <= 1'b0;		aluop_o <= `EXE_MTHI_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0; instvalid <= 1'b0;	
								if (inst_i[20:16] != 5'b00000 || inst_i[15:11] != 5'b00000)
                                    instvalid <= 1'b1;

							end
							`EXE_MTLO: begin
								wreg_o <= 1'b0;		aluop_o <= `EXE_MTLO_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0; instvalid <= 1'b0;	
								if (inst_i[20:16] != 5'b00000 || inst_i[15:11] != 5'b00000)
                                    instvalid <= 1'b1;
								end
							`EXE_MOVN: begin
								aluop_o <= `EXE_MOVN_OP;
		  						alusel_o <= `EXE_RES_MOVE;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;
							 	if(reg2_o != `ZeroWord) begin
	 								wreg_o <= 1'b1;
	 							end else begin
	 								wreg_o <= 1'b0;
								end
								end
							`EXE_MOVZ: begin
								aluop_o <= `EXE_MOVZ_OP;
		  						alusel_o <= `EXE_RES_MOVE;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;
							 	if(reg2_o == `ZeroWord) begin
	 								wreg_o <= 1'b1;
	 							end else begin
	 								wreg_o <= 1'b0;
								end		  							
								end
							`EXE_SLT: begin
								wreg_o <= 1'b1;		aluop_o <= `EXE_SLT_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
								end
							`EXE_SLTU: begin
								wreg_o <= 1'b1;		aluop_o <= `EXE_SLTU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
								end
							`EXE_SYNC: begin
								wreg_o <= 1'b0;		aluop_o <= `EXE_NOP_OP;
		  						alusel_o <= `EXE_RES_NOP;		reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
								end								
							`EXE_ADD: begin
								wreg_o <= 1'b1;		aluop_o <= `EXE_ADD_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
								end
							`EXE_ADDU: begin
								wreg_o <= 1'b1;		aluop_o <= `EXE_ADDU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
								end
							`EXE_SUB: begin
								wreg_o <= 1'b1;		aluop_o <= `EXE_SUB_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
								end
							`EXE_SUBU: begin
								wreg_o <= 1'b1;		aluop_o <= `EXE_SUBU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= 1'b0;	
								end
							`EXE_MULT: begin
								wreg_o <= 1'b0;		aluop_o <= `EXE_MULT_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= 1'b0;	
								if (inst_i[15:11] != 5'b00000)
                                    instvalid <= 1'b1;
								end
							`EXE_MULTU: begin
								wreg_o <= 1'b0;		aluop_o <= `EXE_MULTU_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= 1'b0;	
								if (inst_i[15:11] != 5'b00000)
						        	instvalid <= 1'b1;
								end
							`EXE_DIV: begin
								wreg_o <= 1'b0;		aluop_o <= `EXE_DIV_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= 1'b0;	
								if (inst_i[15:11] != 5'b00000)
                                    instvalid <= 1'b1;
								end
							`EXE_DIVU: begin
								wreg_o <= 1'b0;		aluop_o <= `EXE_DIVU_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= 1'b0;	
								if (inst_i[15:11] != 5'b00000)
                                    instvalid <= 1'b1;
								end			
							`EXE_JR: begin
								wreg_o <= 1'b0;		aluop_o <= `EXE_JR_OP;
		  						alusel_o <= `EXE_RES_JUMP_BRANCH;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  						link_addr_o <= `ZeroWord; 	
			            		branch_target_address_o <= reg1_o;
			            		branch_flag_o <= `Branch;
			           
			            		next_inst_in_delayslot_o <= `InDelaySlot;
			            		instvalid <= 1'b0;
			             		if (inst_i[20:16] != 5'b00000 || inst_i[15:11] != 5'b00000)
                                	instvalid <= 1'b1;
	
								end
							`EXE_JALR: begin
								wreg_o <= 1'b1;		aluop_o <= `EXE_JALR_OP;
		  						alusel_o <= `EXE_RES_JUMP_BRANCH;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  						wd_o <= inst_i[15:11];
		  						link_addr_o <= pc_plus_8;   
			            		branch_target_address_o <= reg1_o;
			            		branch_flag_o <= `Branch;
			           
			            		next_inst_in_delayslot_o <= `InDelaySlot;
			            		instvalid <= 1'b0;	
			             		if (inst_i[20:16] != 5'b00000)
                        			instvalid <= 1'b1;

								end													 											  											
						    default:	begin
						    end
						  endcase
						 end
						default: begin
						end
					endcase	
          case (op3)
                                `EXE_BREAK: begin
                                    wreg_o <= 1'b0;        aluop_o <= `EXE_TEQ_OP;
                                    alusel_o <= `EXE_RES_NOP;   reg1_read_o <= 1'b0;    reg2_read_o <= 1'b0;
                                    instvalid <= 1'b0;
                                    end
								`EXE_TEQ: begin
									wreg_o <= 1'b0;		aluop_o <= `EXE_TEQ_OP;
		  							alusel_o <= `EXE_RES_NOP;   reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
		  							instvalid <= 1'b0;
		  							end
		  						`EXE_TGE: begin
									wreg_o <= 1'b0;		aluop_o <= `EXE_TGE_OP;
		  							alusel_o <= `EXE_RES_NOP;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  							instvalid <= 1'b0;
		  						end		
		  						`EXE_TGEU: begin
									wreg_o <= 1'b0;		aluop_o <= `EXE_TGEU_OP;
		  							alusel_o <= `EXE_RES_NOP;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  							instvalid <= 1'b0;
		  						end	
		  						`EXE_TLT: begin
									wreg_o <= 1'b0;		aluop_o <= `EXE_TLT_OP;
		  							alusel_o <= `EXE_RES_NOP;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  							instvalid <= 1'b0;
		  						end
		  						`EXE_TLTU: begin
									wreg_o <= 1'b0;		aluop_o <= `EXE_TLTU_OP;
		  							alusel_o <= `EXE_RES_NOP;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  							instvalid <= 1'b0;
		  						end	
		  						`EXE_TNE: begin
									wreg_o <= 1'b0;		aluop_o <= `EXE_TNE_OP;
		  							alusel_o <= `EXE_RES_NOP;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  							instvalid <= 1'b0;
		  						end
		  						`EXE_SYSCALL: begin
									wreg_o <= 1'b0;		aluop_o <= `EXE_SYSCALL_OP;
		  							alusel_o <= `EXE_RES_NOP;   reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
		  							instvalid <= 1'b0; except_type_is_syscall<= `True_v;
		  						end							 																					
								default:	begin
								end	
					 endcase									
					end									  
		  	`EXE_ORI: begin                        //ORIָ
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_OR_OP;
		  		alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];
				instvalid <= 1'b0;	
		  	end
		  	`EXE_ANDI:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_AND_OP;
		  		alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end	 	
		  	`EXE_XORI:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_XOR_OP;
		  		alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end	 		
		  	`EXE_LUI:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_OR_OP;
		  		alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				imm <= {inst_i[15:0], 16'h0};		wd_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
				if(inst_i[25:21] != 5'b00000) instvalid <= 1'b1;
			end			
			`EXE_SLTI:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_SLT_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end
			`EXE_SLTIU:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_SLTU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end
			`EXE_PREF:			begin
		  		wreg_o <= 1'b0;		aluop_o <= `EXE_NOP_OP;
		  		alusel_o <= `EXE_RES_NOP; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;	  	  	
				instvalid <= 1'b0;	
			end						
			`EXE_ADDI:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_ADDI_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end
			`EXE_ADDIU:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_ADDIU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
				instvalid <= 1'b0;	
			end
			`EXE_J:			begin
		  		wreg_o <= 1'b0;		aluop_o <= `EXE_J_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
		  		link_addr_o <= `ZeroWord;
			    branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
			    branch_flag_o <= `Branch;
			    next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    instvalid <= 1'b0;	
			end
			`EXE_JAL:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_JAL_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
		  		wd_o <= 5'b11111;	
		  		link_addr_o <= pc_plus_8 ;
			    branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
			    branch_flag_o <= `Branch;
			    next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    instvalid <= 1'b0;	
			end
			`EXE_BEQ:			begin
		  		wreg_o <= 1'b0;		aluop_o <= `EXE_BEQ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  		instvalid <= 1'b0;	
	  			next_inst_in_delayslot_o <= `InDelaySlot;		  	

		  		if(reg1_o == reg2_o) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;  
			    	branch_flag_o <= `Branch;
			    end
			end
			`EXE_BGTZ:			begin
		  		wreg_o <= 1'b0;		aluop_o <= `EXE_BGTZ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  		instvalid <= 1'b0;
	  		    if (inst_i[20:16] != 5'b00000)
                	instvalid <= 1'b1;
	
		    	next_inst_in_delayslot_o <= `InDelaySlot;		  	

		  		if((reg1_o[31] == 1'b0) && (reg1_o != `ZeroWord)) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= `Branch;
			    end
				end
			`EXE_BLEZ:			begin
		  		wreg_o <= 1'b0;		aluop_o <= `EXE_BLEZ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
				next_inst_in_delayslot_o <= `InDelaySlot;		  	

		  		instvalid <= 1'b0;	
		  		  if (inst_i[20:16] != 5'b00000)
                instvalid <= 1'b1;

		  		if((reg1_o[31] == 1'b1) || (reg1_o == `ZeroWord)) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;  
			    	branch_flag_o <= `Branch;
			    end
			end
			`EXE_BNE:			begin
		  		wreg_o <= 1'b0;		aluop_o <= `EXE_BLEZ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  		instvalid <= 1'b0;	
		    	next_inst_in_delayslot_o <= `InDelaySlot;		  	

		  		if(reg1_o != reg2_o) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= `Branch;
			    end
			end
			`EXE_LB:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_LB_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				wd_o <= inst_i[20:16]; instvalid <= 1'b0;	
			end
			`EXE_LBU:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_LBU_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				wd_o <= inst_i[20:16]; instvalid <= 1'b0;	
			end
			`EXE_LH:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_LH_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				wd_o <= inst_i[20:16]; instvalid <= 1'b0;	
			end
			`EXE_LHU:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_LHU_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				wd_o <= inst_i[20:16]; instvalid <= 1'b0;	
			end
			`EXE_LW:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_LW_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				wd_o <= inst_i[20:16]; instvalid <= 1'b0;	
			end
			`EXE_LL:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_LL_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
				wd_o <= inst_i[20:16]; instvalid <= 1'b0;	
			end
			`EXE_LWL:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_LWL_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  	
				wd_o <= inst_i[20:16]; instvalid <= 1'b0;	
			end
			`EXE_LWR:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_LWR_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  	
				wd_o <= inst_i[20:16]; instvalid <= 1'b0;	
			end			
			`EXE_SB:			begin
		  		wreg_o <= 1'b0;		aluop_o <= `EXE_SB_OP;
		  		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= 1'b0;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			`EXE_SH:			begin
		  		wreg_o <= 1'b0;		aluop_o <= `EXE_SH_OP;
		  		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= 1'b0;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			`EXE_SW:			begin
		  		wreg_o <= 1'b0;		aluop_o <= `EXE_SW_OP;
		  		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= 1'b0;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			`EXE_SWL:			begin
		  		wreg_o <= 1'b0;		aluop_o <= `EXE_SWL_OP;
		  		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= 1'b0;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			`EXE_SWR:			begin
		  		wreg_o <= 1'b0;		aluop_o <= `EXE_SWR_OP;
		  		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= 1'b0;	
		  		alusel_o <= `EXE_RES_LOAD_STORE; 
			end
			`EXE_SC:			begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_SC_OP;
		  		alusel_o <= `EXE_RES_LOAD_STORE; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  	
				wd_o <= inst_i[20:16]; instvalid <= 1'b0;	
				alusel_o <= `EXE_RES_LOAD_STORE; 
			end								
			`EXE_REGIMM_INST:		begin
				case (op4)
					`EXE_BGEZ:	begin
						wreg_o <= 1'b0;		aluop_o <= `EXE_BGEZ_OP;
		  				alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  				instvalid <= 1'b0;	
				    	next_inst_in_delayslot_o <= `InDelaySlot;		  	

		  				if(reg1_o[31] == 1'b0) begin
			    			branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    			branch_flag_o <= `Branch;
			   			end
						end
					`EXE_BGEZAL:		begin
						wreg_o <= 1'b1;		aluop_o <= `EXE_BGEZAL_OP;
		  				alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  				link_addr_o <= pc_plus_8; 
		  				wd_o <= 5'b11111;  	instvalid <= 1'b0;
			    		next_inst_in_delayslot_o <= `InDelaySlot;		  	

		  				if(reg1_o[31] == 1'b0) begin
			    			branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    			branch_flag_o <= `Branch;
			   			end
						end
					`EXE_BLTZ:		begin
						wreg_o <= 1'b0;		aluop_o <= `EXE_BGEZAL_OP;
		  				alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  				instvalid <= 1'b0;	
			    		next_inst_in_delayslot_o <= `InDelaySlot;		  	

		  				if(reg1_o[31] == 1'b1) begin
			    			branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;     
			    			branch_flag_o <= `Branch;
			   			end
						end
					`EXE_BLTZAL:		begin
						wreg_o <= 1'b1;		aluop_o <= `EXE_BGEZAL_OP;
		  				alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  				link_addr_o <= pc_plus_8;	
		  				wd_o <= 5'b11111; instvalid <= 1'b0;
			    		next_inst_in_delayslot_o <= `InDelaySlot;		  	

		  				if(reg1_o[31] == 1'b1) begin
			    			branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    			branch_flag_o <= `Branch;
			   			end
						end
					`EXE_TEQI:			begin
		  				wreg_o <= 1'b0;		aluop_o <= `EXE_TEQI_OP;
		  				alusel_o <= `EXE_RES_NOP; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
						imm <= {{16{inst_i[15]}}, inst_i[15:0]};		  	
						instvalid <= 1'b0;	
					end
					`EXE_TGEI:			begin
		  				wreg_o <= 1'b0;		aluop_o <= `EXE_TGEI_OP;
		  				alusel_o <= `EXE_RES_NOP; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
						imm <= {{16{inst_i[15]}}, inst_i[15:0]};		  	
						instvalid <= 1'b0;	
						end
					`EXE_TGEIU:			begin
		  				wreg_o <= 1'b0;		aluop_o <= `EXE_TGEIU_OP;
		  				alusel_o <= `EXE_RES_NOP; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
						imm <= {{16{inst_i[15]}}, inst_i[15:0]};		  	
						instvalid <= 1'b0;	
					end
					`EXE_TLTI:			begin
		  				wreg_o <= 1'b0;		aluop_o <= `EXE_TLTI_OP;
		  				alusel_o <= `EXE_RES_NOP; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
						imm <= {{16{inst_i[15]}}, inst_i[15:0]};		  	
						instvalid <= 1'b0;	
					end
					`EXE_TLTIU:			begin
		  				wreg_o <= 1'b0;		aluop_o <= `EXE_TLTIU_OP;
		  				alusel_o <= `EXE_RES_NOP; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
						imm <= {{16{inst_i[15]}}, inst_i[15:0]};		  	
						instvalid <= 1'b0;	
					end
					`EXE_TNEI:			begin
		  				wreg_o <= 1'b0;		aluop_o <= `EXE_TNEI_OP;
		  				alusel_o <= `EXE_RES_NOP; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
						imm <= {{16{inst_i[15]}}, inst_i[15:0]};		  	
						instvalid <= 1'b0;	
					end						
					default:	begin
						end
					endcase
				end								
				`EXE_SPECIAL2_INST:		begin
					case ( op3 )
						`EXE_CLZ:		begin
							wreg_o <= 1'b1;		aluop_o <= `EXE_CLZ_OP;
		  				alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
							instvalid <= 1'b0;	
							 if (op2 != 5'b00000)
                           instvalid <= 1'b1;

						end
						`EXE_CLO:		begin
							wreg_o <= 1'b1;		aluop_o <= `EXE_CLO_OP;
		  				alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
							instvalid <= 1'b0;	
						 if (op2 != 5'b00000)
                                                      instvalid <= 1'b1;

						end
						`EXE_MUL:		begin
							wreg_o <= 1'b1;		aluop_o <= `EXE_MUL_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  				
		  				instvalid <= 1'b0;	  			
						 if (op2 != 5'b00000)
                                                    instvalid <= 1'b1;

						end
						`EXE_MADD:		begin
							wreg_o <= 1'b0;		aluop_o <= `EXE_MADD_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  			
		  				instvalid <= 1'b0;	
						 if (inst_i[15:11] != 5'b00000 || op2 != 5'b00000)
                        instvalid <= 1'b1;

						end
						`EXE_MADDU:		begin
							wreg_o <= 1'b0;		aluop_o <= `EXE_MADDU_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  			
		  				instvalid <= 1'b0;	
						 if (inst_i[15:11] != 5'b00000 || op2 != 5'b00000)
                        instvalid <= 1'b1;

						end
						`EXE_MSUB:		begin
							wreg_o <= 1'b0;		aluop_o <= `EXE_MSUB_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  			
		  				instvalid <= 1'b0;	
						 if (inst_i[15:11] != 5'b00000 || op2 != 5'b00000)
                                                 instvalid <= 1'b1;

						end
						`EXE_MSUBU:		begin
							wreg_o <= 1'b0;		aluop_o <= `EXE_MSUBU_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  			
		  				instvalid <= 1'b0;	
						 if (inst_i[15:11] != 5'b00000 || op2 != 5'b00000)
                                                                          instvalid <= 1'b1;

						end						
						default:	begin
						end
					endcase      //EXE_SPECIAL_INST2 case
				end																		  	
		    default:			begin
		    end
		  endcase		  //case op
		  
		  if (inst_i[31:21] == 11'b00000000000) begin
		  	if (op3 == `EXE_SLL) begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_SLL_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= 1'b0;	
				end else if ( op3 == `EXE_SRL ) begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_SRL_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= 1'b0;	
				end else if ( op3 == `EXE_SRA ) begin
		  		wreg_o <= 1'b1;		aluop_o <= `EXE_SRA_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= 1'b0;	
				end
			end		  

     	if(inst_i == `EXE_ERET) begin
				wreg_o <= 1'b0;		aluop_o <= `EXE_ERET_OP;
		  	alusel_o <= `EXE_RES_NOP;   reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
		  	instvalid <= 1'b0; except_type_is_eret<= `True_v;				
			end else if(inst_i[31:21] == 11'b01000000000 && 
										inst_i[10:3] == 11'b00000000) begin
				aluop_o <= `EXE_MFC0_OP;
				alusel_o <= `EXE_RES_MOVE;
				wd_o <= inst_i[20:16];
				wreg_o <= 1'b1;
				instvalid <= 1'b0;	   
				reg1_read_o <= 1'b0;
				reg2_read_o <= 1'b0;		
			end else if(inst_i[31:21] == 11'b01000000100 && 
										inst_i[10:3] == 8'b00000000) begin
				aluop_o <= `EXE_MTC0_OP;
				alusel_o <= `EXE_RES_NOP;
				wreg_o <= 1'b0;
				instvalid <= 1'b0;	   
				reg1_read_o <= 1'b1;
				reg1_addr_o <= inst_i[20:16];
				reg2_read_o <= 1'b0;					
			end
		  
		end       //if
	end         //always
	

	always @ (*) begin
			stallreq_for_reg1_loadrelate <= 1'b0;	
		if(rst == 1'b1) begin
			reg1_o <= `ZeroWord;	
		end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o 
								&& reg1_read_o == 1'b1 ) begin
		  stallreq_for_reg1_loadrelate <= 1'b1;
		  reg1_o <= reg1_o;							
		end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg1_addr_o)) begin
			reg1_o <= ex_wdata_i; 
		end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg1_addr_o)) begin
			reg1_o <= mem_wdata_i; 			
	  end else if(reg1_read_o == 1'b1) begin
	  	reg1_o <= reg1_data_i;
	  end else if(reg1_read_o == 1'b0) begin
	  	reg1_o <= imm;
	  end else begin
	    reg1_o <= `ZeroWord;
	  end
	end
	
	always @ (*) begin
			stallreq_for_reg2_loadrelate <= 1'b0;
		if(rst == 1'b1) begin
			reg2_o <= `ZeroWord;
		end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o 
								&& reg2_read_o == 1'b1 ) begin
		  stallreq_for_reg2_loadrelate <= 1'b1;
		  reg2_o <= reg2_o;			
		end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg2_addr_o)) begin
			reg2_o <= ex_wdata_i; 
		end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg2_addr_o)) begin
			reg2_o <= mem_wdata_i;			
	  end else if(reg2_read_o == 1'b1) begin
	  	reg2_o <= reg2_data_i;
	  end else if(reg2_read_o == 1'b0) begin
	  	reg2_o <= imm;
	  end else begin
	    reg2_o <= `ZeroWord;
	  end
	end

	always @ (*) begin
		if(rst == 1'b1) begin
			is_in_delayslot_o <= `NotInDelaySlot;
		end else begin
		  is_in_delayslot_o <= is_in_delayslot_i;		
	  end
	end

endmodule