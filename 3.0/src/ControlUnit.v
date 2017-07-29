/*
* @Author:    tmh
* @Date:      2017-07-24 21:35:44
* @File Name: ControlUnit.v
*/

`include "define.v"

module ControlUnit (
	input                        clk         , // Clock
	input                        rst_n       , // Asynchronous reset active low
	input  [    `INST_WIDTH-1:0] instIn      , // Instruction in
	output [ `FE_STATE_BITS-1:0] fetchState  , // Fetch state
	output [ `EX_STATE_BITS-1:0] executeState, // Execute State
	output [`ALU_FUNC_WIDTH-1:0] aluFuncOut  , // ALU out
	output [                1:0] stackCommand  // Stack control command
);


// Fetch & EXecute State Control
reg[`FE_STATE_BITS - 1 : 0] currentFetchState;
reg[`EX_STATE_BITS - 1 : 0] currentExecuteState;
reg[`FE_STATE_BITS - 1 : 0] nextFetchState;
reg[`EX_STATE_BITS - 1 : 0] nextExecuteState;

//execute, fetch state transition
assign fetchState = currentFetchState;
assign executeState = currentExecuteState;

assign stackCommand = 
						currentExecuteState == `EX_Q4_CALL ? 
						`STK_PUSH : (currentExecuteState == `EX_Q4_RETLW ? `STK_POP : `STK_NOP);

always @(posedge clk) begin
	if(!rst_n) begin
		currentFetchState <= `FE_Q3;
		currentExecuteState <= `EX_Q3;
	end
	else begin
		currentFetchState <= nextFetchState;
		currentExecuteState <= nextExecuteState;
	end
end

//ALU function loading
reg[`ALU_FUNC_WIDTH - 1 : 0] aluFuncRetain;
reg [`ALU_FUNC_WIDTH - 1 : 0] aluFunc;

assign aluFuncOut = aluFuncRetain;

always @(posedge clk) begin
	if (!rst_n) begin
		aluFuncRetain <= `ALU_IDLE;
	end
	else if (nextExecuteState == `EX_Q3) begin
		aluFuncRetain <= aluFunc;
	end
end

