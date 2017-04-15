		  
// Opcode
`define	ALU_OP	4'd15
`define	ADI_OP		4'd4
`define	ORI_OP	4'd5
`define	LHI_OP		4'd6
`define	LWD_OP	4'd7   		  
`define	SWD_OP	4'd8  
`define	BNE_OP	4'd0
`define	BEQ_OP	4'd1
`define	BGZ_OP	4'd2
`define	BLZ_OP	4'd3   		  
`define	JMP_OP	4'd9  
`define	JAL_OP	4'd10	


// ALU Function Codes
`define	FUNC_ADD	3'b000
`define	FUNC_SUB	3'b001				 
`define	FUNC_AND	3'b010
`define	FUNC_ORR	3'b011								    
`define	FUNC_NOT	3'b100
`define	FUNC_TCP	3'b101
`define	FUNC_SHL	3'b110
`define	FUNC_SHR	3'b111	

// ALU instruction function codes
`define INST_FUNC_ADD 6'd0
`define INST_FUNC_SUB 6'd1
`define INST_FUNC_AND 6'd2
`define INST_FUNC_ORR 6'd3
`define INST_FUNC_NOT 6'd4
`define INST_FUNC_TCP 6'd5
`define INST_FUNC_SHL 6'd6
`define INST_FUNC_SHR 6'd7
`define	INST_FUNC_WWD	6'd28								    
`define	INST_FUNC_JPR	6'd25
`define	INST_FUNC_JRL	6'd26
`define	INST_FUNC_HLT	6'd29

// ALU instruction function codes
`define STATE_C1 5'd0
`define STATE_C2 5'd1
`define STATE_R1 5'd2
`define STATE_R2 5'd3
`define STATE_ADI1 5'd4
`define STATE_ORI1 5'd5
`define STATE_LHI1 5'd6
`define STATE_WRITE_RT 5'd7
`define STATE_LW2 5'd8
`define STATE_LW3 5'd9
`define STATE_RW_ADDR_ADD 5'd10
`define STATE_SW2 5'd11
`define STATE_BEQ1 5'd12
`define STATE_BNE1 5'd13
`define STATE_BGZ1 5'd14
`define STATE_BLZ1 5'd15
`define STATE_JMP1 5'd16
`define STATE_JPR1 5'd17
`define STATE_JAL1 5'd18
`define STATE_JRL1 5'd19
`define STATE_WWD1 5'd20
`define STATE_HLT1 5'd21		  

`define	WORD_SIZE	16			
`define	NUM_REGS	4