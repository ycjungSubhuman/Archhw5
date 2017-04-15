`include "opcodes.v"
`include "uProgramRom.v"

module uController(inst, ALUSrcA, IorD, IRWrite, PCWrite, PCWriteCond, ALUSrcB, PCSource, 
	RegDest, RegWrite, MemRead, MemWrite, RegWriteSrc, BranchProperty, OutputPortWrite,
	IsHalted, IsLHI, ALUOp, reset_n, clk);
	
	input [`WORD_SIZE-1:0] inst;
	input reset_n;
	input clk;
	
	output ALUSrcA;
	output IorD;
	output IRWrite;
	output PCWrite;
	output PCWriteCond;
	output [2:0] ALUSrcB;
	output [1:0] PCSource;
	output [1:0] RegDest;
	output RegWrite;
	output MemRead;
	output MemWrite;
	output [1:0] RegWriteSrc;
	output [1:0] BranchProperty;
	output OutputPortWrite;
	output IsHalted;
	output IsLHI;
	output [1:0] ALUOp;
	
	reg [4:0] uState;
	reg [4:0] nextuState;
	
	initial begin
		uState = 0;
	end
	
	always@(posedge clk) begin
		if(!reset_n) uState = 0;
		else uState = nextuState;
	end
	
	uProgramRom uRom(
	.state(uState), 
	.inst(inst),
	.ALUSrcA(ALUSrcA),
	.IorD(IorD),
	.IRWrite(IRWrite),
	.PCWrite(PCWrite),
	.PCWriteCond(PCWriteCond),
	.ALUSrcB(ALUSrcB),
	.PCSource(PCSource),
	.RegDest(RegDest),
	.RegWrite(RegWrite),
	.MemRead(MemRead),
	.MemWrite(MemWrite),
	.RegWriteSrc(RegWriteSrc),
	.BranchProperty(BranchProperty),
	.OutputPortWrite(OutputPortWrite),
	.IsHalted(IsHalted),
	.IsLHI(IsLHI),
	.ALUOp(ALUOp),
	.nextstate(nextuState)
	);
	
endmodule