`include "opcodes.v"
`include "uController.v"

module cpu (clk, reset_n, readM1, address1, data1, readM2, writeM2, address2, data2, num_inst, output_port, is_halted);
	input clk;											// clock signal	
	input reset_n;									// active-low RESET signal
	
	output readM1;									// read from memory
	output [`WORD_SIZE-1:0] address1;	// current address for data
	input [`WORD_SIZE-1:0] data1;			// data being input or output
	
	output readM2;
	output writeM2;									// wrtie to memory
	output [`WORD_SIZE-1:0] address2;
	inout [`WORD_SIZE-1:0] data2;
	
	output reg [`WORD_SIZE-1:0] num_inst;
	output reg [`WORD_SIZE-1:0] output_port;
	output reg is_halted;
	
	//internal state(regsiters)
	reg [`WORD_SIZE-1:0] inst;
	
    // internal control bits	
	wire ALUSrcA;
	wire IorD;
	wire IRWrite;
	wire PCWrite;
	wire PCWriteCond;
	wire [2:0] ALUSrcB;
	wire [1:0] PCSource;
	wire [1:0] RegDest;
	wire RegWrite;
	wire MemRead;
	wire MemWrite;
	wire [1:0] RegWriteSrc;
	wire [1:0] BranchProperty;
	wire wirePortWrite;
	wire IsHalted;
	wire IsLHI;
	wire [1:0] ALUOp;
									   						   	
	// Datapath 
    Datapath dpath (inst, 
	readM1, address1, data1,
	readM2, writeM2, address2, data2
	ALUSrcA, IorD, IRWrite, PCWrite, PCWriteCond, ALUSrcB, PCSource, 
	RegDest, RegWrite, MemRead, MemWrite, RegWriteSrc, BranchProperty, OutputPortWrite,
	IsHalted, IsLHI, ALUOp, reset_n, clk, output_port, is_halted);			
	
	uController uControl(inst, ALUSrcA, IorD, IRWrite, PCWrite, PCWriteCond, ALUSrcB, PCSource, 
	RegDest, RegWrite, MemRead, MemWrite, RegWriteSrc, BranchProperty, OutputPortWrite,
	IsHalted, IsLHI, ALUOp, reset_n, clk);
	

endmodule							  																		  