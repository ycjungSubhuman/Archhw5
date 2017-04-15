`include "opcodes.v"
`include "register_files.v"

module Datapath (inst, 
	readM1, address1, data1,
	readM2, writeM2, address2, data2
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
	input inputPortWrite;
	input IsHalted;
	input IsLHI;
	input [1:0] ALUOp;
	
	//internal states
	reg [`WORD_SIZE-1:0] Pc;
	reg [`WORD_SIZE-1:0] ALUOut;
	reg [`WORD_SIZE-1:0] MDR;
	reg [`WORD_SIZE-1:0] nextPC;
	reg [`WORD_SIZE-1:0] A;
	reg [`WORD_SIZE-1:0] B;
	reg [`WORD_SIZE-1:0] writeData;
	reg [1:0] writeTargetReg; 
	
	//internal states - helpers
	reg fetchInst;						//is instruction fetch pending?
	
	//reg files
	wire [`WORD_SIZE-1:0] readData1;
	wire [`WORD_SIZE-1:0] readData2;
	
	//visible states
	reg [`WORD_SIZE-1:0] inst;
	reg readM1;
	reg [`WORD_SIZE-1:0] address1;
	reg readM2;
	reg writeM2;
	reg [`WORD_SIZE-1:0] address2;
	reg [`WORD_SIZE-1:0] inoutM2WriteBuf;
	
	//assign
	assign data = !writeM2 ? `WORD_SIZE'bz : inoutM2WriteBuf; 
	
	initial begin
		Pc = 0;
		nextPc = 0;
		fetchInst = 0;
	end
	
	always @(*) begin
		
	end
	
	always @(posedge clk) begin
		//updating
		if(fetchInst == 1) begin 
			inst = data;
			fetchInst = 0;
		end
		
		
		//pending
		if(!IorD && IRWrite) begin //pend instruction fetch
			fetchInst = 1;
			readM1 = 1;
			address1 = Pc;
		end
			
		Pc = nextPc;
	end
	
	RegisterFiles regfile (RegWrite, inst[11:10], inst[9:8], writeTargetReg, writeData, clk, reset_n, readData1, readData2);	
	ALU alu (overflowFlag, aluOut, readData1, operandB, aluControl);
endmodule