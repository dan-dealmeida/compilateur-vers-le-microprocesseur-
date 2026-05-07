%{
#include <stdio.h>
#include <stdlib.h>
#include "interp_backend.h"

int yylex();
void yyerror(const char *s);

%}

%union {
    int val;
}

%token <val> tNUMBER
%token tNEWLINE

%%

Program:
    Instructions {
        // When parsing finishes, run the CPU
        run_interpreter();
    }
    ;

Instructions:
    Instruction Instructions
    | /* empty */
    ;

Instruction:
    tNEWLINE
    | tNUMBER tNEWLINE {
        load_instr($1, 0, 0, 0);
    }
    | tNUMBER tNUMBER tNEWLINE {
        load_instr($1, $2, 0, 0);
    }
    | tNUMBER tNUMBER tNUMBER tNEWLINE {
        load_instr($1, $2, $3, 0);
    }
    | tNUMBER tNUMBER tNUMBER tNUMBER tNEWLINE {
        load_instr($1, $2, $3, $4);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Interpreter Parse Error: %s\n", s);
}

int main() {
    yyparse();
    return 0;
}
