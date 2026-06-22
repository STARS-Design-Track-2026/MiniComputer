// UART decimal factorial program for minicomp ISA
//
// Behavior:
// 1) Repeatedly read ASCII digits until '\n' or '\r'.
// 2) Convert to integer with acc = acc*10 + digit.
// 3) Compute factorial(acc).
// 4) Print three decimal digits (hundreds/tens/ones), then '\n'.
//
// Notes:
// - PC is 8-bit, so code must fit in 64 instructions.
// - Output is fixed width (3 digits) to stay compact.

3015  // 0x00: R3  <- 1
40A5  // 0x04: R4  <- 10
5305  // 0x08: R5  <- '0' (48)
60A5  // 0x0C: R6  <- '\n' (10)
F0D5  // 0x10: R15 <- '\r' (13)
B442  // 0x14: R11 <- R4 * R4 = 100
01CA  // 0x18: jump MAIN_LOOP

1005  // 0x1C: MAIN_LOOP: R1 <- 0 (accumulator)
E4C5  // 0x20: R14 <- INPUT_DONE (0x4C)
0008  // 0x24: INPUT_LOOP: UART_READ  R0
060B  // 0x28: CMP R0, R6
00ED  // 0x2C: BRANCH_ZERO  R14
0F0B  // 0x30: CMP R0, R15
00ED  // 0x34: BRANCH_ZERO  R14
0009  // 0x38: UART_PRINT R0         (echo digit)
0501  // 0x3C: R0 <- R0 - R5         (ASCII to digit)
1412  // 0x40: R1 <- R1 * R4
1010  // 0x44: R1 <- R1 + R0
024A  // 0x48: jump INPUT_LOOP

00F9  // 0x4C: INPUT_DONE: UART_PRINT R15 ('\r', echo Enter)
0069  // 0x50: UART_PRINT R6 ('\n')

2015  // 0x54: R2 <- 1   (factorial result)
7013  // 0x58: R7 <- R1              (counter i)
E805  // 0x5C: R14 <- FACT_DONE (0x80)
C745  // 0x60: R12 <- FACT_BODY (0x74)
037B  // 0x64: FACT_LOOP: CMP R7, R3
00ED  // 0x68: BRANCH_ZERO R14
00CE  // 0x6C: BRANCH_CARRY R12
080A  // 0x70: jump FACT_DONE (0x80)
2722  // 0x74: FACT_BODY: R2 <- R2 * R7
7371  // 0x78: R7 <- R7 - R3
064A  // 0x7C: jump FACT_LOOP (0x64)

8023  // 0x80: FACT_DONE: R8 <- R2 (remaining)

9005  // 0x84: DIGIT_100: R9 <- 0
E985  // 0x88: R14 <- SUB100 (0x98)
0B8B  // 0x8C: CMP R8, R11
00EE  // 0x90: BRANCH_CARRY R14
0A4A  // 0x94: jump EMIT100 (0xA4)
8B81  // 0x98: SUB100: R8 <- R8 - R11
9390  // 0x9C: R9 <- R9 + R3
08CA  // 0xA0: jump 0x8C
0590  // 0xA4: EMIT100: R0 <- R9 + R5
0009  // 0xA8: UART_PRINT R0

9005  // 0xAC: DIGIT_10: R9 <- 0
EC05  // 0xB0: R14 <- SUB10 (0xC0)
048B  // 0xB4: CMP R8, R4
00EE  // 0xB8: BRANCH_CARRY R14
0CCA  // 0xBC: jump EMIT10 (0xCC)
8481  // 0xC0: SUB10: R8 <- R8 - R4
9390  // 0xC4: R9 <- R9 + R3
0B4A  // 0xC8: jump 0xB4
0590  // 0xCC: EMIT10: R0 <- R9 + R5
0009  // 0xD0: UART_PRINT R0

0580  // 0xD4: DIGIT_1: R0 <- R8 + R5
0009  // 0xD8: UART_PRINT R0
00F9  // 0xDC: UART_PRINT R15 ('\r')
0069  // 0xE0: UART_PRINT R6 ('\n')
01CA  // 0xE4: jump MAIN_LOOP
