`timescale 1 ps/ 1 ps
module PIC16C55_vlg_tst();
	
// test vector input registers
reg clk;
reg [3:0] treg_portAIO;
reg [7:0] treg_portBIO;
reg [7:0] treg_portCIO;
reg rst_n;

// wires                                               
wire [3:0]  portAIO;
wire [7:0]  portBIO;
wire [7:0]  portCIO;

// assign statements (if any)                          
assign portAIO = treg_portAIO;
assign portBIO = treg_portBIO;
assign portCIO = treg_portCIO;

PIC16C55 i1 (
// port map - connection between master ports and signals/registers   
	.clk(clk),
	.portAIO(portAIO),
	.portBIO(portBIO),
	.portCIO(portCIO),
	.rst_n(rst_n)
);

initial begin
	treg_portAIO = 4'bzzzz;
	treg_portBIO = 8'bzzzz_zzzz;
	treg_portCIO = 8'bzzzz_zzzz;
	clk = 1;
	rst_n = 1;
	#5 rst_n = 0;
	#20 rst_n = 1;
	$display("Running testbench");                       
end   

always begin
	#10 clk <= ~clk;
end

endmodule