//Next execute state logic
always @(*) begin
	aluFunc = `ALU_IDLE;
	case (currentExecuteState)
		`EX_Q1: begin
			nextExecuteState = `EX_Q2;
		end
		`EX_Q2: begin
			nextExecuteState = `EX_Q3;
			casex (instIn[11:6])
				`I_ADDWF_6           : aluFunc = `ALU_ADDWF;
				`I_ANDWF_6           : aluFunc = `ALU_ANDWF;
				`I_COMF_6            : aluFunc = `ALU_COMF;
				`I_DECF_6            : aluFunc = `ALU_DECF;
				`I_DECFSZ_6          : aluFunc = `ALU_DECF;
				`I_INCF_6            : aluFunc = `ALU_INCF;
				`I_INCFSZ_6          : aluFunc = `ALU_INCF;
				`I_IORWF_6           : aluFunc = `ALU_IORWF;
				`I_RLF_6             : aluFunc = `ALU_RLF;
				`I_RRF_6             : aluFunc = `ALU_RRF;
				`I_SUBWF_6           : aluFunc = `ALU_SUBWF;
				`I_SWAPF_6           : aluFunc = `ALU_SWAPF;
				`I_XORWF_6           : aluFunc = `ALU_XORWF;
				`I_MOVF_6            : aluFunc = `ALU_MOVF;	
				{`I_BCF_4   , 2'bxx} : aluFunc = `ALU_BCF;
				{`I_BSF_4   , 2'bxx} : aluFunc = `ALU_BSF;
				{`I_ANDLW_4 , 2'bxx} : aluFunc = `ALU_ANDLW;
				{`I_IORLW_4 , 2'bxx} : aluFunc = `ALU_IORLW;
				{`I_XORLW_4 , 2'bxx} : aluFunc = `ALU_XORLW;
 				default              : aluFunc = `ALU_IDLE;
			endcase
		end
		`EX_Q3: begin
			casex(instIn)
				{`I_CLRF_7,5'bx_xxxx}: begin
					nextExecuteState = `EX_Q4_CLRF;
				end
				{`I_CLRW_12}: begin
					nextExecuteState = `EX_Q4_CLRW;
				end
				{`I_DECFSZ_6,6'bxx_xxx},
				{`I_INCFSZ_6,6'bxx_xxx}: begin
					nextExecuteState = `EX_Q4_FSZ;
				end
				{`I_MOVF_6,6'bxx_xxxx}: begin
					nextExecuteState = `EX_Q4_MOVF;
				end
				{`I_MOVWF_7,5'bx_xxxx}: begin
					nextExecuteState = `EX_Q4_MOVWF;
				end
				{`I_BTFSC_4,8'bxxxx_xxxx},
				{`I_BTFSS_4,8'bxxxx_xxxx}: begin
					nextExecuteState = `EX_Q4_BTFSX;
				end
				{`I_CALL_4,8'bxxxx_xxxx}: begin
					nextExecuteState = `EX_Q4_CALL;
				end
				{`I_CLRWDT_12}: begin
					nextExecuteState = `EX_Q4_CLRWDT;
				end
				{`I_GOTO_3,9'bx_xxxx_xxxx}: begin
					nextExecuteState = `EX_Q4_GOTO;
				end
				{`I_MOVLW_4,8'bxxxx_xxxx}: begin
					nextExecuteState = `EX_Q4_MOVLW;
				end
				{`I_OPTION_12}: begin
					nextExecuteState = `EX_Q4_OPTION;
				end
				{`I_RETLW_4,8'bxxxx_xxxx}: begin
					nextExecuteState = `EX_Q4_RETLW;
				end
				{`I_SLEEP_12}: begin
					nextExecuteState = `EX_Q4_SLEEP;
				end
				{`I_TRIS_9,3'b101},{`I_TRIS_9,3'b110},{`I_TRIS_9,3'b111}: begin
					nextExecuteState = `EX_Q4_TRIS;
				end

				{`I_ADDWF_6,6'bxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ELSE;
				end
				{`I_ANDWF_6,6'bxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ELSE;
				end
				{`I_COMF_6,6'bxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ELSE;
				end
				{`I_DECF_6,6'bxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ELSE;
				end
				{`I_INCF_6,6'bxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ELSE;
				end
				{`I_IORWF_6,6'bxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ELSE;
				end
				{`I_RLF_6,6'bxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ELSE;
				end
				{`I_RRF_6 ,6'bxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ELSE;
				end
				{`I_SUBWF_6,6'bxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ELSE;
				end
				{`I_SWAPF_6,6'bxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ELSE;
				end
				{`I_XORWF_6,6'bxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ELSE;
				end
				{`I_BCF_4,8'bxxxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_BXF;
				end
				{`I_BSF_4,8'bxxxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_BXF;
				end
				{`I_ANDLW_4,8'bxxxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ALUXLW;
				end
				{`I_IORLW_4,8'bxxxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ALUXLW;
				end
				{`I_XORLW_4,8'bxxxx_xxxx}: begin 
					nextExecuteState = `EX_Q4_ALUXLW;
				end
				default: nextExecuteState = `EX_Q4_NOP;
			endcase
		end
		`EX_Q4_CLRF,`EX_Q4_CLRW,`EX_Q4_FSZ,`EX_Q4_MOVF,`EX_Q4_MOVWF,
		`EX_Q4_BXF,`EX_Q4_BTFSX,`EX_Q4_CALL,`EX_Q4_CLRWDT,`EX_Q4_GOTO,
		`EX_Q4_MOVLW,`EX_Q4_OPTION,`EX_Q4_RETLW,`EX_Q4_SLEEP,`EX_Q4_TRIS,
		`EX_Q4_ELSE, `EX_Q4_ALUXLW,`EX_Q4_NOP: begin 
			nextExecuteState= `EX_Q1;
		end
		default nextExecuteState = `EX_Q3;
	endcase
end

//next fetch state logic
always @(*) begin
	case (currentFetchState)
		`FE_Q1: begin
			nextFetchState = `FE_Q2;
		end
		`FE_Q2: begin
			nextFetchState = `FE_Q3;
		end
		`FE_Q3: begin
			nextFetchState = `FE_Q4;
		end
		`FE_Q4: begin
			nextFetchState = `FE_Q1;
		end
	endcase
end


endmodule
