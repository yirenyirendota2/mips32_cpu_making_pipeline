

`include "defines.v"

module ctrl(

	input wire										rst,

	input wire[31:0]             excepttype_i,
	input wire[`RegBus]          cp0_epc_i,

	input wire                   stallreq_from_id,
	input wire[31:0]               ebase_i,

  //����ִ�н׶ε���ͣ����
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
		end else if(excepttype_i != `ZeroWord) begin
		  flush <= 1'b1;
		  stall <= 6'b000000;
			case (excepttype_i)
				32'h00000001:		begin   //interrupt
					new_pc <= ebase_i + 32'h80000180;
//					new_pc <= 32'h00000020;
//					new_pc <= 32'h80000000 + 32'h00000200;
				end
				32'h00000008:		begin   //syscall
//					new_pc <= 32'h80000000 + 32'h00000200;
					//new_pc <= 32'h00000040;
//					 new_pc <= 32'h00000040;
new_pc <= ebase_i+ 32'h80000180;
				end
				32'h0000000a:		begin   //inst_invalid
//					new_pc <= 32'h00000040;
//					new_pc <= 32'h80000000 + 32'h00000200;
new_pc <= ebase_i+ 32'h80000180;
				end
				32'h0000000d:		begin   //trap
//					new_pc <= 32'h00000040;
//					new_pc <= 32'h80000000 + 32'h00000180;
new_pc <= ebase_i+ 32'h80000180;
				end
								32'h0000000f:		begin   //trap
//                    new_pc <= 32'h00000040;
//                    new_pc <= 32'h80000000 + 32'h00000180;
new_pc <= ebase_i+ 32'h80000180;
                end
                				32'h00000009:		begin   //trap
//                    new_pc <= 32'h00000040;
//                    new_pc <= 32'h80000000 + 32'h00000180;
new_pc <= ebase_i+ 32'h80000180;
                end
				32'h0000000c:		begin   //ov
//					new_pc <= 32'h00000040;
//					new_pc <= 32'h80000000 + 32'h00000200;
new_pc <= ebase_i+ 32'h80000180;
				end
				32'h0000000e:		begin   //eret
				    
					   new_pc <= cp0_epc_i;
					
//					new_pc <= 32'h80000000 + 32'h00000200;
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
		end else if(stallreq_from_if == `Stop) begin
		  	stall <= 6'b000111;	
			flush <= 1'b0;
		end else begin
			stall <= 6'b000000;
			flush <= 1'b0;
			new_pc <= `ZeroWord;		
		end    //if
	end      //always
			

endmodule