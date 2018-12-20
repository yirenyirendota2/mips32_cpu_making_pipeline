`include "defines.v"

module ctrl(

	input wire					rst,

	input wire[31:0]             except_type_i,
	input wire[`RegBus]          cp0_epc_i,

	input wire                   stallreq_from_id,
	input wire[31:0]               ebase_i,

  //输入的暂停信号
	input wire                   stallreq_from_ex,
	input wire					 stallreq_from_if,   // 取指令阶段的暂停

	output reg[`RegBus]          new_pc,
	output reg                   flush,	
	output reg[5:0]              stall       
	
);


	always @ (*) begin
		if(rst == `RstEnable) begin
			stall <= 6'b000000;
			flush <= 1'b0;
			new_pc <= `ZeroWord;
		end else if(except_type_i != `ZeroWord) begin
		  flush <= 1'b1;
		  stall <= 6'b000000;
			case (except_type_i)
				32'h00000001:		begin   //interrupt
					new_pc <= ebase_i + 32'h80000180;
				end
				32'h00000008:		begin   //syscall	
					new_pc <= ebase_i+ 32'h80000180;
				end
				32'h0000000a:		begin   
					new_pc <= ebase_i+ 32'h80000180;
				end
				32'h0000000d:		begin   //trap
					new_pc <= ebase_i+ 32'h80000180;
				end
				32'h0000000f:		begin   //trap
					new_pc <= ebase_i+ 32'h80000180;
                end
            	32'h00000009:		begin   //trap
					new_pc <= ebase_i+ 32'h80000180;
                end
				32'h0000000c:		begin   //ov
					new_pc <= ebase_i+ 32'h80000180;
				end
				32'h0000000e:		begin   //eret
				    
					   new_pc <= cp0_epc_i;
				end
				default	: begin
				end
			endcase 						
		end else if(stallreq_from_ex == `Stop) begin
			stall <= 6'b001111;
			flush <= 1'b0;		
		end else if(stallreq_from_id == `Stop) begin
			stall <= 6'b000111;	
			flush <= 1'b0;		
		end else if(stallreq_from_if == `Stop) begin    // 处理取指令阶段的结构冲突
		  	stall <= 6'b000111;	
			flush <= 1'b0;
		end else begin
			stall <= 6'b000000;
			flush <= 1'b0;
			new_pc <= `ZeroWord;		
		end    //if
	end      //always
			

endmodule