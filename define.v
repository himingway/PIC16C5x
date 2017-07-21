/*
* @Author:    tmh
* @Date:      2017-07-17 19:35:39
* @File Name: define.v
*/

`ifndef _DEFINE_V_
`define _DEFINE_V_

// PORT WIDTH
`define INST_WIDTH       12
`define DATA_WIDTH       8
`define ALU_STATUS_WIDTH 3
`define BIT_SEL_WIDTH    3
`define PC_WIDTH         9

// ALU Functions
`define ALU_FUNC_WIDTH 5

`define ALU_SUBWF `ALU_FUNC_WIDTH'b0_0000
`define ALU_ADDWF `ALU_FUNC_WIDTH'b0_0001
`define ALU_ANDWF `ALU_FUNC_WIDTH'b0_0010
`define ALU_COMF  `ALU_FUNC_WIDTH'b0_0011
`define ALU_DECF  `ALU_FUNC_WIDTH'b0_0100
`define ALU_INCF  `ALU_FUNC_WIDTH'b0_0101
`define ALU_IORWF `ALU_FUNC_WIDTH'b0_0110
`define ALU_RLF   `ALU_FUNC_WIDTH'b0_0111
`define ALU_RRF   `ALU_FUNC_WIDTH'b0_1000
`define ALU_SWAPF `ALU_FUNC_WIDTH'b0_1001
`define ALU_XORWF `ALU_FUNC_WIDTH'b0_1010
`define ALU_BCF   `ALU_FUNC_WIDTH'b0_1011
`define ALU_BSF   `ALU_FUNC_WIDTH'b0_1100
`define ALU_ANDLW `ALU_FUNC_WIDTH'b0_1101
`define ALU_IORLW `ALU_FUNC_WIDTH'b0_1110
`define ALU_XORLW `ALU_FUNC_WIDTH'b0_1111
`define ALU_IDLE  `ALU_FUNC_WIDTH'b1_0000

// Instructions Set
`define OP_3BIT_WIDTH 3
`define OP_4BIT_WIDTH 4
`define OP_6BIT_WIDTH 6
`define OP_7BIT_WIDTH 7
`define OP_9BIT_WIDTH 9

// Byte-oriented operations
`define I_ADDWF_6  `OP_6BIT_WIDTH'b00_0111
`define I_ANDWF_6  `OP_6BIT_WIDTH'b00_0101
`define I_COMF_6   `OP_6BIT_WIDTH'b00_1001
`define I_DECF_6   `OP_6BIT_WIDTH'b00_0011
`define I_DECFSZ_6 `OP_6BIT_WIDTH'b00_1011
`define I_INCF_6   `OP_6BIT_WIDTH'b00_1010
`define I_INCFSZ_6 `OP_6BIT_WIDTH'b00_1111
`define I_IORWF_6  `OP_6BIT_WIDTH'b00_0100
`define I_MOVF_6   `OP_6BIT_WIDTH'b00_1000
`define I_RLF_6    `OP_6BIT_WIDTH'b00_1101
`define I_RRF_6    `OP_6BIT_WIDTH'b00_1100
`define I_SUBWF_6  `OP_6BIT_WIDTH'b00_0010
`define I_SWAPF_6  `OP_6BIT_WIDTH'b00_1110
`define I_XORWF_6  `OP_6BIT_WIDTH'b00_0110

`define I_CLRF_7   `OP_7BIT_WIDTH'b000_0011
`define I_MOVWF_7  `OP_7BIT_WIDTH'b000_0001

`define I_NOP_12   `INST_WIDTH'b0000_0000_0000
`define I_CLRW_12  `INST_WIDTH'b0000_0100_0000

// Bit-oriented operations
`define I_BCF_4    `OP_4BIT_WIDTH'b0100
`define I_BSF_4    `OP_4BIT_WIDTH'b0101
`define I_BTFSC_4  `OP_4BIT_WIDTH'b0110
`define I_BTFSS_4  `OP_4BIT_WIDTH'b0111

// Literal amd Control operations 
`define I_GOTO_3   `OP_3BIT_WIDTH'b101

`define I_ANDLW_4  `OP_4BIT_WIDTH'b1110
`define I_CALL_4   `OP_4BIT_WIDTH'b1001
`define I_IORLW_4  `OP_4BIT_WIDTH'b1101
`define I_MOVLW_4  `OP_4BIT_WIDTH'b1100
`define I_RETLW_4  `OP_4BIT_WIDTH'b1000
`define I_XORLW_4  `OP_4BIT_WIDTH'b1111

`define I_TRIS_9   `OP_9BIT_WIDTH'b0_0000_0000

`define I_CLRWDT_12 `INST_WIDTH'b0000_0000_0100
`define I_OPTION_12 `INST_WIDTH'b0000_0000_0010
`define I_SLEEP_12  `INST_WIDTH'b0000_0000_0011

// Fetch
`define FE_STATE_BITS   2

