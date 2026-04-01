#include <stdio.h>
#include <stdlib.h>
#include "asm_output.h"

static FILE *f_text = NULL;     /* plain-text assembly file */
static FILE *f_encoded = NULL;  /* encoded (numeric) assembly file */
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
    if (f_text)    { fclose(f_text);    f_text = NULL; }
    if (f_encoded) { fclose(f_encoded); f_encoded = NULL; }
}

/* 3-operand: ADD, SOU, MUL, DIV, INF, SUP, EQU */
void asm_emit3(int opcode, int dest, int op1, int op2) {
    /* Plain-text: "ADD 5 3 4" */
    fprintf(f_text, "%s %d %d %d\n", opcode_name(opcode), dest, op1, op2);
    /* Encoded:    "1 5 3 4" */
    fprintf(f_encoded, "%d %d %d %d\n", opcode, dest, op1, op2);
    /* Also print to stdout for debugging */
    printf("%s %d %d %d\n", opcode_name(opcode), dest, op1, op2);
    line_num++;
}

/* 2-operand: COP, AFC */
void asm_emit2(int opcode, int dest, int src) {
    fprintf(f_text, "%s %d %d\n", opcode_name(opcode), dest, src);
    fprintf(f_encoded, "%d %d %d\n", opcode, dest, src);
    printf("%s %d %d\n", opcode_name(opcode), dest, src);
    line_num++;
}

/* 1-operand: PRI, JMP */
void asm_emit1(int opcode, int operand) {
    fprintf(f_text, "%s %d\n", opcode_name(opcode), operand);
    fprintf(f_encoded, "%d %d\n", opcode, operand);
    printf("%s %d\n", opcode_name(opcode), operand);
    line_num++;
}

int asm_get_line(void) {
    return line_num;
}
