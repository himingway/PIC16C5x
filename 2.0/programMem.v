/*
* @Author:    tmh
* @Date:      2017-07-25 20:49:26
* @File Name: programMem.v
*/

module programMem (
	// input clk,    // Clock
	// input rst_n,  // Asynchronous reset active low
	input PCIn,
	output [`INST_WIDTH - 1:0] programMemOut // programMem out
);
	
	reg [`INST_WIDTH - 1:0] programMem;

	assign programMemOut = programMem [PCIn];
	initial begin
		$readmemh("program.mif", programMem);
		$display("Program loaded.");
	end

endmodule