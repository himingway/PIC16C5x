/*
* @Author:    tmh
* @Date:      2017-07-20 15:16:05
* @File Name: RegisterFile.v
*/

`include "define.v"
module RegisterFile (
	input                    clk         , // Clock
	input                    rst         , // Asynchronous reset active low
	input  [            2:0] writeCommand,
	input  [            4:0] fileAddr    ,
	input  [`DATA_WIDTH-1:0] writeDataIn ,
	input  [`DATA_WIDTH-1:0] statusIn    ,
	input  [`IO_A_WIDTH-1:0] portAIn     ,
	input  [`IO_B_WIDTH-1:0] portBIn     ,
	input  [`IO_C_WIDTH-1:0] portCIn     ,
	input  [  `PC_WIDTH-1:0] pcIn        ,
	output [`DATA_WIDTH-1:0] fsrOut      , // First Select Register out
	output [`DATA_WIDTH-1:0] regfileOut  , // regfile out
	output [`DATA_WIDTH-1:0] statusOut   , //status out
	output [`IO_A_WIDTH-1:0] portAOut    ,
	output [`IO_B_WIDTH-1:0] portBOut    ,
	output [`IO_C_WIDTH-1:0] portCOut
);

// Reg
reg[`DATA_WIDTH - 1:0] status;
reg[`DATA_WIDTH - 1:0] FSReg;
reg[`IO_A_WIDTH - 1:0] portA;
reg[`IO_B_WIDTH - 1:0] portB;
reg[`IO_C_WIDTH - 1:0] portC;

reg[`DATA_WIDTH - 1:0] indirect; // not real register
reg[`DATA_WIDTH - 1:0] direct;   // not real register

// MEM
reg [`DATA_WIDTH - 1:0] GPR [31:8];

//assign
assign fsrOut = FSReg;
assign regfileOut = (fileAddr == `ADDR_INDF) ? indirect : direct;
assign statusOut = status;
assign portAOut = portA;
assign portBOut = portB;
assign portCOut = portC;

