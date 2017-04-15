`timescale 1 ns / 100 ps

`include "opcodes.v"

module uProgramRom (state, inst,
	ALUSrcA, IorD, IRWrite, PCWrite, PCWriteCond, ALUSrcB, PCSource, 
	RegDest, RegWrite, MemRead, MemWrite, RegWriteSrc, BranchProperty, OutputPortWrite,
	IsHalted, IsLHI, ALUOp);
	
	input [`WORD_SIZE-1:0] state;
	input [`WORD_SIZE-1:0] inst;
	output ALUSrcA;
	output IorD;
	output IRWrite;
	output PCWrite;
	output PCWriteCond;
	output [2:0] ALUSrcB;
	output [1:0] PCSource;
	output [1:0] RegDest;
	output [//TODO : Finish

endmodule
