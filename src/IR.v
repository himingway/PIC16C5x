/*
* @Author:    tmh
* @Date:      2017-07-25 20:57:38
* @File Name: IR.v
*/

`include "define.v"

module IR (
	input                       clk         , // Clock
	input                       rst_n       , // Asynchronous reset active low
	input  [`FE_STATE_BITS-1:0] fetchState  , // Fetch State
	input  [`EX_STATE_BITS-1:0] executeState, // Execute State
	input  [   `INST_WIDTH-1:0] programMemIn, // Program memory in
	input                       goto        , // goto
	input                       skip        , //skip
	output [   `INST_WIDTH-1:0] IR            // Instruction out
);

reg [`INST_WIDTH-1:0] rIR;

assign IR = rIR;

always @(posedge clk) begin
	if (!rst_n) begin
		rIR <= `INST_WIDTH'b0;
	end
	else begin
		if (fetchState == `FE_Q4) begin
			rIR <= programMemIn;
		end
		if (executeState == `EX_Q1) begin
			if (skip | goto) begin
				rIR <= `I_NOP_12;
			end
		end
	end
end
endmodule