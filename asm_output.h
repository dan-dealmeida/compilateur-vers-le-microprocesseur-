#ifndef ASM_OUTPUT_H
#define ASM_OUTPUT_H

#include <stdio.h>

/* Opcode definitions from the PDF */
#define OP_ADD  1
#define OP_MUL  2
#define OP_SOU  3
#define OP_DIV  4
#define OP_COP  5
#define OP_AFC  6
#define OP_JMP  7
#define OP_JMF  8
#define OP_INF  9
#define OP_SUP  10
#define OP_EQU  11
#define OP_PRI  12

/* Open the two output files. Returns 0 on success, -1 on error. */
int asm_open(const char *text_filename, const char *encoded_filename);

/* Close both output files. */
void asm_close(void);

/* Emit a 3-operand instruction (ADD, SOU, MUL, DIV, INF, SUP, EQU) */
void asm_emit3(int opcode, int dest, int op1, int op2);

/* Emit a 2-operand instruction (COP) */
void asm_emit2(int opcode, int dest, int src);

/* Emit a 1-operand instruction (PRI, JMP) */
void asm_emit1(int opcode, int operand);

/* Get the current instruction number (for jump patching later) */
int asm_get_line(void);

/* Patch a previously emitted jump instruction with its resolved target line */
void asm_patch(int instruction_line, int jump_target_line);

#endif
