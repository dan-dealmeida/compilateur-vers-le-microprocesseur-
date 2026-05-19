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
int compiler_error_count = 0;

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

static void compiler_error(const char *message, const char *name) {
    if (name) {
        fprintf(stderr, "Error: %s '%s'\n", message, name);
    } else {
        fprintf(stderr, "Error: %s\n", message);
    }
    compiler_error_count++;
}

static int combine_expr(int opcode, int left, int right) {
    if (left < 0 || right < 0) {
        return -1;
    }
    asm_emit3(opcode, left, left, right);
    free_temp_addr();
    return left;
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

%type <nb> Expression IfHeader IfBody Arguments ArgList

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
    | tMAIN {
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
        if ($2 >= 0) {
            asm_emit2(OP_COP, current_func_return_addr, $2);
            asm_emit0(OP_RET);
            free_temp_addr(); // free $2 logically
        }
    }
    | error tSEMI {
        yyerrok;
    }
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
        if (addr >= 0 && $4 >= 0) {
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
        if (addr >= 0 && $5 >= 0) {
            asm_emit2(OP_COP, addr, $5);
            printf("/* declared '*%s' at address %d (init from temp %d) */\n", $2, addr, $5);
        }
        free($2);
    }
    ;

Assignment:
    tID tASSIGN Expression tSEMI {
        int addr = lookup_symbol($1);
        if (addr >= 0 && is_const_symbol($1)) {
            compiler_error("cannot assign to const", $1);
        } else if (addr >= 0 && $3 >= 0) {
            asm_emit2(OP_COP, addr, $3);
        }
        free($1);
    }
    | tMUL Expression tASSIGN Expression tSEMI {
        if ($2 >= 0 && $4 >= 0) {
            asm_emit2(OP_COPW, $2, $4);
            free_temp_addr(); /* free $4 */
            free_temp_addr(); /* free $2 */
        }
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
        if ($3 >= 0) {
            asm_emit2(OP_JMF, $3, -1);
            free_temp_addr();
        } else {
            $<nb>$ = -1;
        }
    }
    ;

IfBody:
    IfHeader tLBRACE Instructions tRBRACE {
        $$ = $1;
    }
    ;

IfStatement:
    IfBody {
        if ($1 >= 0) {
            asm_patch($1, asm_get_line());
        }
    }
    | IfBody tELSE {
        $<nb>$ = asm_get_line();
        asm_emit1(OP_JMP, -1);
        if ($1 >= 0) {
            asm_patch($1, asm_get_line());
        }
    } tLBRACE Instructions tRBRACE {
        asm_patch($<nb>3, asm_get_line());
    }
    ;

WhileStatement:
    tWHILE {
        $<nb>$ = asm_get_line();
    } tLPAR Expression tRPAR {
        $<nb>$ = asm_get_line();
        if ($4 >= 0) {
            asm_emit2(OP_JMF, $4, -1);
            free_temp_addr();
        } else {
            $<nb>$ = -1;
        }
    } tLBRACE Instructions tRBRACE {
        if ($<nb>6 >= 0) {
            asm_emit1(OP_JMP, $<nb>2);
            asm_patch($<nb>6, asm_get_line());
        }
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
        if (f && $3 == f->num_params) {
            int base = arg_stack_top - $3;
            int bad_arg = 0;
            for (int i = 0; i < $3; i++) {
                if (arg_stack[base + i] < 0) {
                    bad_arg = 1;
                }
            }
            if (!bad_arg) {
                for(int i = 0; i < f->num_params; i++) {
                    asm_emit2(OP_COP, f->param_addresses[i], arg_stack[base + i]);
                }
                arg_stack_top = base; // pop args
                asm_emit1(OP_CALL, f->start_line);
                int t = get_temp_addr();
                asm_emit2(OP_COP, t, f->return_address);
                $$ = t;
            } else {
                arg_stack_top = base;
                $$ = -1;
            }
        } else {
            if (f) {
                compiler_error("wrong number of arguments for function", $1);
            }
            arg_stack_top -= $3;
            if (arg_stack_top < 0) {
                arg_stack_top = 0;
            }
            $$ = -1;
        }
        free($1);
    }
    | tID {
        int addr = lookup_symbol($1);
        if (addr >= 0) {
            int t = get_temp_addr();
            asm_emit2(OP_COP, t, addr);
            $$ = t;
        } else {
            $$ = -1;
        }
        free($1);
    }
    | tAMPERSAND tID {
        int addr = lookup_symbol($2);
        if (addr >= 0) {
            int t = get_temp_addr();
            asm_emit2(OP_AFC, t, addr);
            $$ = t;
        } else {
            $$ = -1;
        }
        free($2);
    }
    | tMUL Expression %prec tDEREF {
        if ($2 >= 0) {
            int t = get_temp_addr();
            asm_emit2(OP_COPR, t, $2);
            // Free the expression temp after dereferencing it
            free_temp_addr(); // Frees $2
            $$ = t;
        } else {
            $$ = -1;
        }
    }
    | Expression tADD Expression {
        $$ = combine_expr(OP_ADD, $1, $3);
    }
    | Expression tSOU Expression {
        $$ = combine_expr(OP_SOU, $1, $3);
    }
    | Expression tMUL Expression {
        $$ = combine_expr(OP_MUL, $1, $3);
    }
    | Expression tDIV Expression {
        $$ = combine_expr(OP_DIV, $1, $3);
    }
    | Expression tEQU Expression {
        $$ = combine_expr(OP_EQU, $1, $3);
    }
    | Expression tINF Expression {
        $$ = combine_expr(OP_INF, $1, $3);
    }
    | Expression tSUP Expression {
        $$ = combine_expr(OP_SUP, $1, $3);
    }
    | tLPAR Expression tRPAR {
        $$ = $2;
    }
    ;

Arguments:
    /* empty */ {
        $$ = 0;
    }
    | ArgList {
        $$ = $1;
    }
    ;

ArgList:
    Expression {
        push_arg($1);
        $$ = 1;
    }
    | ArgList tCOMMA Expression {
        push_arg($3);
        $$ = $1 + 1;
    }
    ;

%%

void yyerror(const char *s) {
    extern int yylineno;
    extern char *yytext;
    fprintf(stderr, "Error at line %d near '%s': %s\n", yylineno, yytext, s);
    compiler_error_count++;
}

int main() {
    init_symbol_table();
    if (asm_open("target.asm", "target_encoded.asm") < 0) {
        return 1;
    }
    int parse_result = yyparse();
    asm_close();
    if (parse_result != 0 || compiler_error_count > 0 || symbol_error_count() > 0) {
        return 1;
    }
    return 0;
}
