`timescale 1ns/1ns
`include "opcodes.v"

module ALU (
	output reg overflow,
	output reg [`WORD_SIZE-1:0] Y,
	input [`WORD_SIZE-1:0] input1,
	input [`WORD_SIZE-1:0] input2,
	input [2:0] op
	);
	
	always @(*) begin
		overflow = 0;
		case(op)
			`FUNC_ADD: begin
				Y = input1 + input2;
				overflow = !(((input1[`WORD_SIZE-1] == input2[`WORD_SIZE-1]) && (input2[`WORD_SIZE-1] == Y[`WORD_SIZE-1])) || (input1[`WORD_SIZE-1] != input2[`WORD_SIZE-1]));
				end
			`FUNC_SUB: begin
				Y = input1 - input2;
				overflow = !(((input1[`WORD_SIZE-1] == ~input2[`WORD_SIZE-1]) && (~input2[`WORD_SIZE-1] == Y[`WORD_SIZE-1])) || (input1[`WORD_SIZE-1] != ~input2[`WORD_SIZE-1]));
				end
			`FUNC_AND: Y = input1 & input2;
			`FUNC_ORR: Y = input1 | input2;
			`FUNC_NOT: Y = ~input1;
			`FUNC_TCP: Y = ~input1 + 1;
			`FUNC_SHL: Y = input1 << 1;
			`FUNC_SHR: Y = $signed(input1) >>> 1;
		endcase
		//$display("ALUINSIEEZE!!!!!! %x, %x, %x, %x", input1, input2, op,Y);
	end
	
endmodule
	