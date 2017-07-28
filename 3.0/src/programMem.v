/*
* @Author:    tmh
* @Date:      2017-07-25 20:49:26
* @File Name: programMem.v
*/

`include "define.v"

module programMem (
	// input clk,    // Clock
	// input rst_n,  // Asynchronous reset active low
	input [`PC_WIDTH-1:0] PCIn,
	output [`INST_WIDTH - 1:0] programMemOut // programMem out
);
	
	reg [`INST_WIDTH - 1:0] programMem [511:0];

	assign programMemOut = programMem [PCIn];
	initial begin
		$readmemh("program.mif", programMem);
		$display("Program loaded.");
	end

endmodule
