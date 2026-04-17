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

int param_array[MAX_PARAMS];
int param_count = 0;
int current_func_return_addr = -1;

int arg_stack[100];
int arg_stack_top = 0;
void push_arg(int t) {
    if (arg_stack_top < 100) arg_stack[arg_stack_top++] = t;
}

%}

%union {
    int nb;
    char *str;
}

%define parse.error verbose

%token <str> tID
%token <nb>  tNB
%token tMAIN tINT tCONST tPRINTF tRETURN
%token tIF tELSE tWHILE
%token tADD tSOU tMUL tDIV tASSIGN
%token tEQU tINF tSUP tAMPER
%token tLBRACE tRBRACE tLPAR tRPAR tSEMI tCOMMA
%token tAMPERSAND

%type <nb> Expression IfHeader IfBody

%left tEQU tINF tSUP
%left tADD tSOU
%left tMUL tDIV
%right tDEREF tAMPERSAND
%right tAMPER DEREF

%%

Program:
    {
        /* jump to main to avoid falling into whichever function is first */
        $<nb>$ = asm_get_line();
        asm_emit1(OP_JMP, -1);
    } Functions {
        FuncSymbol *m = lookup_function("main");
        if (m) {
            asm_patch($<nb>1, m->start_line);
        } else {
            fprintf(stderr, "Error: missing main function\n");
        }
    }
    ;

Functions:
    Function Functions
    | Function
    ;

Function:
    tINT tID {
        reset_local_symbol_table();
        param_count = 0;
    } tLPAR Parameters tRPAR tLBRACE {
        int r_addr = add_symbol("..ret..", 0, 0);
        current_func_return_addr = r_addr;
        add_function($2, asm_get_line(), r_addr, param_array, param_count);
    } Declarations Instructions tRBRACE {
        free($2);
    }
    | tINT tMAIN {
        reset_local_symbol_table();
        param_count = 0;
    } tLPAR tRPAR tLBRACE {
        int r_addr = add_symbol("..ret..", 0, 0);
        current_func_return_addr = r_addr;
        add_function("main", asm_get_line(), r_addr, NULL, 0);
    } Declarations Instructions tRBRACE
    ;

Parameters:
    /* empty */
    | ParamList
    ;

ParamList:
    Param
    | ParamList tCOMMA Param
    ;

Param:
    tINT tID {
        int addr = add_symbol($2, 0, 0);
        param_array[param_count++] = addr;
        free($2);
    }
    | tINT tMUL tID {
        int addr = add_symbol($3, 0, 1);
        param_array[param_count++] = addr;
        free($3);
    }
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
    | IfStatement
    | WhileStatement
    | tRETURN Expression tSEMI {
        asm_emit2(OP_COP, current_func_return_addr, $2);
        asm_emit0(OP_RET);
        free_temp_addr(); // free $2 logically
    }
    | error tSEMI {
        yyerrok;
    }
    ;

Declaration:
    tINT { declaring_const = 0; } DeclList tSEMI
    | tCONST { declaring_const = 1; } DeclList tSEMI
    | error tSEMI {
        yyerrok;
    }
    ;

DeclList:
    DeclItem
    | DeclList tCOMMA DeclItem
    ;

