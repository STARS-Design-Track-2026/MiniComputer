`ifndef _opcodes_vh_
`define _opcodes_vh_

typedef enum logic [3:0] {
  ALU_ADD = 4'b0000,
  ALU_SUB = 4'b0001,
  ALU_MUL = 4'b0010,
  ALU_CPA = 4'b0011,
  ALU_CPB = 4'b0100
} alu_op_t;

typedef enum logic [3:0] {
  INST_ALU_ADD       = 4'h0,
  INST_ALU_SUB       = 4'h1,
  INST_ALU_MUL       = 4'h2,
  INST_ALU_CPA       = 4'h3,
  INST_ALU_CPB       = 4'h4,
  INST_LOAD_IMM      = 4'h5,
  INST_LOAD_MEM      = 4'h6,
  INST_STORE_MEM     = 4'h7,
  INST_UART_READ     = 4'h8,
  INST_UART_PRINT    = 4'h9,
  INST_JUMP          = 4'hA,
  INST_CMP           = 4'hB,
  INST_BRANCH_NEG    = 4'hC,
  INST_BRANCH_ZERO   = 4'hD,
  INST_BRANCH_CARRY  = 4'hE,
  INST_BRANCH_OVF    = 4'hF
} instr_op_t;

`endif