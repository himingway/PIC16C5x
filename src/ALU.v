/*
* @Author:    tmh
* @Date:      2017-07-24 20:09:26
* @File Name: ALU.v
*/

`include "define.v"

module ALU (
	input  [  `ALU_DATA_WIDTH-1:0] wIn         , // working register in
	input  [  `ALU_DATA_WIDTH-1:0] fIn         , // general purpose register in
	input  [  `ALU_DATA_WIDTH-1:0] lIn         , // literlal in
	input  [  `ALU_FUNC_WIDTH-1:0] funcIn      , // alu function in
	input  [                  2:0] bitSel      , // bit selection in
	input                          cFlag       , // carry flag in(for RRF, RLF instruction)
	input  [`ALU_STATUS_WIDTH-1:0] statusIn    , // status in
	output [`ALU_STATUS_WIDTH-1:0] aluStatusOut, // alu status out {zero, digit carry, carry}
	output [  `ALU_DATA_WIDTH-1:0] aluResultOut  // alu result out
);

// Arithmetic
reg C3;
reg carry;
reg [`ALU_DATA_WIDTH-1:0] result;

assign aluResultOut = result;

always @(*) begin
	C3 = 1'b0;
	carry = 1'b0;
	case (funcIn)
		`ALU_ADDWF: begin // ADD W and f
			{C3,result[3:0]} = fIn[3:0] + wIn[3:0];
			{carry,result[7:4]} = fIn [7:4] + wIn[7:4] + C3;
		end
		`ALU_SUBWF: begin // SUB w form f
			{C3,result[3:0]} = fIn[3:0] - wIn[3:0];
			{carry,result[7:4]} = fIn[7:4] - wIn[7:4] - C3;
		end
		`ALU_ANDWF: begin // AND w with f
			result = wIn & fIn;
		end
		`ALU_COMF: begin // Complement f
			result = ~ fIn;
		end
		`ALU_DECF: begin // Decrement f
			result = fIn - 1'b1;
		end
		`ALU_INCF: begin // Incresement f
			result = fIn + 1'b1;
		end
		`ALU_IORWF: begin // Inclusive OR W with f
			result = fIn | wIn;
		end
		`ALU_RLF: begin // Rotate left f throngh Carry
			{carry, result} = {fIn[`DATA_WIDTH-1:0], cFlag};
		end
		`ALU_RRF: begin // Rotate right f through Carry
			{carry, result} = {fIn[0], cFlag, fIn[`DATA_WIDTH-1:1]};
		end
		`ALU_SWAPF: begin // Swap f
			result = {fIn[3:0],fIn[7:4]};
		end
		`ALU_XORWF: begin // Exclusive OR W wtih f
			result = fIn ^ wIn;
		end
		`ALU_BCF: begin // Bit Clear f
			result = fIn & ~ (8'h01 << bitSel);
		end
		`ALU_BSF: begin // Bit Set f
			result = fIn | (8'h1 << bitSel);
		end
		`ALU_ANDLW: begin // AND literal with W
			result = wIn & lIn;
		end
		`ALU_IORLW: begin // Inclusive Or Literal in W
			result = lIn | wIn;
		end
		`ALU_XORLW: begin
			result = lIn ^ wIn;
		end
		`ALU_MOVF : begin 
			result = fIn;
		end
		`ALU_IDLE: begin
			result = 8'hEF;
		end
		default: begin
			result = 8'hEF;
		end
	endcase
end

// Status Affected
reg [`ALU_STATUS_WIDTH - 1:0] status;

assign aluStatusOut = status;

always@(*) begin
	case (funcIn)
		`ALU_ADDWF:begin 
			status = {(result == 8'b0), 1'b0, 1'b0} | {1'b0, C3, carry};
		end
		`ALU_SUBWF: begin
			status = {(result == 8'b0), 1'b0, 1'b0} | {1'b0, ~C3, ~carry};
		end
		`ALU_RLF, `ALU_RRF: begin
			status = statusIn | {1'b0, 1'b0, carry};
		end
		default: begin
			status = {(result == 8'b0), statusIn[1:0]};
		end
	endcase
end

endmodule
