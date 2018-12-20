`include "defines.v"

module mem(

	input wire	rst,
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,
	input wire[31:0]					  wdata_i,
	input wire[31:0]           hi_i,
	input wire[31:0]           lo_i,
	input wire                    whilo_i,	

  input wire[`AluOpBus]        aluop_i,
	input wire[31:0]          mem_addr_i,
	input wire[31:0]          reg2_i,
	
	//memory
	input wire[31:0]          mem_data_i,

	//LLbitֵ
	input wire                  LLbit_i,
	input wire                  wb_LLbit_we_i,
	input wire                  wb_LLbit_value_i,

	//cp0
	input wire                   cp0_we_i,
	input wire[4:0]              cp0_write_addr_i,
	input wire[31:0]          cp0_data_i,
	
	input wire[31:0]             except_type_i,
	input wire                   is_in_delayslot_i,
	input wire[31:0]          current_inst_address_i,	
	input wire[31:0]          cp0_status_i,
	input wire[31:0]          cp0_cause_i,
	input wire[31:0]          cp0_epc_i,

    input wire                    wb_cp0_we,
	input wire[4:0]               wb_cp0_write_addr,
	input wire[31:0]           wb_cp0_data,
	
	output reg[`RegAddrBus]      wd_o,
	output reg                   wreg_o,
	output reg[31:0]					 wdata_o,
	output reg[31:0]          hi_o,
	output reg[31:0]          lo_o,
	output reg                   whilo_o,

	output reg                   LLbit_we_o,
	output reg                   LLbit_value_o,

	output reg                   cp0_we_o,
	output reg[4:0]              cp0_write_addr_o,
	output reg[31:0]          cp0_data_o,
	
	//memory输出
	output reg[31:0]          mem_addr_o,
	output wire									 mem_we_o,
	output reg[3:0]              mem_sel_o,
	output reg[31:0]          mem_data_o,
	output reg                   mem_ce_o,
	
	output reg[31:0]             except_type_o,
	output wire[31:0]          cp0_epc_o,
	output wire                  is_in_delayslot_o,
	
	output wire[31:0]         current_inst_address_o		
	
);

  reg LLbit;
	wire[31:0] zero32;
	reg[31:0]          cp0_status;
	reg[31:0]          cp0_cause;
	reg[31:0]          cp0_epc;	
	reg                   mem_we;
	reg                    if_serr;
	reg                    if_lerr;
	reg                    if_eret_wrong;

	assign mem_we_o = mem_we & (~(|except_type_o));
	assign zero32 = `ZeroWord;

	assign is_in_delayslot_o = is_in_delayslot_i;
	assign current_inst_address_o = current_inst_address_i;
	assign cp0_epc_o = cp0_epc;
	
	// LLBIT
	always @ (*) begin
		if(rst == 1'b1) begin
			LLbit <= 1'b0;
		end else begin
			if(wb_LLbit_we_i == 1'b1) begin
				LLbit <= wb_LLbit_value_i;
			end else begin
				LLbit <= LLbit_i;
			end
		end
	end
	
	always @ (*) begin
		if(rst == 1'b1) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= 1'b0;
		  wdata_o <= `ZeroWord;
		  hi_o <= `ZeroWord;
		  lo_o <= `ZeroWord;
		  whilo_o <= 1'b0;		
		  mem_addr_o <= `ZeroWord;
		  mem_we <= 1'b0;
		  mem_sel_o <= 4'b0000;
		  mem_data_o <= `ZeroWord;		
		  mem_ce_o <= `ChipDisable;
		  LLbit_we_o <= 1'b0;
		  LLbit_value_o <= 1'b0;		
		  cp0_we_o <= 1'b0;
		  cp0_write_addr_o <= 5'b00000;
		  cp0_data_o <= `ZeroWord;		 
		  cp0_epc <= `ZeroWord;
           if_eret_wrong<= 1'b0;         
		end else begin
		  wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
			hi_o <= hi_i;
			lo_o <= lo_i;
			whilo_o <= whilo_i;		
			mem_we <= 1'b0;
			mem_addr_o <= `ZeroWord;
			mem_data_o <= `ZeroWord;
			mem_sel_o <= 4'b1111;
			mem_ce_o <= `ChipDisable;
		  LLbit_we_o <= 1'b0;
		  LLbit_value_o <= 1'b0;		
		  cp0_we_o <= cp0_we_i;
		  cp0_write_addr_o <= cp0_write_addr_i;
		  cp0_data_o <= cp0_data_i;		
		  if_serr<=1'b0;
		  if_lerr<=1'b0; 		
		  if_eret_wrong<= 1'b0;  	
			case (aluop_i)
				`EXE_LB_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= 1'b0;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
						wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
                                                    mem_sel_o <= 4'b0001;
							
						end
						2'b01:	begin
							
							wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
                                                        mem_sel_o <= 4'b0010;
						end
						2'b10:	begin
							wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
                                                    mem_sel_o <= 4'b0100;
						end
						2'b11:	begin
							wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
                                                    mem_sel_o <= 4'b1000;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase
				end
				`EXE_LBU_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= 1'b0;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[7:0]};
                                                    mem_sel_o <= 4'b0001;
						end
						2'b01:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[15:8]};
                                                    mem_sel_o <= 4'b0010;
						end
						2'b10:	begin
							
							wdata_o <= {{24{1'b0}},mem_data_i[23:16]};
                                                        mem_sel_o <= 4'b0100;
						end
						2'b11:	begin
							
							wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
                                                        mem_sel_o <= 4'b1000;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase				
				end
				`EXE_LH_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= 1'b0;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{16{mem_data_i[15]}},mem_data_i[15:0]};
                                                    mem_sel_o <= 4'b0011;
						end
						2'b10:	begin
							
							wdata_o <= {{16{mem_data_i[31]}},mem_data_i[31:16]};
                                                        mem_sel_o <= 4'b1100;
						end
						default:	begin
							wdata_o <= `ZeroWord;
//							except_type_o <= 32'h00000009;        //fail load h
                            if_lerr <= 1'b1;
							  cp0_write_addr_o <= 5'b01000;
                              cp0_data_o <= mem_addr_i;
                              		  cp0_we_o <= 1'b1;
        
                              

						end
					endcase					
				end
				`EXE_LHU_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= 1'b0;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{16{1'b0}},mem_data_i[15:0]};
                                                    mem_sel_o <= 4'b0011;
						end
						2'b10:	begin
							
							wdata_o <= {{16{1'b0}},mem_data_i[31:16]};
                                                        mem_sel_o <= 4'b1100;
						end
						default:	begin
							wdata_o <= `ZeroWord;
//							except_type_o <= 32'h00000009;        //fail load h
                            if_lerr <= 1'b1;
							  cp0_write_addr_o <= 5'b01000;
							  cp0_we_o <= 1'b1;
                            cp0_data_o <= mem_addr_i; 
						end
					endcase				
				end
				`EXE_LW_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= 1'b0;
					mem_ce_o <= `ChipEnable;

					case (mem_addr_i[1:0])
                                            2'b00:    begin
                                            wdata_o <= mem_data_i;
                                            mem_sel_o <= 4'b1111;    
                                            end
                                            default:    begin
                                                wdata_o <= `ZeroWord;
                                                if_lerr <= 1'b1;
//                                                except_type_o <= 32'h00000009;        //fail load w
                                                							  cp0_write_addr_o <= 5'b01000;
                                                cp0_data_o <= mem_addr_i;
                                                cp0_we_o <= 1'b1; 
                                            end
                                        endcase                
				end
				
				`EXE_SB_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= 1'b1;
					mem_data_o <= {reg2_i[7:0],reg2_i[7:0],reg2_i[7:0],reg2_i[7:0]};
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
													mem_sel_o <= 4'b0001;	

						end
						2'b01:	begin
													mem_sel_o <= 4'b0010;

						end
						2'b10:	begin
														mem_sel_o <= 4'b0100;

						end
						2'b11:	begin
														mem_sel_o <= 4'b1000;

						end
						default:	begin
							mem_sel_o <= 4'b0000;
						end
					endcase				
				end
				`EXE_SH_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= 1'b1;
					mem_data_o <= {reg2_i[15:0],reg2_i[15:0]};
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
													mem_sel_o <= 4'b0011;

						end
						2'b10:	begin
														mem_sel_o <= 4'b1100;

						end
						default:	begin
                            if_serr <= 1'b1;
							mem_sel_o <= 4'b0000;
//							except_type_o <= 32'h0000000f; 
														  cp0_write_addr_o <= 5'b01000;
                            cp0_data_o <= mem_addr_i; 
                            cp0_we_o <= 1'b1;
//                            mem_we <= 1'b1;
                            mem_ce_o <= `ChipDisable;
						end
					endcase						
				end
				`EXE_SW_OP:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= 1'b1;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
                                       2'b00:    begin
					                       mem_data_o <= reg2_i;
					                       mem_sel_o <= 4'b1111;			
					                   end
					                   default: begin
					                       mem_sel_o <= 4'b0000;
//                                            except_type_i[13]<=1'b1;
//                                           except_type_o <= 32'h0000000f; 
                                            if_serr <= 1'b1;
                                           	cp0_write_addr_o <= 5'b01000;
                                           cp0_data_o <= mem_addr_i; 
                                           cp0_we_o <= 1'b1;
//                                             mem_we <= 1'b1;
                                             mem_ce_o <= `ChipDisable;
                                       end
                                    endcase         
				end
				
				default:		begin
          //ʲôҲ����
				end
			endcase			
			
			if((wb_cp0_we == 1'b1) && 
                                            (wb_cp0_write_addr == `cp0_EPC ))begin
                        if_eret_wrong<= 1'b0;      
            
                        if(except_type_i[12] == 1'b1 &&  wb_cp0_data[1:0] != 2'b00) begin if_eret_wrong <= 1'b1; cp0_write_addr_o <= 5'b01000;
                                                                         cp0_data_o <= wb_cp0_data;
                                                                                   cp0_we_o <= 1'b1; end
                        else begin cp0_epc <= wb_cp0_data; end
                    end else begin
                    if_eret_wrong<= 1'b0;      
                    if(except_type_i[12] == 1'b1 && cp0_epc_i[1:0] != 2'b00) begin if_eret_wrong <= 1'b1; cp0_write_addr_o <= 5'b01000;
                                                 cp0_data_o <= cp0_epc_i;
                                                           cp0_we_o <= 1'b1; end
                      else begin cp0_epc <= cp0_epc_i; end
                    end
			
							
		end    //if
	end      //always

	always @ (*) begin
		if(rst == 1'b1) begin
			cp0_status <= `ZeroWord;
		end else if((wb_cp0_we == 1'b1) && 
								(wb_cp0_write_addr == `cp0_STATUS ))begin
			cp0_status <= wb_cp0_data;
		end else begin
		  cp0_status <= cp0_status_i;
		end
	end
	

  always @ (*) begin
		if(rst == 1'b1) begin
			cp0_cause <= `ZeroWord;
		end else if((wb_cp0_we == 1'b1) && 
								(wb_cp0_write_addr == `cp0_CAUSE ))begin
			cp0_cause[9:8] <= wb_cp0_data[9:8];
			cp0_cause[22] <= wb_cp0_data[22];
			cp0_cause[23] <= wb_cp0_data[23];
		end else begin
		  cp0_cause <= cp0_cause_i;
		end
	end

	always @ (*) begin
		if(rst == 1'b1) begin
			except_type_o <= `ZeroWord;
		end else begin
//		    if(except_type_o[6:2] != 
			except_type_o <= `ZeroWord;
			
			if(current_inst_address_i != `ZeroWord) begin
				if(((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00) && (cp0_status[1] == 1'b0) && 
							(cp0_status[0] == 1'b1)) begin
					except_type_o <= 32'h00000001;        //interrupt
				end else if(except_type_i[8] == 1'b1) begin
			  	except_type_o <= 32'h00000008;        //syscall
				end else if(except_type_i[9] == 1'b1) begin
					except_type_o <= 32'h0000000a;        //inst_invalid
				end else if(except_type_i[10] ==1'b1) begin
					except_type_o <= 32'h0000000d;        //trap
				end else if(except_type_i[11] == 1'b1) begin  //ov
					except_type_o <= 32'h0000000c;
				end else if(if_eret_wrong == 1'b1) begin
                                        except_type_o <= 32'h00000009;
				end else if(except_type_i[12] == 1'b1) begin  
					except_type_o <= 32'h0000000e;
				end else if(except_type_i[13] == 1'b1) begin
				    except_type_o <= 32'h00000009;
				end else if(if_serr == 1'b1) begin
				    except_type_o <= 32'h0000000f;
				end else if(if_lerr == 1'b1) begin
				    except_type_o <= 32'h00000009;
				end
			end
				
		end
	end			
	

endmodule