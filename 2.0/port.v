/*
* @Author:    tmh
* @Date:      2017-07-26 09:00:48
* @File Name: port.v
*/

`include "define.v"

module port (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [ `EX_STATE_BITS-1:0] executeState,
	input [`INST_WIDTH-1:0] IR,
	input [`DATA_WIDTH-1:0] WRIn,
	input [`IO_A_WIDTH-1:0] portAIn,
	input [`IO_B_WIDTH-1:0] portBIn,
	input [`IO_C_WIDTH-1:0] portCIn,

	output [`IO_A_WIDTH-1:0] portAO,
	output [`IO_B_WIDTH-1:0] portBO,
	output [`IO_C_WIDTH-1:0] portCO
);

reg [`IO_A_WIDTH-1:0] trisAReg;
reg [`IO_B_WIDTH-1:0] trisBReg;
reg [`IO_C_WIDTH-1:0] trisCReg;

always @(posedge clk) begin
	if(!rst_n) begin 
		trisAReg <= `IO_A_WIDTH'hF;
		trisBReg <= `IO_B_WIDTH'hFF;
		trisCReg <= `IO_C_WIDTH'hFF;
	end
	else begin 
		if (executeState == `EX_Q4_TRIS) begin 
			case (IR[2:0])
				3'b101: begin 
					trisAReg <= WRIn[`IO_A_WIDTH-1:0];
				end
				3'b110: begin 
					trisBReg <= WRIn;
				end
				3'b111: begin 
					trisCReg <= WRIn;
				end
			endcase
		end
	end
end

assign portAO = {
	trisAReg[3] ? 1'bz : portAIn[3],
	trisAReg[2] ? 1'bz : portAIn[2],
	trisAReg[1] ? 1'bz : portAIn[1],
	trisAReg[0] ? 1'bz : portAIn[0]
};
assign portBO = {
	trisBReg[7] ? 1'bz : portBIn[7],
	trisBReg[6] ? 1'bz : portBIn[6],
	trisBReg[5] ? 1'bz : portBIn[5],
	trisBReg[4] ? 1'bz : portBIn[4],
	trisBReg[3] ? 1'bz : portBIn[3],
	trisBReg[2] ? 1'bz : portBIn[2],
	trisBReg[1] ? 1'bz : portBIn[1],
	trisBReg[0] ? 1'bz : portBIn[0]
};
assign portCO = {
	trisCReg[7] ? 1'bz : portCIn[7],
	trisCReg[6] ? 1'bz : portCIn[6],
	trisCReg[5] ? 1'bz : portCIn[5],
	trisCReg[4] ? 1'bz : portCIn[4],
	trisCReg[3] ? 1'bz : portCIn[3],
	trisCReg[2] ? 1'bz : portCIn[2],
	trisCReg[1] ? 1'bz : portCIn[1],
	trisCReg[0] ? 1'bz : portCIn[0]
};

endmodule