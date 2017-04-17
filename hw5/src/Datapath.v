`include "opcodes.v"
`include "register_files.v"
`include "ALU.v"

module Datapath (inst, 
	readM1, address1, data1,
	readM2, writeM2, address2, data2,
	ALUSrcA, IorD, IRWrite, PCWrite, PCWriteCond, ALUSrcB, PCSource, 
	RegDest, RegWrite, MemRead, MemWrite, RegWriteSrc, BranchProperty, OutputPortWrite,
	IsHalted, IsLHI, ALUOp, reset_n, clk, output_port, is_halted);  
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
	output reg [15:0] output_port;
	output reg is_halted;
	
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
	reg [`WORD_SIZE-1:0] A;
	reg [`WORD_SIZE-1:0] B;
	reg [`WORD_SIZE-1:0] writeData;
	reg [1:0] writeTargetReg;
	reg [`WORD_SIZE-1:0] ALUOperandA;
	reg [`WORD_SIZE-1:0] ALUOperandB;
	
	//wires
	wire [`WORD_SIZE-1:0] readData1;
	wire [`WORD_SIZE-1:0] readData2;
	wire [`WORD_SIZE-1:0] aluOutComb;
	wire overflowFlag;
	wire branchMet;
	wire zero;
	
	reg [1:0] prevBranchProperty;
	reg prevPCWriteCond;
	
	assign zero = aluOutComb==0;
	assign prevBranchMet = ((prevBranchProperty==0) && zero) || ((prevBranchProperty==1) && !zero)
		|| ((prevBranchProperty==2) && !A[15] && !zero) || ((prevBranchProperty==3) && A[15] && !zero);
	
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
	reg [`WORD_SIZE-1:0] next_num_inst;
	initial begin
		Pc = 0;
		readM1 = 0;
		readM2 = 0;
		writeM2 = 0;
		next_num_inst = 0;
		aluOpCode = 0;
		pendingPcUpdate = 0;
		prevRegWrite = 0;
		prevPCWriteCond = 0;
	end
	
	always @(data1) begin
	  	//fetching memory data
		if(readM1 == 1) begin 
			inst = data1;
			readM1 = 0;

		end
	end
	
	reg pendingPcUpdate;
	reg [1:0] prevPcSource;
	reg [15:0] prevJmpTarget;
	
	reg [2:0] aluOpCode;
	reg prevRegWrite;
	
	always @(posedge clk) begin
		prevRegWrite = RegWrite;

		
		if(readM2 == 1) begin
			MDR = data2;
			readM2 = 0;
		end
		if(writeM2 == 1) writeM2 = 0;
			
		if(pendingPcUpdate) begin		
			pendingPcUpdate = 0;
			if(prevPcSource == 0) Pc = aluOutComb;
			else if(prevPcSource == 1) Pc = ALUOut;
			else if(prevPcSource == 2) Pc = prevJmpTarget;
			else Pc = A;
		end
		

		
		//Select NextPC
		if(PCWrite) begin
			pendingPcUpdate = 1;
			prevPcSource = PCSource;
			prevJmpTarget = {Pc[15:12], inst[11:0]};
		end
		
		//$display("prevBranchMet: %x, prevBranchProperty: %x, prevPCWriteCond: %x, zero: %x, A: %x", prevBranchMet, prevBranchProperty, prevPCWriteCond, zero, A);
		if(prevPCWriteCond && prevBranchMet) begin
			Pc = ALUOut;
		end		 
		
		if(IsLHI) ALUOut = {8'b00000000, inst[7:0]} << 8;
		else ALUOut = aluOutComb;
		
		prevBranchProperty = BranchProperty;
		prevPCWriteCond = PCWriteCond;
		
		if(ALUOp == 0) begin
			case(inst[5:0])
				`INST_FUNC_ADD: aluOpCode = `FUNC_ADD;
				`INST_FUNC_SUB: aluOpCode = `FUNC_SUB;
				`INST_FUNC_AND: aluOpCode = `FUNC_AND;
				`INST_FUNC_ORR: aluOpCode = `FUNC_ORR;
				`INST_FUNC_NOT: aluOpCode = `FUNC_NOT;
				`INST_FUNC_TCP: aluOpCode = `FUNC_TCP;
				`INST_FUNC_SHL: aluOpCode = `FUNC_SHL;
				`INST_FUNC_SHR: aluOpCode = `FUNC_SHR;
			endcase
		end
		else if (ALUOp == 1) aluOpCode = `FUNC_ADD;
		else if (ALUOp == 2) aluOpCode = `FUNC_ORR;
		else aluOpCode = `FUNC_SUB;
		
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
			

		
		//pending memory operations 		
		if(!IorD && IRWrite) begin //pend instruction fetch
			readM1 = 1;
			address1 = Pc;
		end
		
		if(IorD && MemRead) begin //pend data fetch
			readM2 = 1;
			address2 = ALUOut; 
		end
		
		if(IorD && MemWrite) begin
			writeM2 = 1;
			address2 = ALUOut;
			inoutM2WriteBuf = B;
		end
		

			
		if(IsHalted) is_halted = 1;
		else is_halted = 0;


		A = readData1;
		B = readData2;
		//control
		if(OutputPortWrite) output_port = A;
				

			
		if(!reset_n) begin
			Pc = 0;
			readM1 = 0;
			readM2 = 0;
			writeM2 = 0;
			aluOpCode = 0;
			inst = 16'bx;
			pendingPcUpdate = 0;
			prevRegWrite = 0;
			prevPCWriteCond = 0;
		end
		//$display("posedge! Pc: %x, readM1: %x, readM2: %x, writeM2: %x,  aluOutComb: %x, ALUOut: %x, ALUOperandA: %x, ALUOperandB: %x, aluOpCode: %x, reset_n: %x, A: %x, B: %x", 
		//Pc, readM1, readM2, writeM2, aluOutComb, ALUOut, ALUOperandA, ALUOperandB, aluOpCode, reset_n, A, B);
	end

	 
	
	RegisterFiles regfile (prevRegWrite, inst[11:10], inst[9:8], writeTargetReg, writeData, clk, reset_n, readData1, readData2);	
	ALU alu (overflowFlag, aluOutComb, ALUOperandA, ALUOperandB, aluOpCode);
endmodule