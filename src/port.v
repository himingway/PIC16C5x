/*
* @Author:    tmh
* @Date:      2017-07-26 09:00:48
* @File Name: port.v
*/

`include "define.v"

module port (
	input                       clk         , // Clock
	input                       rst_n       , // Asynchronous reset active low
	input  [`EX_STATE_BITS-1:0] executeState,
	input  [               2:0] IR          ,
	input  [   `DATA_WIDTH-1:0] WRIn        ,
	output [`IO_A_WIDTH-1:0] trisAReg,
	output [`IO_B_WIDTH-1:0] trisBReg,
	output [`IO_C_WIDTH-1:0] trisCReg

);

reg [`IO_A_WIDTH-1:0] rtrisAReg;
reg [`IO_B_WIDTH-1:0] rtrisBReg;
reg [`IO_C_WIDTH-1:0] rtrisCReg;

assign trisAReg = rtrisAReg;
assign trisBReg = rtrisBReg;
assign trisCReg = rtrisCReg;

always @(posedge clk) begin
	if(!rst_n) begin 
		rtrisAReg <= `IO_A_WIDTH'hF;
		rtrisBReg <= `IO_B_WIDTH'hFF;
		rtrisCReg <= `IO_C_WIDTH'hFF;
	end
	else begin 
		if (executeState == `EX_Q4_TRIS) begin 
			case (IR[2:0])
				3'b101: begin 
					rtrisAReg <= WRIn[`IO_A_WIDTH-1:0];
				end
				3'b110: begin 
					rtrisBReg <= WRIn;
				end
				3'b111: begin 
					rtrisCReg <= WRIn;
				end
			endcase
		end
	end
end

endmodule