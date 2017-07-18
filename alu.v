/*
* @Author:    tmh
* @Date:      2017-07-17 19:35:39
* @File Name: alu.v
*/

`include "define.v"

module alu (
	input  [`DATA_WIDTH-1:0]     WIn,       // Working register in
	input  [`DATA_WIDTH-1:0]     fIn,       // GenerL purpose register in
	input  [`DATA_WIDTH-1:0]     lIn,       // Literal in
	input  [`ALU_FUNC_WIDTH-1:0] funcIn,    // ALU function in
	input  [`BIT_SEL_WIDTH-1:0]  bitSel,    // Bit selection in
	input  cFLag,                           // Carry status
	output [`DATA_WIDTH-1:0]     resultOut  // ALU result out
);

	// Reg
	reg carry;
	reg C3;
	reg [`DATA_WIDTH-1:0]       result;
	reg [`ALU_STATUS_WIDTH-1:0] status;

	// Assign
	assign resultOut = result;

	/*========Combination Logic========*/

	// Status Affected
	always@(*) begin
			status = {(result == 0), 1'b0, 1'b0};
		case (funcIn)
			`ALU_ADDWF,`ALU_SUBWF: begin
				status = status | {1'b0, C3, carry};
			end
			`ALU_RLF, `ALU_RRF: begin
				status = status | {1'b0, 1'b0, carry};
			end
			default : status = 3'd0;
		endcase
	end

	// Arithmetic Unit
	always @(*) begin
		case (funcIn)
			`ALU_ADDWF: begin // ADD W and f
				{C3,result[3:0]} = fIn[3:0] + WIn[3:0];
				{carry,result[7:4]} = fIn [7:4] + WIn[7:4] + C3;
			end
			`ALU_SUBWF: begin // SUB w form f
				{C3,result} = fIn[3:0] - WIn[3:0];
				{carry,result} = fIn[7:4] - WIn[7:4] - C3;
			end
			`ALU_ANDWF: begin // AND w with f 
				result = WIn & fIn;
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
				result = fIn | WIn;
			end
			`ALU_RLF: begin // Rotate left f throngh Carry
				{carry, result} = {fIn[`DATA_WIDTH-1:0], cFLag};
			end
			`ALU_RRF: begin // Rotate right f through Carry
				{carry, result} = {fIn[0], cFLag, fIn[`DATA_WIDTH-1:1]};
			end
			`ALU_SWAPF: begin // Swap f
				result = {fIn[3:0],fIn[7:4]};
			end
			`ALU_XORWF: begin // Exclusive OR W wtih f 
				result = fIn ^ WIn;
			end
			`ALU_BCF: begin // Bit Clear f
				result = fIn & ~ (8'h01 << bitSel);
			end
			`ALU_BSF: begin // Bit Set f
				result = fIn | (8'h1 << bitSel);
			end
			`ALU_ANDLW: begin // AND literal with W
				result = WIn & lIn;
			end
			`ALU_IORLW: begin // Inclusive Or Literal in W
				result = lIn | WIn;
			end
			`ALU_IDLE: begin 
				result = 8'd0;
			end
			default : result = 8'd0;
		endcase
	end

endmodule