// fsr indirect read
always @(*) begin
	case (FSReg[4:0])
		`ADDR_INDF: begin
			indirect = `DATA_WIDTH'b0;
		end
		`ADDR_TMR0: begin
			indirect = `DATA_WIDTH'b0;
		end
		`ADDR_PCL: begin
			indirect = pcIn[7:0];
		end
		`ADDR_STATUS: begin
			indirect = status;
		end
		`ADDR_FSR: begin
			indirect = FSReg;
		end
		`ADDR_PORTA: begin
			indirect = {4'b0000, portAIn};
		end
		`ADDR_PORTB: begin
			indirect = portBIn;
		end
		`ADDR_PORTC: begin
			indirect = portCIn;
		end
		5'h08, 5'h09, 5'h0A, 5'h0B, 5'h0C,5'h0D, 
		5'h0E, 5'h0F, 5'h10, 5'h11, 5'h12, 5'h13, 
		5'h14,5'h15, 5'h16, 5'h17, 5'h18, 5'h19, 
		5'h1A, 5'h1B, 5'h1C, 5'h1D, 5'h1E, 5'h1F:begin
			indirect = GPR[FSReg[4:0]];
		end
		default: ;
	endcase
end

// fsr direct read
always @(*) begin
	case (fileAddr)
		`ADDR_INDF: begin
			direct = `DATA_WIDTH'bX;
		end
		`ADDR_TMR0: begin
			direct = `DATA_WIDTH'bX;
		end
		`ADDR_PCL: begin
			direct = pcIn[7:0];
		end
		`ADDR_STATUS: begin
			direct = status;
		end
		`ADDR_FSR: begin
			direct = FSReg;
		end
		`ADDR_PORTA: begin
			direct = {4'b0000, portAIn};
		end
		`ADDR_PORTB: begin
			direct = portBIn;
		end
		`ADDR_PORTC: begin
			direct = portCIn;
		end
		5'h08, 5'h09, 5'h0A, 5'h0B, 5'h0C,5'h0D, 
		5'h0E, 5'h0F, 5'h10, 5'h11, 5'h12, 5'h13, 
		5'h14,5'h15, 5'h16, 5'h17, 5'h18, 5'h19, 
		5'h1A, 5'h1B, 5'h1C, 5'h1D, 5'h1E, 5'h1F: begin
			direct = GPR[fileAddr];
		end
		default: ;
	endcase
end

integer index;
// write block
always@(posedge clk) begin
	if(!rst) begin
			status <= `DATA_WIDTH'b0001_1xxx;
			FSReg <= `DATA_WIDTH'b1xxx_xxxx;
			portA <= `IO_A_WIDTH'bxxxx;
			portB <= `IO_B_WIDTH'bxxxx_xxxx;
			portC <= `IO_C_WIDTH'bxxxx_xxxx;
			GPR[8]  <= `DATA_WIDTH'b0000_0000;
			GPR[9]  <= `DATA_WIDTH'b0000_0000;
			GPR[10] <= `DATA_WIDTH'b0000_0000;
			GPR[11] <= `DATA_WIDTH'b0000_0000;
			GPR[12] <= `DATA_WIDTH'b0000_0000;
			GPR[13] <= `DATA_WIDTH'b0000_0000;
			GPR[14] <= `DATA_WIDTH'b0000_0000;
			GPR[15] <= `DATA_WIDTH'b0000_0000;
	end
	else begin
		case (writeCommand)
			3'b010,3'b011: begin 
				if(writeCommand == 3'b011) begin 
					status <= statusIn;
				end
				case (fileAddr)
					`ADDR_INDF: begin
						case(FSReg[4:0])
							`ADDR_INDF: begin
							end
							`ADDR_TMR0: begin
							end
							`ADDR_PCL: begin
							end
							`ADDR_STATUS: begin
								status <= {writeDataIn[7:5],status[4:3],writeDataIn[2:0]};
							end
							`ADDR_FSR: begin
								FSReg <= writeDataIn;
							end
							`ADDR_PORTA: begin
								portA <= writeDataIn[`IO_A_WIDTH - 1:0]; 
							end
							`ADDR_PORTB: begin
								portB <= writeDataIn;
							end
							`ADDR_PORTC: begin
								portC <= writeDataIn;
							end
							5'h08, 5'h09, 5'h0A, 5'h0B, 5'h0C,5'h0D, 
							5'h0E, 5'h0F, 5'h10, 5'h11, 5'h12, 5'h13, 
							5'h14,5'h15, 5'h16, 5'h17, 5'h18, 5'h19, 
							5'h1A, 5'h1B, 5'h1C, 5'h1D, 5'h1E, 5'h1F: begin
								GPR[FSReg[4:0]] <= writeDataIn;
							end
							default: ;
						endcase
					end
					`ADDR_TMR0: begin
					end
					`ADDR_PCL: begin
					end
					`ADDR_STATUS: begin
						status <= {writeDataIn[7:5],status[4:3],writeDataIn[2:0]};
					end
					`ADDR_FSR: begin
						FSReg <= writeDataIn;
					end
					`ADDR_PORTA: begin
						portA <= writeDataIn[`IO_A_WIDTH - 1:0];
					end
					`ADDR_PORTB: begin
						portB <= writeDataIn;
					end
					`ADDR_PORTC: begin
						portC <= writeDataIn;
					end
					5'h08, 5'h09, 5'h0A, 5'h0B,	5'h0C,5'h0D, 
					5'h0E, 5'h0F, 5'h10, 5'h11, 5'h12, 5'h13, 
					5'h14,5'h15, 5'h16, 5'h17, 5'h18, 5'h19, 
					5'h1A, 5'h1B, 5'h1C, 5'h1D, 5'h1E, 5'h1F: begin
						GPR[fileAddr] <= writeDataIn;
					end
					default : /* default */;
				endcase
			end
			3'b001: begin
				status <= statusIn;
			end
			3'b100: begin
				FSReg <= writeDataIn;
			end
			default : /* default */;
		endcase
	end
end

endmodule
