`include "opcodes.v" 	   

module cpu (readM, writeM, address, data, ackOutput, inputReady, reset_n, clk);
	output readM;									// read from memory
	output writeM;									// wrtie to memory
	output [`WORD_SIZE-1:0] address;	// current address for data
	inout [`WORD_SIZE-1:0] data;			// data being input or output
	input ackOutput;								// acknowledge of data receipt from output port
	input inputReady;								// indicates that data is ready from the input port
	input reset_n;									// active-low RESET signal
	input clk;											// clock signal
																																					  
	wire [`WORD_SIZE-1:0] inst;
	
	wire ctrlRegDst;
	wire ctrlALUOp;	 	   
	wire [1:0] ctrlALUSrc;
	wire ctrlRegWrite;		
	wire ctrlRegWriteSrc;  
	wire ctrlReadDataDst;	   
	wire ctrlMemRead;
	wire ctrlMemWrite;	
	wire ctrlLHI;
	wire [1:0] ctrlPc;
	wire [2:0] aluControl;			  
									   						   	
	// Datapath 
    Datapath dpath (inst, readM, writeM, address, data, ackOutput, inputReady, reset_n, clk,
	ctrlRegDst, ctrlALUOp, ctrlALUSrc, ctrlRegWrite, ctrlRegWriteSrc, ctrlReadDataDst, 
	ctrlMemRead, ctrlMemWrite, ctrlLHI, ctrlPc, aluControl);			
																													
	ControlUnit ctrl_unit (inst, ctrlRegDst, ctrlALUOp, ctrlALUSrc, ctrlRegWrite, ctrlRegWriteSrc, 
	ctrlReadDataDst, ctrlMemRead, ctrlMemWrite, ctrlLHI, ctrlPc, aluControl, reset_n);	
	

endmodule							  																		  