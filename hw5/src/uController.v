`include "opcodes.v"
`include "uProgramRom.v"

module uController(inst, ALUSrcA, IorD, IRWrite, PCWrite, PCWriteCond, ALUSrcB, PCSource, 
	RegDest, RegWrite, MemRead, MemWrite, RegWriteSrc, BranchProperty, OutputPortWrite,
	IsHalted, IsLHI, ALUOp, reset_n, sudoClk, num_inst);
	
	input [`WORD_SIZE-1:0] inst;
	input reset_n;
	inout sudoClk;
	
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
	output reg [`WORD_SIZE-1:0] num_inst;
	
	reg [4:0] uState;
	reg [4:0] nextuState;
	
	initial begin
		uState = 0;
		num_inst = 0;
	end
	
	always@(posedge sudoClk) begin
		//$display("state: %x, op: %d, func: %d, reset_n: %x", uState, inst[15:12], inst[5:0], reset_n);
		//$display("ALUSrcA: %x, IorD: %x, IRWrite: %x, PCWrite, %x, PCWriteCond: %x, ALUSrcB: %x, PCSource: %x, RegDest: %x, RegWrite: %x, MemRead: %x, MemWrite, %x, RegWriteSrc: %x, BranchProperty: %x, OutputPortWrite: %x, IsHalted: %x, IsLHI: %x, ALUOp: %x",
		//ALUSrcA, IorD, IRWrite, PCWrite, PCWriteCond, ALUSrcB, PCSource, RegDest, RegWrite, MemRead, MemWrite, RegWriteSrc, BranchProperty, OutputPortWrite, IsHalted, IsLHI, ALUOp);
		if(!reset_n) uState = 0;
		else begin
			//$display("ylo");

			uState = nextuState;
			if(nextuState == 0 ) begin
				num_inst += 1;
				$display("numinst increased: %d", num_inst);
			end
		end
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