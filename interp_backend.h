#ifndef INTERP_BACKEND_H
#define INTERP_BACKEND_H

#define MAX_INSTR 1000
#define MAX_MEM 1000

typedef struct {
    int opcode;
    int op1;
    int op2;
    int op3;
} Instruction;

void load_instr(int opcode, int op1, int op2, int op3);
void run_interpreter(void);

#endif
