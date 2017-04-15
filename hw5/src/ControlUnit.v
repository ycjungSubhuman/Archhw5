`include "opcodes.v" 	   

module ControlUnit(inst, ctrlRegDst, ctrlALUOp, ctrlALUSrc, ctrlRegWrite, ctrlRegWriteSrc, ctrlReadDataDst, ctrlMemRead, ctrlMemWrite, ctrlLHI, ctrlPc, aluControl, reset_n);  
	input [`WORD_SIZE-1:0] inst;	
	output reg ctrlRegDst;
	output reg ctrlALUOp;  
	output reg [1:0] ctrlALUSrc;
	output reg ctrlRegWrite; 		
	output reg ctrlRegWriteSrc;
	output reg ctrlReadDataDst;	  
	output reg ctrlMemRead;
	output reg ctrlMemWrite;
	output reg ctrlLHI;		   
	output reg [1:0] ctrlPc;
	output reg [2:0] aluControl;   
	input reset_n;
	
	wire [3:0] opcode = inst[`WORD_SIZE-1: `WORD_SIZE-4];
	wire [5:0] func = (opcode==`ALU_OP) ? inst[5:0] : 0;
	
	always @(*) begin
		ctrlRegDst = (opcode == `ALU_OP);
		ctrlALUOp = !((opcode == `ALU_OP && func >= 25) || opcode == `JMP_OP);
		if(opcode == `ALU_OP || opcode == `BNE_OP || opcode == `BEQ_OP)// reg b
			ctrlALUSrc = 0;
		else if(opcode == `LHI_OP) // LHI (8)
			ctrlALUSrc = 1;
		else
			ctrlALUSrc = 2;
		ctrlRegWrite = (opcode != `SWD_OP) && (opcode != `BNE_OP) && (opcode != `BEQ_OP) && (opcode != `JMP_OP);
		ctrlRegWriteSrc = (opcode == `LWD_OP);
		ctrlReadDataDst = 0;
		ctrlMemRead = opcode == `LWD_OP;
		ctrlMemWrite = opcode == `SWD_OP;
		ctrlLHI = opcode == `LHI_OP;
		if(opcode == `JMP_OP)
			ctrlPc = 0;
		else if(opcode == `BNE_OP || opcode == `BEQ_OP)
			ctrlPc = 1;
		else
			ctrlPc = 2;

		//opcode 
		if(opcode == `ADI_OP || opcode == `LWD_OP || opcode == `SWD_OP)
			aluControl = `FUNC_ADD;
		else if(opcode == `LHI_OP)
			aluControl = `FUNC_SHL;
		else
			aluControl = `FUNC_SUB;
			
		//function
		if(opcode == `ALU_OP) begin
			case(func)
				`INST_FUNC_ADD: aluControl = `FUNC_ADD;
				`INST_FUNC_SUB: aluControl = `FUNC_SUB;
				`INST_FUNC_AND: aluControl = `FUNC_AND;
				`INST_FUNC_ORR: aluControl = `FUNC_ORR;
				`INST_FUNC_NOT: aluControl = `FUNC_NOT;
				`INST_FUNC_TCP: aluControl = `FUNC_TCP;
				`INST_FUNC_SHL: aluControl = `FUNC_SHL;
				`INST_FUNC_SHR: aluControl = `FUNC_SHR;
			endcase
		end	
	end
			  	
endmodule