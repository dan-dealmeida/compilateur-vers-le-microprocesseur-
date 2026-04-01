%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"
#include "asm_output.h"

void yyerror(const char *s);
int yylex();

/* 0 = declaring int variables, 1 = declaring const */
int declaring_const = 0;

/* Temp address pointer — reset after declarations are done */
int temp_base = 0;
%}

%union {
    int nb;
    char *str;
}

%token <str> tID
%token <nb>  tNB
%token tMAIN tINT tCONST tPRINTF
%token tADD tSOU tMUL tDIV tASSIGN
%token tLBRACE tRBRACE tLPAR tRPAR tSEMI tCOMMA

%type <nb> Expression

%left tADD tSOU
%left tMUL tDIV

%%

Program:
    tINT tMAIN tLPAR tRPAR tLBRACE { init_symbol_table(); } Body tRBRACE
    ;

Body:
    Declarations Instructions
    ;

Declarations:
    Declaration Declarations
    | /* empty */
    ;

Instructions:
    Instruction Instructions
    | /* empty */
    ;

Instruction:
    Assignment
    | Print
    ;

Declaration:
    tINT { declaring_const = 0; } DeclList tSEMI
    | tCONST { declaring_const = 1; } DeclList tSEMI
    ;

DeclList:
    DeclItem
    | DeclList tCOMMA DeclItem
    ;

DeclItem:
    tID {
        int addr = add_symbol($1, declaring_const);
        if (addr >= 0) {
            printf("/* declared '%s' at address %d */\n", $1, addr);
        }
        free($1);
    }
    | tID {
        /* Mid-rule action: register the variable BEFORE evaluating the expression,
           so that temp addresses don't collide with this variable's address. */
        $<nb>$ = add_symbol($1, declaring_const);
    } tASSIGN Expression {
        int addr = $<nb>2;
        if (addr >= 0) {
            asm_emit2(OP_COP, addr, $4);
            printf("/* declared '%s' at address %d (init from temp %d) */\n", $1, addr, $4);
        }
        free($1);
    }
    ;

Assignment:
    tID tASSIGN Expression tSEMI {
        int addr = lookup_symbol($1);
        if (addr >= 0) {
            asm_emit2(OP_COP, addr, $3);
        }
        free($1);
    }
    ;

Print:
    tPRINTF tLPAR tID tRPAR tSEMI {
        int addr = lookup_symbol($3);
        if (addr >= 0) {
            asm_emit1(OP_PRI, addr);
        }
        free($3);
    }
    ;

Expression:
    tNB {
        int t = get_temp_addr();
        asm_emit2(OP_AFC, t, $1);
        $$ = t;
    }
    | tID {
        int addr = lookup_symbol($1);
        int t = get_temp_addr();
        asm_emit2(OP_COP, t, addr);
        $$ = t;
        free($1);
    }
    | Expression tADD Expression {
        asm_emit3(OP_ADD, $1, $1, $3);
        free_temp_addr(); /* free $3 */
        $$ = $1;
    }
    | Expression tSOU Expression {
        asm_emit3(OP_SOU, $1, $1, $3);
        free_temp_addr();
        $$ = $1;
    }
    | Expression tMUL Expression {
        asm_emit3(OP_MUL, $1, $1, $3);
        free_temp_addr();
        $$ = $1;
    }
    | Expression tDIV Expression {
        asm_emit3(OP_DIV, $1, $1, $3);
        free_temp_addr();
        $$ = $1;
    }
    | tLPAR Expression tRPAR {
        $$ = $2;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    if (asm_open("target.asm", "target_encoded.asm") < 0) {
        return 1;
    }
    yyparse();
    asm_close();
    return 0;
}
