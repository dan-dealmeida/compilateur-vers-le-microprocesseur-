#include <stdio.h>
#include <stdlib.h>
#include "interp_backend.h"

Instruction instr_mem[MAX_INSTR];
int instr_count = 0;

int data_mem[MAX_MEM];
int pc = 0;
int call_stack[100];
int call_stack_top = 0;

void load_instr(int opcode, int op1, int op2, int op3) {
    if (instr_count < MAX_INSTR) {
        instr_mem[instr_count].opcode = opcode;
        instr_mem[instr_count].op1 = op1;
        instr_mem[instr_count].op2 = op2;
        instr_mem[instr_count].op3 = op3;
        instr_count++;
    } else {
        fprintf(stderr, "Error: Instruction memory full\n");
        exit(1);
    }
}

void run_interpreter(void) {
    pc = 0;
    while (pc < instr_count && pc >= 0) {
        Instruction i = instr_mem[pc];
        switch(i.opcode) {
            case 1: // ADD
                data_mem[i.op1] = data_mem[i.op2] + data_mem[i.op3];
                pc++; break;
            case 2: // MUL
                data_mem[i.op1] = data_mem[i.op2] * data_mem[i.op3];
                pc++; break;
            case 3: // SOU
                data_mem[i.op1] = data_mem[i.op2] - data_mem[i.op3];
                pc++; break;
            case 4: // DIV
                if (data_mem[i.op3] == 0) {
                    fprintf(stderr, "Interpreter Error: Division by zero\n");
                    exit(1);
                }
                data_mem[i.op1] = data_mem[i.op2] / data_mem[i.op3];
                pc++; break;
            case 5: // COP
                data_mem[i.op1] = data_mem[i.op2];
                pc++; break;
            case 6: // AFC
                data_mem[i.op1] = i.op2;
                pc++; break;
            case 7: // JMP
                pc = i.op1;
                break;
            case 8: // JMF
                if (data_mem[i.op1] == 0) {
                    pc = i.op2;
                } else {
                    pc++;
                }
                break;
            case 9: // INF
                data_mem[i.op1] = (data_mem[i.op2] < data_mem[i.op3]) ? 1 : 0;
                pc++; break;
            case 10: // SUP
                data_mem[i.op1] = (data_mem[i.op2] > data_mem[i.op3]) ? 1 : 0;
                pc++; break;
            case 11: // EQU
                data_mem[i.op1] = (data_mem[i.op2] == data_mem[i.op3]) ? 1 : 0;
                pc++; break;
            case 12: // PRI
                printf("%d\n", data_mem[i.op1]);
                pc++; break;
            case 17: // COPR
                data_mem[i.op1] = data_mem[data_mem[i.op2]];
                pc++; break;
            case 18: // COPW
                data_mem[data_mem[i.op1]] = data_mem[i.op2];
                pc++; break;
            case 15: // CALL
                call_stack[call_stack_top++] = pc + 1;
                pc = i.op1;
                break;
            case 16: // RET
                if (call_stack_top > 0) {
                    pc = call_stack[--call_stack_top];
                } else {
                    fprintf(stderr, "Interpreter Error: RET with empty stack\n");
                    exit(1);
                }
                break;
            default:
                fprintf(stderr, "Interpreter Error: Unknown opcode %d at line %d\n", i.opcode, pc);
                exit(1);
        }
    }
}
