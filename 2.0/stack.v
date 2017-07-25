/*
* @Author:    tmh
* @Date:      2017-07-19 09:15:57
* @File Name: stack.v
*/

`include "define.v"

module stack (
	input                  clk      , // Clock
	input                  rst_n    , // Asynchronous reset   active low
	input  [          1:0] commandIn, // Command input
	input  [`PC_WIDTH-1:0] in       , // Stack in
	output [`PC_WIDTH-1:0] topOut     // Stack out
);

// Reg
reg ptr;
reg [`PC_WIDTH-1:0] level [1:0];

assign topOut = level[~ptr];

always@(posedge clk) begin 
	if (!rst_n) begin 
		ptr <= 0;
		level[0] <= `PC_WIDTH'b0;
		level[1] <= `PC_WIDTH'b0;
	end
	else begin 
		case (commandIn)
				`STK_PUSH: begin 
					ptr <= ~ptr; // ++ptr
					level[ptr] <= in;
				end
				`STK_POP: begin 
					ptr <= ~ptr; // --ptr
				end
			default : /* default */;
		endcase
	end
end
endmodule