DeclItem:
    tID {
        int addr = add_symbol($1, declaring_const, 0);
        if (addr >= 0) {
            printf("/* declared '%s' at address %d */\n", $1, addr);
        }
        free($1);
    }
    | tID {
        /* Mid-rule action: register the variable BEFORE evaluating the expression,
           so that temp addresses don't collide with this variable's address. */
        $<nb>$ = add_symbol($1, declaring_const, 0);
    } tASSIGN Expression {
        int addr = $<nb>2;
        if (addr >= 0) {
            asm_emit2(OP_COP, addr, $4);
            printf("/* declared '%s' at address %d (init from temp %d) */\n", $1, addr, $4);
        }
        free($1);
    }
    | tMUL tID {
        int addr = add_symbol($2, declaring_const, 1);
        if (addr >= 0) {
            printf("/* declared '*%s' at address %d */\n", $2, addr);
        }
        free($2);
    }
    | tMUL tID {
        $<nb>$ = add_symbol($2, declaring_const, 1);
    } tASSIGN Expression {
        int addr = $<nb>2;
        if (addr >= 0) {
            asm_emit2(OP_COP, addr, $5);
            printf("/* declared '*%s' at address %d (init from temp %d) */\n", $2, addr, $5);
        }
        free($2);
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
    | tMUL Expression tASSIGN Expression tSEMI {
        asm_emit2(OP_COPW, $2, $4);
        free_temp_addr(); /* free $4 */
        free_temp_addr(); /* free $2 */
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

IfHeader:
    tIF tLPAR Expression tRPAR {
        $<nb>$ = asm_get_line();
        asm_emit2(OP_JMF, $3, -1);
        free_temp_addr();
    }
    ;

IfBody:
    IfHeader tLBRACE Instructions tRBRACE {
        $$ = $1;
    }
    ;

IfStatement:
    IfBody {
        asm_patch($1, asm_get_line());
    }
    | IfBody tELSE {
        $<nb>$ = asm_get_line();
        asm_emit1(OP_JMP, -1);
        asm_patch($1, asm_get_line());
    } tLBRACE Instructions tRBRACE {
        asm_patch($<nb>3, asm_get_line());
    }
    ;

WhileStatement:
    tWHILE {
        $<nb>$ = asm_get_line();
    } tLPAR Expression tRPAR {
        $<nb>$ = asm_get_line();
        asm_emit2(OP_JMF, $4, -1);
        free_temp_addr();
    } tLBRACE Instructions tRBRACE {
        asm_emit1(OP_JMP, $<nb>2); 
        asm_patch($<nb>6, asm_get_line());
    }
    ;

Expression:
    tNB {
        int t = get_temp_addr();
        asm_emit2(OP_AFC, t, $1);
        $$ = t;
    }
    | tID tLPAR Arguments tRPAR {
        FuncSymbol *f = lookup_function($1);
        if (f) {
            int base = arg_stack_top - f->num_params;
            for(int i = 0; i < f->num_params; i++) {
                asm_emit2(OP_COP, f->param_addresses[i], arg_stack[base + i]);
            }
            arg_stack_top = base; // pop args
            asm_emit1(OP_CALL, f->start_line);
            int t = get_temp_addr();
            asm_emit2(OP_COP, t, f->return_address);
            $$ = t;
        } else {
            $$ = 0;
        }
        free($1);
    }
    | tID {
        int addr = lookup_symbol($1);
        int t = get_temp_addr();
        asm_emit2(OP_COP, t, addr);
        $$ = t;
        free($1);
    }
    | tAMPERSAND tID {
        int addr = lookup_symbol($2);
        int t = get_temp_addr();
        asm_emit2(OP_AFC, t, addr);
        $$ = t;
        free($2);
    }
    | tMUL Expression %prec tDEREF {
        int t = get_temp_addr();
        asm_emit2(OP_COPR, t, $2);
        // Free the expression temp after dereferencing it
        free_temp_addr(); // Frees $2
        $$ = t;
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
    | Expression tEQU Expression {
        asm_emit3(OP_EQU, $1, $1, $3);
        free_temp_addr();
        $$ = $1;
    }
    | Expression tINF Expression {
        asm_emit3(OP_INF, $1, $1, $3);
        free_temp_addr();
        $$ = $1;
    }
    | Expression tSUP Expression {
        asm_emit3(OP_SUP, $1, $1, $3);
        free_temp_addr();
        $$ = $1;
    }
    | tLPAR Expression tRPAR {
        $$ = $2;
    }
    ;

Arguments:
    /* empty */
    | ArgList
    ;

ArgList:
    Expression {
        push_arg($1);
    }
    | ArgList tCOMMA Expression {
        push_arg($3);
    }
    ;

%%

void yyerror(const char *s) {
    extern int yylineno;
    extern char *yytext;
    fprintf(stderr, "Error at line %d near '%s': %s\n", yylineno, yytext, s);
}

int main() {
    if (asm_open("target.asm", "target_encoded.asm") < 0) {
        return 1;
    }
    yyparse();
    asm_close();
    return 0;
}
