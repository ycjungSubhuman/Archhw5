`include "opcodes.v"
`include "register_files.v"
`include "ALU.v"

module Datapath (inst, 
	readM1, address1, data1,
	readM2, writeM2, address2, data2,
	ALUSrcA, IorD, IRWrite, PCWrite, PCWriteCond, ALUSrcB, PCSource, 
	RegDest, RegWrite, MemRead, MemWrite, RegWriteSrc, BranchProperty, OutputPortWrite,
	IsHalted, IsLHI, ALUOp, reset_n, clk, output_port, is_halted, num_inst);  
	output inst;	 
	
	output readM1;
	output address1;
	input [`WORD_SIZE-1:0] data1;
	
	output readM2;
	output writeM2;
	output address2;
	inout [`WORD_SIZE-1:0] data2;

	input reset_n;	  
	input clk;
	output reg output_port;
	output reg is_halted;
	output reg [`WORD_SIZE-1:0] num_inst;
	
	//control bits
	input ALUSrcA;
	input IorD;
	input IRWrite;
	input PCWrite;
	input PCWriteCond;
	input [2:0] ALUSrcB;
	input [1:0] PCSource;
	input [1:0] RegDest;
	input RegWrite;
	input MemRead;
	input MemWrite;
	input [1:0] RegWriteSrc;
	input [1:0] BranchProperty;
	input OutputPortWrite;
	input IsHalted;
	input IsLHI;
	input [1:0] ALUOp;
	
	//internal states
	reg [`WORD_SIZE-1:0] Pc;
	reg [`WORD_SIZE-1:0] ALUOut;
	reg [`WORD_SIZE-1:0] MDR;
	reg [`WORD_SIZE-1:0] nextPc;
	reg [`WORD_SIZE-1:0] A;
	reg [`WORD_SIZE-1:0] B;
	reg [`WORD_SIZE-1:0] writeData;
	reg [1:0] writeTargetReg;
	reg [`WORD_SIZE-1:0] ALUOperandA;
	reg [`WORD_SIZE-1:0] ALUOperandB;
	
	//wires
	wire [`WORD_SIZE-1:0] readData1;
	wire [`WORD_SIZE-1:0] readData2;
	wire [`WORD_SIZE-1:0] aluOut;
	wire overflowFlag;
	wire branchMet;
	wire zero;
	
	assign zero = aluOut==0;
	assign branchMet = ((BranchProperty==0) && zero) || ((BranchProperty==1) && !zero)
		|| ((BranchProperty==2) && A[15] && !zero) || ((BranchProperty==3) && !A[15] && !zero);
	
	//visible states
	reg [`WORD_SIZE-1:0] inst;
	reg readM1;
	reg [`WORD_SIZE-1:0] address1;
	reg readM2;
	reg writeM2;
	reg [`WORD_SIZE-1:0] address2;
	reg [`WORD_SIZE-1:0] inoutM2WriteBuf;
	
	//assign
	assign data2 = !writeM2 ? `WORD_SIZE'bz : inoutM2WriteBuf; 
	
	initial begin
		Pc = 0;
		nextPc = 0;
		readM1 = 0;
		readM2 = 0;
		writeM2 = 0;
		num_inst = 0;
	end
	
	always @(*) begin
		
	end
	
	always @(posedge clk) begin			
		//Select NextPC
		if(PCWriteCond && branchMet || PCWrite) begin
			if(PCSource == 0) nextPc = aluOut;
			else if(PCSource == 1) nextPc = ALUOut;
			else if(PCSource == 2) nextPc = {Pc[15:12], inst[11:0]};
			else nextPc = A;
			num_inst += 1;
		end
		
		//Select ALU operands
		if(ALUSrcA == 0) ALUOperandA = Pc;
		else ALUOperandA = A;
		
		if(ALUSrcB ==0) ALUOperandB = B;
		else if (ALUSrcB == 1) ALUOperandB = 1;
		else if (ALUSrcB == 2 || ALUSrcB == 3) begin
			if(inst[7] == 1) ALUOperandB = {8'b11111111, inst[7:0]};
			else ALUOperandB = {8'b00000000, inst[7:0]};
		end
		else if (ALUSrcB == 4) ALUOperandB = {8'b00000000, inst[7:0]};
		else ALUOperandB = 0;
		
		//Select Reg Write Data
		if(RegWriteSrc==0)
			writeData = ALUOut;
		else if(RegWriteSrc==1)
			writeData = MDR;
		else
			writeData = Pc;
			
		//Select Reg Write Target
		if(RegDest == 0) writeTargetReg = inst[9:8];
		else if(RegDest == 1) writeTargetReg = inst[7:6];
		else writeTargetReg = 2;	
			
		//fetching memory data
		if(readM1 == 1) begin 
			inst = data1;
			readM1 = 0;
		end
		if(readM2 == 1) begin
			MDR = data2;
			readM2 = 0;
		end
		if(writeM2 == 1) writeM2 = 0;
		
		//pending memory operations 		
		if(!IorD && IRWrite && MemRead) begin //pend instruction fetch
			readM1 = 1;
			address1 = Pc;
		end
		
		if(IorD && RegWrite && MemRead) begin //pend data fetch
			readM2 = 1;
			address2 = ALUOut; 
		end
		
		if(IorD && MemWrite) begin
			writeM2 = 1;
			address2 = ALUOut;
			inoutM2WriteBuf = B;
		end
		
		//control
		if(OutputPortWrite) output_port = A;
		else output_port = 16'bz;
			
		if(IsHalted) is_halted = 1;
		else is_halted = 0;

		Pc = nextPc;
		A = readData1;
		B = readData2;
		if(IsLHI) ALUOut = {8'b00000000, A} << 8;
		else ALUOut = aluOut;
	end
	
	RegisterFiles regfile (RegWrite, inst[11:10], inst[9:8], writeTargetReg, writeData, clk, reset_n, readData1, readData2);	
	ALU alu (overflowFlag, aluOut, ALUOperandA, ALUOperandB, ALUOp);
endmodule