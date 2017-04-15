`include "opcodes.v"
`include "alu_register_files.v"

module Datapath (inst, readM, writeM, address, data, ackOutput, inputReady, reset_n, clk,
	ctrlRegDst, ctrlALUOp, ctrlALUSrc, ctrlRegWrite, ctrlRegWriteSrc, ctrlReadDataDst, ctrlMemRead, ctrlMemWrite, ctrlLHI, ctrlPc, aluControl);	  
	output reg [`WORD_SIZE-1:0] inst;	 
	output reg readM;					   
	output reg writeM;
	output reg [`WORD_SIZE-1:0] address;
	inout [`WORD_SIZE-1:0] data;
	input inputReady;				
	input ackOutput;
	input reset_n;	  
	input clk;		   
	
	input ctrlRegDst;
	input ctrlALUOp;	
	input [1:0] ctrlALUSrc;
	input ctrlRegWrite; 	 
	input ctrlRegWriteSrc;		  
	input ctrlReadDataDst; 
	input ctrlMemRead;
	input ctrlMemWrite;
	input ctrlLHI;		 
	input [1:0] ctrlPc;
	input [2:0] aluControl;
	
	reg [`WORD_SIZE-1:0] inoutReg;
	assign data = !writeM ? `WORD_SIZE'bz : inoutReg;
	
	reg overflowFlag;
	reg [3:0] opcode;
	reg [`WORD_SIZE-1:0] Pc;
	reg [1:0] reg1;
	reg [1:0] reg2;
	reg [1:0] writeReg;
	reg [`WORD_SIZE-1:0] writeData;
	reg [`WORD_SIZE-1:0] readData1;
	reg [`WORD_SIZE-1:0] readData2;
	reg [7:0] immediate;	
	reg [`WORD_SIZE-1:0] aluOut;
	reg [`WORD_SIZE-1:0] memOut;
	reg [`WORD_SIZE-1:0] extendedImmediate;
	
	reg [1:0] writeReg_prev;
	reg ctrlRegWrite_prev;
	reg pendingReadType; //0 : inst 1: memory
	reg memOpTicket;
	
	initial begin
		Pc = 0;
		writeM = 0;
		pendingReadType = 0;
	end
	
	reg [`WORD_SIZE-1: 0] operandB;
	always @(*) begin 
		if(inputReady && !writeM) begin
			readM = 0;
			if(pendingReadType == 0) begin
				inst = data;
				//decode instruction
				opcode = inst[`WORD_SIZE-1:`WORD_SIZE-4];
				reg1 = inst[11:10];
				reg2 = inst[9:8];
				immediate = inst[7:0];
				writeReg = (ctrlRegDst == 1) ? inst[7:6] : inst[9:8];
				
				//Select ALU input 2
				if(ctrlALUSrc == 0) operandB = readData2;
				else if(ctrlALUSrc == 2) begin
					if(immediate[7] == 1) operandB = {8'b11111111, immediate};
					else operandB = {8'b00000000, immediate};
				end
				else operandB = 8;

				memOpTicket = 1;	//enable load/store after IF
					
				if(immediate[7] == 1) extendedImmediate = {8'b11111111, immediate};
				else extendedImmediate = {8'b00000000, immediate};
				
				//YOLO : Immediate Branch Target 
				writeData = (ctrlLHI) ? extendedImmediate<<8 : aluOut;
			end
			else if(pendingReadType == 1) begin
				writeData = ctrlRegWriteSrc ? data : aluOut;
				memOpTicket = 0;
			end
		end
		
		//send R/W request
		if(!inputReady && !readM && ctrlMemRead && memOpTicket) begin
			readM = 1;
			address = aluOut;
			pendingReadType = 1;
		end
		else if(!inputReady && !writeM && ctrlMemWrite && memOpTicket) begin
			writeM = 1;
			address = aluOut;
			inoutReg = readData2;
		end
		
		if(ackOutput == 1) begin
			memOpTicket = 0;
			writeM = 0; 
		end
			  
		
		$display("readM: %d, writeM: %d, data: %x, inst: %x, inoutReg: %x, reg1: %x, reg2: %x, immediate: %x, writeReg: %x, writeData: %x, readData1: %x, readData2: %x, operandB: %x, aluOut: %x, ctrlRegDst: %x, ctrlRegWrite: %x, address: %x, aluControl: %x", readM, writeM, data, inst, inoutReg, reg1, reg2, immediate, writeReg, writeData, readData1, readData2, operandB, aluOut, ctrlRegDst, ctrlRegWrite, address, aluControl);
	end
	
	always @(posedge clk) begin

		if(ctrlPc == 0)	Pc = {Pc[15:12], operandB[11:0]};
		else if(ctrlPc == 1) begin
			if(!((opcode == `BEQ_OP && aluOut == 0) || (opcode == `BNE_OP && aluOut != 0))) extendedImmediate = 0;
			Pc = Pc + 1 + extendedImmediate;
		end
		else if(ctrlPc == 2) Pc = Pc + 1;
		
		// Read instruction
		readM = 1;
		address = Pc;															  											  
		pendingReadType = 0;
	end
		
	always @(posedge clk) begin
		writeReg_prev = writeReg;
		ctrlRegWrite_prev = ctrlRegWrite;
	end
	
	RegisterFiles regfile (ctrlRegWrite, reg1, reg2, writeReg, writeData, clk, reset_n, readData1, readData2);	
	ALU alu (overflowFlag, aluOut, readData1, operandB, aluControl);
endmodule