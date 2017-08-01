/*
* @Author:    tmh
* @Date:      2017-07-25 20:02:24
* @File Name: PC.v
*/

`include "define.v"


module PC (
	input                          clk         , // Clock
	input                          rst_n       , // Asynchronous reset active low
	input  [                  8:0] IR          , // Instruction in
	input  [   `EX_STATE_BITS-1:0] executeState, // Execute State
	input  [   `FE_STATE_BITS-1:0] fetchState  , // Fetch State
	input  [`ALU_STATUS_WIDTH-1:0] aluStatusIn , // ALU State in
	input  [      `DATA_WIDTH-1:0] gprIn       , // gpr In
	input  [        `PC_WIDTH-1:0] stackIn     , // Stack in
	input  [                  2:0] writeCommand, // GPR write command
	input  [                  4:0] gprFSRIn    , // gprFSRIn
	output [        `PC_WIDTH-1:0] PC          , // PC Register out
	output                         goto        ,
	output                         skip
);

reg[`PC_WIDTH-1:0] rPC;
reg rgoto;
reg rskip;

assign PC = rPC;
assign goto = rgoto;
assign skip = rskip;

always @(posedge clk) begin
		if (!rst_n) begin
			rPC <= `PC_WIDTH'b0;
			rskip <= 1'b0;
			rgoto <= 1'b0;
		end
		else begin
			case (fetchState)
				`FE_Q1: begin
					if (!rgoto) begin
						rPC <= rPC + 1'b1;
					end
				end
				`FE_Q2, `FE_Q3: begin
				end
				`FE_Q4: begin
				end
			endcase
			case (executeState)
				`EX_Q1: begin
					if (rskip | rgoto) begin
						rskip <= 1'b0;
						rgoto <= 1'b0;
					end
				end
				`EX_Q2: begin
				end
				`EX_Q3: begin
				end
				`EX_Q4_CLRF: begin
				end
				`EX_Q4_CLRW: begin
				end
				`EX_Q4_FSZ: begin
					if (aluStatusIn[2]) begin
						rskip <= 1'b1;
					end
				end
				`EX_Q4_MOVF: begin
				end
				`EX_Q4_MOVWF: begin
				end
				`EX_Q4_BXF: begin
				end
				`EX_Q4_BTFSX: begin
					case (IR[8])
						1'b1: begin
							if(gprIn[IR[7:5]]) begin
								rskip <= 1'b1;
							end
						end
						1'b0: begin
							if(!gprIn[IR[7:5]]) begin
								rskip <= 1'b1;
							end
						end
					endcase
				end
				`EX_Q4_CALL: begin
					rPC <= {1'b0, IR[7:0]};
					rskip <= 1'b1;
					rgoto <= 1'b1;
				end
				`EX_Q4_CLRWDT: begin
				end
				`EX_Q4_GOTO: begin
					rPC <= IR[8:0];
					rskip <= 1;
					rgoto <= 1;
				end
				`EX_Q4_MOVLW: begin
				end
				`EX_Q4_OPTION: begin
				end
				`EX_Q4_RETLW: begin
					rPC <= stackIn;
					rskip <= 1'b1;
					rgoto <= 1'b1;
				end
				`EX_Q4_SLEEP: begin
				end
				`EX_Q4_TRIS: begin
				end
				`EX_Q4_ELSE: begin
				end
				`EX_Q4_ALUXLW: begin
				end
				`EX_Q4_NOP: begin
				end
				default: ;
			endcase
			if (writeCommand[1] && (gprFSRIn[4:0] == `ADDR_PCL)) begin
				rPC <= {1'b0, IR[7:0]};
				rskip <= 1'b1;
			end
		end
	end

endmodule