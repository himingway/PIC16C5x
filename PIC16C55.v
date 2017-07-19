/*
* @Author:    tmh
* @Date:      2017-07-19 10:25:31
* @File Name: PIC16C55.v
*/

`include "define.v"

module PIC16C55 (
	input clk,    // Clock
	input rst,  // Asynchronous reset active low
);

	// Memory
	reg [`INST_WIDTH-1:0] MEM [511:0]; // 12*512 memory

	// Reg
	reg [`PC_WIDTH-1:0]   PC; // Program count
	reg [`INST_WIDTH-1:0] IR; // Instruction Register
	reg [`DATA_WIDTH-1:0] WR; // W Reg

	// Wire
	wire [`FE_STATE_BITS-1:0]  fetchState;
	wire [`EX_STATE_BITS-1:0]  executeState;
	wire [`ALU_FUNC_WIDTH-1:0] aluFunc;

	//Assign
	assign byteDestF = IR[5];

	// Decoder
	decoder Decoder_Ins(
		.clk(clk),
		.rst(rst),
		.instIn(IR),
		.fetchState(fetchState),
		.executeState(executeState),
		.aluFunc(aluFunc)
		);

	// ALU 
	ALU ALU_Ins(
		.WIn(WR),
		.fIn(gprOut),
		.lIn(IR[7:0]),
		.funcIn(aluFunc),
		.bitSel(IR[7:5]),
		.cFlag(gprStatusOut[0]),
		.statusOut(aluStatusOut),
		.resultOut(aluResultOut)
		);

	//Combination Logic

	//writeQ4Result, fsrIndWriteData decision
	always @(*) begin
		case(executeState)
			`EX_Q2_FSR: begin 
				fsrIndWriteData = {3'b000,IR[4:0]};
			end
			`EX_Q4_CLRF: begin 
				writeQ4Result = 1'b1;
				fsrIndWriteData = 8'b0;
			end
			`EX_Q4_MOVWF: begin 
				writeQ4Result = 1'b1;
				fsrIndWriteData = WR;
			end
			`EX_Q4_BXF: begin 
				writeQ4Result = 1'b1;
				fsrIndWriteData = aluResultOut;
			end
			`EX_Q4_FSZ, `EX_Q4_DECF, `EX_Q4_SUBWF, `EX_Q4_SWAPF, `EX_Q4_MOVF，`EX_Q4_00_ELSE: begin 
				if(byteDestF) begin 
					writeQ4Result = 1'b1;
					fsrIndWriteData = aluResultOut;
				end
			end
			default : /* default */;
		endcase
	end


	always @(*) begin
		case (executeState)
			`EX_Q4_CLRF: begin 
				writeStatus = 1'b1;
				statusWriteData = {gprStatusOut[7:3],1'b1,2'b00};
			end
			`EX_Q4_CLRW: begin 
				writeStatus = 1'b1;
				statusWriteData = {gprStatusOut[7:3],1'b1,2'b00};
			end
			`EX_Q4_MOVF: begin 
				statusWriteData = {gprStatusOut[7:3],gprOut == 0,2'b00};
			end
			`EX_Q4_DECF, `EX_Q4_SUBWF, 
			`EX_Q4_00_ELSE,
			`EX_Q4_ALUXLW: begin 
				writeStatus = 1'b1;
				statusWriteData = {gprStatusOut[7:3],aluStatusOut};
			end
			default : /* default */;
		endcase
	end

	always @(posedge clk or negedge rst) begin
		if (rst) begin 
			PC <= `PC_WIDTH'b0;
			IR <= `I_NOP_12;
			WR <= `DATA_WIDTH'b0;
		end
		else begin 
			case (fetchState)
				`FE_Q1_INCPC: begin 
					PC <= PC +1;
				end
				`FE_Q2_IDLE, `FE_Q3_IDLE: begin
					// Do nothing 
				end
				`FE_Q4_FETCH： begin 
					IR <= programMem [PC];
				end
				default : /* default */;
			endcase

			case (executeState)
				`EX_Q1_TEST_SKIP: begin 
				end
				`EX_Q2_FSR: begin 
				end
				`EX_Q3_ALU: begin 
				end
				`EX_Q4_CLRF: begin 

				end
				`EX_Q4_CLRW: begin 

				end
				`EX_Q4_DECF: begin 
					if (! byteDestF) begin 
						WR <= aluResultOut;
					end
				end 
				`EX_Q4_MOVWF: begin 

				end
				`EX_Q4_MOVF: begin 
					if (! byteDestF) begin 
						WR <= gprOut;
					end
				end
				`EX_Q4_SUBWF: begin 
					if(! byteDestF) begin 
						WR <= aluResultOut;
					end
				end
				`EX_Q4_CLRWDT: begin 

				end
				`EX_Q4_OPTION: begin 

				end
				`EX_Q4_SLEEP: begin 

				end
				`EX_Q4_TRIS: begin 

				end
				`EX_Q4_FSZ: begin 
					if (!byteDestF) begin
						WR <= aluResultOut;
					end
					if (aluResultOut[2]) begin 
						skip <= 1;
					end
				end
				`EX_Q4_SWAPF: begin 
					if (!byteDestF) begin
						WR <= aluResultOut;
					end
				end 
				`EX_Q4_00_ELSE: begin 
					if (!byteDestF) begin
						WR <= aluResultOut;
					end
				end
				`EX_Q4_BXF: begin 

				end
				`EX_Q4_BTFSX: begin 
					if (IR[8]) begin // BTFSS
						if (gprOut[IR[7:5]]) begin // if set
							skip <= 1;
						end
					end
					else begin //BTFSC
						if (!gprOut[IR[7:5]]) begin // if clear
							skip <= 1;
						end
					end
				end	
				`EX_Q4_ALUXLW: begin 
					WR <= aluResultOut;
				end
				`EX_Q4_MOVLW: begin 
					WR <= IR[7:0];
				end
				`EX_Q4_GOTO: begin 
					PC <= {gprStatusOut[6:5], IR[8:0]};
					skip <= 1;
					goto <= 1;
				end
				`EX_Q4_CALL: begin 
					PC <= {gprStatusOut[6:5], 1'b0, IR[7:0]};
					skip <= 1;
					goto <= 1;
				end`EX_Q4_RETLW: begin 
					WR <= IR[7:0];
					PC <= stackOut;
					skip <= 1;
					goto <= 1;
				end
				`EX_Q4_ELSE: begin 
				end
				default : /* default */;
			endcase
		end
	end
endmodule