`define FE_Q1_INCPC `FE_STATE_BITS'b00
`define FE_Q2_IDLE  `FE_STATE_BITS'b01
`define FE_Q3_IDLE  `FE_STATE_BITS'b10
`define FE_Q4_FETCH `FE_STATE_BITS'b11

// Execute
`define EX_STATE_BITS   5

`define EX_Q1_TEST_SKIP `CU_EX_STATE_BITS'b00001 //Q1
`define EX_Q2_FSR       `CU_EX_STATE_BITS'b00010 //Q2
`define EX_Q3_ALU       `CU_EX_STATE_BITS'b00100 //Q3
`define EX_Q4_CLRF      `CU_EX_STATE_BITS'b01000 //Q4

`define EX_Q4_CLRW    `CU_EX_STATE_BITS'b01001
`define EX_Q4_DECF    `CU_EX_STATE_BITS'b01010
`define EX_Q4_MOVWF   `CU_EX_STATE_BITS'b01011
`define EX_Q4_SUBWF   `CU_EX_STATE_BITS'b01100
`define EX_Q4_CLRWDT  `CU_EX_STATE_BITS'b01101
`define EX_Q4_OPTION  `CU_EX_STATE_BITS'b01110
`define EX_Q4_SLEEP   `CU_EX_STATE_BITS'b01111
`define EX_Q4_TRIS    `CU_EX_STATE_BITS'b10000
`define EX_Q4_FSZ     `CU_EX_STATE_BITS'b10001
`define EX_Q4_SWAPF   `CU_EX_STATE_BITS'b10010
`define EX_Q4_00_ELSE `CU_EX_STATE_BITS'b10011
`define EX_Q4_BXF     `CU_EX_STATE_BITS'b10100
`define EX_Q4_BTFSX   `CU_EX_STATE_BITS'b10101
`define EX_Q4_ALUXLW  `CU_EX_STATE_BITS'b10110 //AND, IOR, XOR
`define EX_Q4_MOVLW   `CU_EX_STATE_BITS'b10111
`define EX_Q4_GOTO    `CU_EX_STATE_BITS'b11000
`define EX_Q4_CALL    `CU_EX_STATE_BITS'b11001
`define EX_Q4_RETLW   `CU_EX_STATE_BITS'b11010
`define EX_Q4_ELSE    `CU_EX_STATE_BITS'b11011
`define EX_Q4_MOVF    `CU_EX_STATE_BITS'b11100

// Stack
`define STK_NOP  2'b00
`define STK_PUSH 2'b01
`define STK_POP  2'b10

// Reg
`define ADDR_INDF   5'b0_0000
`define ADDR_TMR0   5'b0_0001
`define ADDR_PCL    5'b0_0010
`define ADDR_STATUS 5'b0_0011
`define ADDR_FSR    5'b0_0100
`define ADDR_PROTA  5'b0_0101
`define ADDR_PROTB  5'b0_0110
`define ADDR_PROTC  5'b0_0111

`endif 