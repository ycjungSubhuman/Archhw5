`timescale 1 ns / 100 ps

`include "opcodes.v"

module uProgramRom (state, inst,
	ALUSrcA, IorD, IRWrite, PCWrite, PCWriteCond, ALUSrcB, PCSource, 
	RegDest, RegWrite, MemRead, MemWrite, RegWriteSrc, BranchProperty, OutputPortWrite,
	IsHalted, IsLHI, ALUOp, nextstate);
	
	input [4:0] state;
	input [`WORD_SIZE-1:0] inst;
	output reg ALUSrcA;
	output reg IorD;
	output reg IRWrite;
	output reg PCWrite;
	output reg PCWriteCond;
	output reg [2:0] ALUSrcB;
	output reg [1:0] PCSource;
	output reg [1:0] RegDest;
	output reg RegWrite;
	output reg MemRead;
	output reg MemWrite;
	output reg [1:0] RegWriteSrc;
	output reg [1:0] BranchProperty;
	output reg OutputPortWrite;
	output reg IsHalted;
	output reg IsLHI;
	output reg [1:0] ALUOp;
	output reg [`WORD_SIZE-1:0] nextstate;
	
	wire [3:0] opcode = inst[`WORD_SIZE-1: `WORD_SIZE-4];
	wire [5:0] func = (opcode==`ALU_OP) ? inst[5:0] : 0;
	
	always @(*) begin
		if(state == `STATE_C1) IRWrite = 1;
		else IRWrite = 0;
		if(state == `STATE_C1
			|| state == `STATE_JMP1
			|| state == `STATE_JPR1
			|| state == `STATE_JAL1
			|| state == `STATE_JRL1) PCWrite = 1;
		else PCWrite = 0;
		if(state == `STATE_BEQ1
			|| state == `STATE_BNE1
			|| state == `STATE_BGZ1
			|| state == `STATE_BLZ1) PCWriteCond = 1;
		else PCWriteCond = 0;
		if(state == `STATE_R2
			|| state == `STATE_WRITE_RT
			|| state == `STATE_LW3
			|| state == `STATE_JAL1
			|| state == `STATE_JRL1) RegWrite = 1;
		else RegWrite = 0;
		if(state == `STATE_LW2) MemRead = 1;
		else MemRead = 0;
		if(state == `STATE_SW2) MemWrite = 1;
		else MemWrite = 0;
		if(state == `STATE_WWD1) OutputPortWrite = 1;
		else OutputPortWrite = 0;
		if(state == `STATE_HLT1) IsHalted = 1;
		else IsHalted = 0;
		case(state)
			`STATE_C1: begin
				ALUSrcA = 0;
				IorD = 0;
				ALUSrcB = 1;
				PCSource = 0;
				ALUOp = 1;
				nextstate = `STATE_C2;
			end
			`STATE_C2: begin
				ALUSrcA = 0;
				ALUSrcB = 3;
				ALUOp = 1;
				$display("rom examining opcode %x", opcode);
				if(opcode == `ALU_OP) begin
					if(func == `INST_FUNC_WWD) nextstate = `STATE_WWD1;
					else if(func == `INST_FUNC_JPR) nextstate = `STATE_JPR1;
					else if(func == `INST_FUNC_JRL) nextstate = `STATE_JRL1;
					else if(func == `INST_FUNC_HLT) nextstate = `STATE_HLT1;
					else nextstate = `STATE_R1;
				end
				else begin
					case(opcode)
						`ADI_OP: nextstate = `STATE_ADI1;
						`ORI_OP: nextstate = `STATE_ORI1;
						`LHI_OP: nextstate = `STATE_LHI1;
						`LWD_OP: nextstate = `STATE_RW_ADDR_ADD;
						`SWD_OP: nextstate = `STATE_RW_ADDR_ADD;
						`BNE_OP: nextstate = `STATE_BNE1;
						`BEQ_OP: nextstate = `STATE_BEQ1;
						`BGZ_OP: nextstate = `STATE_BGZ1;
						`BLZ_OP: nextstate = `STATE_BLZ1;
						`JMP_OP: nextstate = `STATE_JMP1;
						`JAL_OP: nextstate = `STATE_JAL1;
					endcase
				end
			end
			`STATE_R1: begin
				ALUSrcA = 1;
				ALUSrcB = 0;
				IsLHI = 0;
				ALUOp = 0;
				nextstate = `STATE_R2;
			end 
			`STATE_R2: begin
				RegDest = 1;
				RegWriteSrc = 0;
				nextstate = `STATE_C1;
			end 
			`STATE_ADI1: begin
				ALUSrcA = 1;
				ALUSrcB = 2;
				IsLHI = 0;
				ALUOp = 1;
				nextstate = `STATE_WRITE_RT;
			end 
			`STATE_ORI1: begin
				ALUSrcB = 4;
				IsLHI = 0;
				ALUOp = 2;
				nextstate = `STATE_WRITE_RT;
			end 
			`STATE_LHI1: begin
				RegWriteSrc = 0;
				IsLHI = 1;
				nextstate = `STATE_WRITE_RT;
			end 
			`STATE_WRITE_RT: begin
				RegDest = 0;
				RegWriteSrc = 0;
				nextstate = `STATE_C1;
			end 
			`STATE_LW2: begin
				IorD = 1;
				nextstate = `STATE_LW3;
			end 
			`STATE_LW3: begin
				RegDest = 0;
				RegWriteSrc = 1;
				nextstate = `STATE_C1;
			end 
			`STATE_RW_ADDR_ADD: begin
				ALUSrcA = 1;
				ALUSrcB = 2;
				ALUOp = 1;
				if(opcode == `LWD_OP) nextstate = `STATE_LW2;
				else if(opcode == `SWD_OP) nextstate = `STATE_SW2;
			end 
			`STATE_SW2: begin
				IorD = 1;
				nextstate = `STATE_C1;
			end 
			`STATE_BEQ1: begin
				ALUSrcA = 1;
				ALUSrcB = 0;
				PCSource = 1;
				BranchProperty = 0;
				ALUOp = 3;
				nextstate = `STATE_C1;
			end 
			`STATE_BNE1: begin
				ALUSrcA = 1;
				ALUSrcB = 0;
				PCSource = 1;
				BranchProperty = 1;
				ALUOp = 3;
				nextstate = `STATE_C1;
			end 
			`STATE_BGZ1: begin
				ALUSrcA = 1;
				ALUSrcB = 5;
				PCSource = 1;
				BranchProperty = 2;
				ALUOp = 3;
				nextstate = `STATE_C1;
			end 
			`STATE_BLZ1: begin
				ALUSrcA = 1;
				ALUSrcB = 5;
				PCSource = 1;
				BranchProperty = 3;
				ALUOp = 3;
				nextstate = `STATE_C1;
			end 
			`STATE_JMP1: begin
				PCSource = 2;
				nextstate = `STATE_C1;
			end 
			`STATE_JPR1: begin
				PCSource = 3;
				nextstate = `STATE_C1;
			end 
			`STATE_JAL1: begin
				PCSource = 2;
				RegDest = 2;
				RegWriteSrc = 2;
				nextstate = `STATE_C1;
			end 
			`STATE_JRL1: begin
				PCSource = 3;
				RegDest = 2;
				RegWriteSrc = 2;
				nextstate = `STATE_C1;
			end
			`STATE_WWD1: begin
				nextstate = `STATE_C1;
			end 
			`STATE_HLT1: begin
				nextstate = `STATE_C1;
			end
		endcase
	end

endmodule
