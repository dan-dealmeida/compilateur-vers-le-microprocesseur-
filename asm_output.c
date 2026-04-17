#include <stdio.h>
#include <stdlib.h>
#include "asm_output.h"

#define MAX_INS 1000

typedef struct {
    int opcode;
    int op1;
    int op2;
    int op3;
} Instruction;

static FILE *f_text = NULL;     /* plain-text assembly file */
static FILE *f_encoded = NULL;  /* encoded (numeric) assembly file */
static Instruction instr_buffer[MAX_INS];
static int line_num = 0;        /* current instruction number */

/* Maps opcode number to mnemonic string */
static const char *opcode_name(int opcode) {
    switch (opcode) {
        case OP_ADD: return "ADD";
        case OP_MUL: return "MUL";
        case OP_SOU: return "SOU";
        case OP_DIV: return "DIV";
        case OP_COP: return "COP";
        case OP_AFC: return "AFC";
        case OP_JMP: return "JMP";
        case OP_JMF: return "JMF";
        case OP_INF: return "INF";
        case OP_SUP: return "SUP";
        case OP_EQU: return "EQU";
        case OP_PRI: return "PRI";
        case OP_RDIN: return "RDIN";
        case OP_WRIN: return "WRIN";
        case OP_CALL: return "CALL";
        case OP_RET:  return "RET";
        case OP_COPR: return "COPR";
        case OP_COPW: return "COPW";
        default:     return "???";
    }
}

int asm_open(const char *text_filename, const char *encoded_filename) {
    f_text = fopen(text_filename, "w");
    if (!f_text) {
        perror("Error opening text assembly file");
        return -1;
    }
    f_encoded = fopen(encoded_filename, "w");
    if (!f_encoded) {
        perror("Error opening encoded assembly file");
        fclose(f_text);
        f_text = NULL;
        return -1;
    }
    line_num = 0;
    return 0;
}

void asm_close(void) {
    for (int i = 0; i < line_num; i++) {
        int op = instr_buffer[i].opcode;
        int a = instr_buffer[i].op1;
        int b = instr_buffer[i].op2;
        int c = instr_buffer[i].op3;

        if (op == OP_PRI || op == OP_JMP || op == OP_CALL || op == OP_RET) {
            fprintf(f_text, "%s %d\n", opcode_name(op), a);
            fprintf(f_encoded, "%d %d\n", op, a);
            printf("%s %d\n", opcode_name(op), a);
        } else if (op == OP_COP || op == OP_AFC || op == OP_JMF || op == OP_COPR || op == OP_COPW || op == OP_RDIN || op == OP_WRIN) {
            fprintf(f_text, "%s %d %d\n", opcode_name(op), a, b);
            fprintf(f_encoded, "%d %d %d\n", op, a, b);
            printf("%s %d %d\n", opcode_name(op), a, b);
        } else {
            fprintf(f_text, "%s %d %d %d\n", opcode_name(op), a, b, c);
            fprintf(f_encoded, "%d %d %d %d\n", op, a, b, c);
            printf("%s %d %d %d\n", opcode_name(op), a, b, c);
        }
    }

    if (f_text)    { fclose(f_text);    f_text = NULL; }
    if (f_encoded) { fclose(f_encoded); f_encoded = NULL; }
}

/* 3-operand: ADD, SOU, MUL, DIV, INF, SUP, EQU */
void asm_emit3(int opcode, int dest, int op1, int op2) {
    if (line_num >= MAX_INS) return;
    instr_buffer[line_num].opcode = opcode;
    instr_buffer[line_num].op1 = dest;
    instr_buffer[line_num].op2 = op1;
    instr_buffer[line_num].op3 = op2;
    line_num++;
}

/* 2-operand: COP, AFC, JMF */
void asm_emit2(int opcode, int dest, int src) {
    if (line_num >= MAX_INS) return;
    instr_buffer[line_num].opcode = opcode;
    instr_buffer[line_num].op1 = dest;
    instr_buffer[line_num].op2 = src;
    line_num++;
}

/* 1-operand: PRI, JMP, CALL */
void asm_emit1(int opcode, int operand) {
    if (line_num >= MAX_INS) return;
    instr_buffer[line_num].opcode = opcode;
    instr_buffer[line_num].op1 = operand;
    line_num++;
}

/* 0-operand: RET */
void asm_emit0(int opcode) {
    if (line_num >= MAX_INS) return;
    instr_buffer[line_num].opcode = opcode;
    line_num++;
}

int asm_get_line(void) {
    return line_num;
}

void asm_patch(int instruction_line, int jump_target_line) {
    if (instruction_line < 0 || instruction_line >= line_num) return;
    
    if (instr_buffer[instruction_line].opcode == OP_JMP) {
        instr_buffer[instruction_line].op1 = jump_target_line;
    } else if (instr_buffer[instruction_line].opcode == OP_JMF) {
        instr_buffer[instruction_line].op2 = jump_target_line;
    } else {
        fprintf(stderr, "Error: trying to patch a non-jump instruction\n");
    }
}
