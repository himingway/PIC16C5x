/*
* @Author:    tmh
* @Date:      2017-07-25 20:47:53
* @File Name: PIC16C55.v
*/

`include "define.v"

module PIC16C55 (
	input clk,    // Clock
	input rst_n,   // Asynchronous reset active low
	inout[`IO_A_WIDTH - 1:0] portAIO,
	inout[`IO_B_WIDTH - 1:0] portBIO,
	inout[`IO_C_WIDTH - 1:0] portCIO
);

// wire clk;
// wire rst_n;
wire [`INST_WIDTH-1:0] IR;
wire [`EX_STATE_BITS-1:0] executeState;
wire [`FE_STATE_BITS-1:0] fetchState;
wire [`DATA_WIDTH-1:0] aluResult;
wire [`ALU_STATUS_WIDTH-1:0] aluStatus;
wire [`DATA_WIDTH-1:0] gprStatus;
wire [`DATA_WIDTH-1:0] gpr;
wire [`PC_WIDTH-1:0] stack;
wire [2:0] writeCommand;
wire [`DATA_WIDTH-1:0] gprFSR;
wire [`PC_WIDTH-1:0] PC;
wire [`DATA_WIDTH-1:0] W;
wire [`INST_WIDTH - 1:0] programMem;
wire [`ALU_FUNC_WIDTH-1:0] aluFunc;
wire [`DATA_WIDTH-1:0] gprWriteData;
wire [`DATA_WIDTH-1:0] statusWriteData;
wire[`IO_A_WIDTH - 1:0] portA;
wire[`IO_B_WIDTH - 1:0] portB;
wire[`IO_C_WIDTH - 1:0] portC;
wire [1:0] stackCommand;
wire ALU_En;
wire Read_En;
wire goto;
wire skip;

port port_I(
	// IN
	.clk         (clk),
	.rst_n       (rst_n),
	.executeState(executeState),
	.IR          (IR),
	.WRIn        (W),
	.portAIn     (portA),
	.portBIn     (portB),
	.portCIn     (portC),
	// OUT
	.portAO     (portAIO),
	.portBO     (portBIO),
	.portCO     (portCIO)
);

PC PC_I(
	// IN
	.clk         (clk),
	.rst_n       (rst_n),
	.IR          (IR),
	.executeState(executeState),
	.fetchState  (fetchState),
	.aluResultIn (aluResult),
	.aluStatusIn (aluStatus),
	.gprStatusIn (gprStatus),
	.gprIn       (gpr),
	.stackIn     (stack),
	.writeCommand(writeCommand),
	.gprFSRIn    (gprFSR),
	// OUT
	.PC          (PC),
	.goto        (goto),
	.skip        (skip)
);

programMem Mem_I(
	// IN
	.PCIn(PC),
	// OUT
	.programMemOut(programMem)
);

IR IR_I(
	// IN
	.clk         (clk),
	.rst_n       (rst_n),
	.fetchState  (fetchState),
	.executeState(executeState),
	.programMemIn(programMem),
	.goto        (goto),
	.skip        (skip),
	// OUT
	.IR          (IR)
);

ControlUnit CU_I(
	// IN
	.clk         (clk),
	.rst_n       (rst_n),
	.instIn      (IR),
	// OUR
	.fetchState  (fetchState),
	.executeState(executeState),
	.aluFuncOut  (aluFunc),
	.stackCommand(stackCommand),
	.ALU_En      (ALU_En),
	.Read_En     (Read_En)
);

ALU ALU_I (
	// IN
	.wIn         (W),
	.fIn         (gpr),
	.lIn         (IR[7:0]),
	.funcIn      (aluFunc),
	.bitSel      (IR[7:5]),
	.cFlag       (gprStatus[0]),
	.ALU_En      (ALU_En),
	.statusIn    (gprStatus[3:0]),
	// OUT
	.aluStatusOut(aluStatus),
	.aluResultOut(aluResult)
);

RegFileWriteControl RegFileWC_I(
	// IN
	.fetchState        (fetchState),
	.executeState      (executeState),
	.aluResultIn       (aluResult),
	.wRIn              (W),
	.IR                (IR),
	.gprStatusIn       (gprStatus),
	.aluStatusIn       (aluStatus),
	// OUT
	.writeCommand      (writeCommand),
	.gprWriteDataOut   (gprWriteData),
	.statusWriteDataOut(statusWriteData)
); 

RegisterFile RegFile_I(
	// IN
	.clk         (clk),
	.rst         (rst_n),
	.writeCommand(writeCommand),
	.fileAddr    (IR[4:0]),
	.writeDataIn (gprWriteData),
	.statusIn    (statusWriteData),
	.portAIn     (portAIO),
	.portBIn     (portBIO),
	.portCIn     (portCIO),
	.pcIn        (PC),
	.Read_En     (Read_En),
	// OUT
	.fsrOut      (gprFSR),
	.regfileOut  (gpr),
	.statusOut   (gprStatus),
	.portAOut    (portA),
	.portBOut    (portB),
	.portCOut    (portC)
);

wRegWriteControl wRegWC_I(
	// IN
	.clk         (clk),
	.rst_n       (rst_n),
	.IR          (IR),
	.executeState(executeState),
	.aluResultIn (aluResult),
	.gprIn       (gpr),
	// OUT
	.wROut       (W)
);

stack stack_I(
	// IN
	.clk      (clk),
	.rst_n    (rst_n),
	.commandIn(stackCommand),
	.in       (PC),
	// OUT
	.topOut   (stack)
	);
endmodule