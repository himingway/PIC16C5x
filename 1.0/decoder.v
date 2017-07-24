/*
* @Author:    tmh
* @Date:      2017-07-18 10:54:17
* @File Name: decoder.v
*/

`include "define.v"

module decoder (
	input clk,    // Clock
	input rst,  // Asynchronous reset active low
	input [`INST_WIDTH-1:0] instIn, // Instruction in
	output [`ALU_FUNC_WIDTH-1:0] aluFuncOut,   // ALU function out
	output [`FE_STATE_BITS-1:0]  fetchState,   // Fetch tate out
	output [`EX_STATE_BITS-1:0]  executeState // Execute state out
);
	
	// Reg
	reg [`FE_STATE_BITS-1:0]  currentFetchState;
	reg [`EX_STATE_BITS-1:0]  currentExecuteState;
	reg [`FE_STATE_BITS-1:0]  nextFetchState;
	reg [`EX_STATE_BITS-1:0]  nextExecuteState;
	reg [`ALU_FUNC_WIDTH-1:0] aluFuncRetain;
	reg [`ALU_FUNC_WIDTH-1:0] aluFunc;

	// Assign
	assign aluFuncOut   = aluFuncRetain;
	assign fetchState   = currentFetchState;
	assign executeState = currentExecuteState;

	// Sequence logic
	always@(posedge clk or negedge rst) begin
		if (!rst) begin 
			currentExecuteState <= `EX_Q3_ALU;
			currentFetchState <= `FE_Q3_IDLE;
		end
		else begin
			currentExecuteState <= nextExecuteState;
			currentFetchState <= nextFetchState;
		end
	end

	always @(posedge clk or negedge rst) begin
		if(!rst) begin
			aluFuncRetain <= `ALU_IDLE;
		end 
		else if (nextExecuteState == `EX_Q3_ALU) begin
			aluFuncRetain <= aluFunc;
		end
	end

	// Combination logic
	always @(*) begin
		aluFunc = `ALU_IDLE;
		case(currentExecuteState)
			`EX_Q1_TEST_SKIP: begin
				nextExecuteState = `EX_Q2_FSR;
			end
			`EX_Q2_FSR: begin
				nextExecuteState = `EX_Q3_ALU;
				if (instIn[11:10] == 2'b00) begin
					case(instIn[11:6])
						`I_ADDWF_6: begin 
							aluFunc = `ALU_ADDWF;
						end
						`I_ANDWF_6: begin
							aluFunc = `ALU_ANDWF;
						end
						`I_COMF_6: begin 
							aluFunc = `ALU_COMF;
						end
						`I_DECF_6: begin
							aluFunc = `ALU_DECF;
						end
						`I_DECFSZ_6: begin
							aluFunc = `ALU_DECF;
						end
						`I_INCF_6: begin
							aluFunc = `ALU_INCF;
						end
						`I_INCFSZ_6: begin
							aluFunc = `ALU_INCF;
						end
						`I_IORWF_6: begin
							aluFunc = `ALU_IORWF;
						end
						`I_RLF_6: begin
							aluFunc = `ALU_RLF;
						end
						`I_RRF_6: begin
							aluFunc = `ALU_RRF;
						end
						`I_SUBWF_6: begin
							aluFunc = `ALU_SUBWF;
						end
						`I_SWAPF_6:begin
							aluFunc = `ALU_SWAPF;
						end
						`I_XORWF_6: begin
							aluFunc = `ALU_XORWF;
						end
					endcase
				end
				else if (instIn[11:10] == 2'b01) begin 
					case(instIn[11:8])
						`I_BCF_4: begin 
							aluFunc = `ALU_BCF;
						end
						`I_BSF_4: begin 
							aluFunc = `ALU_BSF;
						end
					endcase
				end
				else if (instIn[11:10] == 2'b11) begin 
					case (instIn[11:8])
						`I_ANDLW_4: begin 
							aluFunc = `ALU_ANDLW;
						end
						`I_IORLW_4: begin
							aluFunc = `ALU_IORLW;
						end
						`I_XORLW_4: begin
							aluFunc = `ALU_XORLW;
						end
					endcase
				end
			end
			`EX_Q3_ALU: begin 
				if(instIn[11:8] == 4'b0000)begin 
					casex(instIn)
						{`I_CLRF_7,5'bx_xxxx}: begin 
							nextExecuteState = `EX_Q4_CLRF;
						end
						{`I_CLRW_12}:begin 
							nextExecuteState = `EX_Q4_CLRW;
						end
						{`I_DECF_6,6'bxx_xxxx}: begin
							nextExecuteState = `EX_Q4_DECF;
						end
						{`I_MOVWF_7,5'bx_xxxx}: begin
							nextExecuteState = `EX_Q4_MOVWF;
						end
						{`I_SUBWF_6,6'bxx_xxxx}: begin
							nextExecuteState = `EX_Q4_SUBWF;
						end
						{`I_CLRWDT_12}: begin
							nextExecuteState = `EX_Q4_CLRF;
						end
						{`I_OPTION_12}: begin 
							nextExecuteState = `EX_Q4_OPTION;
						end
						{`I_SLEEP_12}: begin
							nextExecuteState = `EX_Q4_SLEEP;
						end
						{`I_TRIS_9,3'b101},{`I_TRIS_9,3'b110},{`I_TRIS_9,3'b111}: begin
							nextExecuteState = `EX_Q4_TRIS;
						end
						default: begin
							nextExecuteState = `EX_Q4_ELSE;
						end
					endcase
				end
				else if (instIn[11:10] == 2'b00) begin
					case (instIn[11:6])
						`I_INCFSZ_6, `I_DECF_6: begin
							nextExecuteState = `EX_Q4_FSZ;
						end
						`I_SWAPF_6: begin 
							nextExecuteState = `EX_Q4_SWAPF;
						end
						`I_MOVF_6: begin 
							nextExecuteState = `EX_Q4_MOVF;
						end
						default: begin
							nextExecuteState = `EX_Q4_00_ELSE;
						end
					endcase
				end
				else if (instIn[11:10] == 2'b01) begin
					case (instIn[11:8])
						`I_BCF_4, `I_BSF_4: begin 
							nextExecuteState = `EX_Q4_BXF;
						end
						`I_BTFSC_4, `I_BTFSS_4: begin 
							nextExecuteState = `EX_Q4_BTFSX;
						end
						default: begin 
							nextExecuteState = `EX_Q4_ELSE;
						end
					endcase
				end
				else begin
					casex(instIn[11:8])
						`I_ANDLW_4, `I_IORLW_4, `I_XORLW_4: begin
							nextExecuteState = `EX_Q4_ALUXLW;
						end
						`I_MOVLW_4: begin
							nextExecuteState = `EX_Q4_MOVLW;
						end
						{`I_GOTO_3, 1'bx}: begin
							nextExecuteState = `EX_Q4_GOTO;
						end
						`I_CALL_4: begin 
							nextExecuteState = `EX_Q4_CALL;
						end
						`I_RETLW_4: begin
							nextExecuteState = `EX_Q4_RETLW;
						end
						default: begin 
							nextExecuteState = `EX_Q4_ELSE;
						end
					endcase
				end
			end
			`EX_Q4_CLRF, `EX_Q4_CLRW, `EX_Q4_DECF, `EX_Q4_MOVWF, `EX_Q4_MOVF,
			`EX_Q4_SUBWF, `EX_Q4_CLRWDT, `EX_Q4_OPTION, `EX_Q4_SLEEP,
			`EX_Q4_TRIS, `EX_Q4_FSZ, `EX_Q4_SWAPF, `EX_Q4_00_ELSE,
			`EX_Q4_BXF, `EX_Q4_BTFSX,	`EX_Q4_ALUXLW, `EX_Q4_MOVLW,
			`EX_Q4_GOTO, `EX_Q4_CALL,	`EX_Q4_RETLW,	`EX_Q4_ELSE: begin
				nextExecuteState = `EX_Q1_TEST_SKIP;
			end
			default : begin
				nextExecuteState = `EX_Q1_TEST_SKIP;
			end
		endcase
	end

	always @(*) begin
		case (currentFetchState)
			`FE_Q1_INCPC: begin 
				nextFetchState = `FE_Q2_IDLE;
			end
			`FE_Q2_IDLE: begin 
				nextFetchState = `FE_Q3_IDLE;
			end
			`FE_Q3_IDLE: begin 
				nextFetchState = `FE_Q4_FETCH;
			end
			`FE_Q4_FETCH: begin 
				nextFetchState = `FE_Q1_INCPC;
			end
		endcase
	end

endmodule