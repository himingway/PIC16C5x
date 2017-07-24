/*
* @Author:    tmh
* @Date:      2017-07-19 10:25:31
* @File Name: PIC16C55.v
*/

`include "define.v"

module PIC16C55 (
	input clk,    // Clock
	input rst  // Asynchronous reset active low
);

	// Memory
	reg [`INST_WIDTH-1:0] MEM [511:0]; // 12*512 memory

	// Reg
	reg [`PC_WIDTH-1:0]   PC; // Program count
	reg [`INST_WIDTH-1:0] IR; // Instruction Register
	reg [`DATA_WIDTH-1:0] WR; // W Reg
	reg [`DATA_WIDTH-1:0] fsrIndWriteData;
	reg [`DATA_WIDTH-1:0] statusWriteData;
	reg skip;
	reg goto;
	reg writeQ4Result;
	reg writeStatus;
	
	// Wire
	wire [`FE_STATE_BITS-1:0]    fetchState;
	wire [`EX_STATE_BITS-1:0]    executeState;
	wire [`ALU_FUNC_WIDTH-1:0]   aluFunc;
	wire                         byteDestF;
	wire [`ALU_STATUS_WIDTH-1:0] aluStatusOut;
	wire [`DATA_WIDTH-1:0]       aluResultOut;
	wire [2:0]                   writeCommand;
	wire [`DATA_WIDTH-1:0]       gprOut;
	wire [`DATA_WIDTH-1:0]       gprFSROut;
	wire [`DATA_WIDTH-1:0]       gprStatusOut;
	wire [`PC_WIDTH-1:0]         stackIn;
	wire [1:0]                   stackCommand;
	wire [`PC_WIDTH-1:0]         stackOut;


	//Assign
	assign stackIn = PC;
	assign byteDestF = IR[5];
	assign writeCommand = {executeState == `EX_Q2_FSR, // write FSR
		                       writeQ4Result, // write Q4 result to the register pointed to by FSR
		                       writeStatus};  // write status
	assign stackCommand = executeState == `EX_Q4_CALL ? `STK_PUSH : 
												(executeState == `EX_Q4_RETLW ? `STK_POP : `STK_NOP);	                       
	// Stack
  stack Stack_Ins (
  	.clk(clk),
  	.rst(rst),
  	.commandIn(stackCommand),
  	.in(stackIn),
  	.topOut(stackOut)
		);

	// Decoder
	decoder Decoder_Ins(
		.clk          (clk),
		.rst          (rst),
		.instIn       (IR),
		.fetchState   (fetchState),
		.executeState (executeState),
		.aluFuncOut   (aluFunc)
		);

	// ALU 
	alu ALU_Ins(
		.WIn       (WR),
		.fIn       (gprOut),
		.lIn       (IR[7:0]),
		.funcIn    (aluFunc),
		.bitSel    (IR[7:5]),
		.cFLag     (gprStatusOut[0]),
		.aluStatusOut (aluStatusOut),
		.resultOut (aluResultOut)
		);
	
	// RegisterFile
	RegisterFile RegFile_Ins(
		.clk          (clk),
		.rst          (rst),
		.writeCommand (writeCommand),
		.fileAddr     (IR[4:0]),
		.writeDataIn  (fsrIndWriteData),
		.statusIn     (statusWriteData),
		.pcIn         (PC),
		.fsrOut       (gprFSROut),
		.regfileOut   (gprOut),
		.statusOut    (gprStatusOut)
		);

	initial begin
		$readmemh("program.mif", MEM);
	end

	//Combination Logic

	//writeQ4Result, fsrIndWriteData decision
	always @(*) begin
		case(executeState)
			`EX_Q2_FSR: begin 
				writeQ4Result = 1'b0;
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
			`EX_Q4_FSZ, `EX_Q4_DECF, `EX_Q4_SUBWF, `EX_Q4_SWAPF, `EX_Q4_00_ELSE: begin 
				if(byteDestF) begin 
					writeQ4Result = 1'b1;
					fsrIndWriteData = aluResultOut;
				end
				else begin 
					writeQ4Result = 1'b0;
					fsrIndWriteData = aluResultOut;
				end
			end
			default: begin 
				writeQ4Result = 0;
				fsrIndWriteData = 0;
			end
		endcase
	end


	always @(*) begin
		case (executeState)
			`EX_Q4_CLRF: begin 
				writeStatus = 1'b1;
				statusWriteData = {gprStatusOut[7:3],1'b1,gprStatusOut[1:0]};
			end
			`EX_Q4_CLRW: begin 
				writeStatus = 1'b1;
				statusWriteData = {gprStatusOut[7:3],1'b1,gprStatusOut[1:0]};
			end
			`EX_Q4_MOVF: begin 
				writeStatus = 1'b1;
				statusWriteData = {gprStatusOut[7:3],1'b1,gprStatusOut[1:0]};
			end
			`EX_Q4_DECF, `EX_Q4_SUBWF, 
			`EX_Q4_00_ELSE,
			`EX_Q4_ALUXLW: begin 
				writeStatus = 1'b1;
				statusWriteData = {gprStatusOut[7:3],aluStatusOut};
			end
			default: begin 
				writeStatus = 0;
				statusWriteData = 0;
			end
		endcase
	end

	always @(posedge clk or negedge rst) begin
		if (!rst) begin 
			PC <= `PC_WIDTH'b0;
			IR <= `I_NOP_12;
			WR <= `DATA_WIDTH'b0;
			skip <= 1'b0;
			goto <= 1'b0;
		end
		else begin 
			case (fetchState)
				`FE_Q1_INCPC: begin
					if (!goto) begin
						PC <= PC +1'b1;
					end
				end
				`FE_Q2_IDLE, `FE_Q3_IDLE: begin
					// Do nothing 
				end
				`FE_Q4_FETCH: begin 
					IR <= MEM [PC];
				end
				//default : /* default */;
			endcase

			case (executeState)
				`EX_Q1_TEST_SKIP: begin 
					if (skip | goto) begin
						skip <= 0;
						goto <= 0;
						IR <= `I_NOP_12;
					end
				end
				`EX_Q2_FSR: begin 
				end
				`EX_Q3_ALU: begin 
				end
				`EX_Q4_CLRF: begin 

				end
				`EX_Q4_CLRW: begin 
					WR <= 0;
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
					PC <= IR[8:0];
					skip <= 1;
					goto <= 1;
				end
				`EX_Q4_CALL: begin 
					PC <= {1'b0, IR[7:0]};
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
			endcase
		end
	end
endmodule
