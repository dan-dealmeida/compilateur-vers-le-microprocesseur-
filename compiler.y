%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex();
%}

%token tMAIN tINT tCONST tPRINTF tID tNB tADD tSOU tMUL tDIV tASSIGN tLBRACE tRBRACE tLPAR tRPAR tSEMI tCOMMA

%left tADD tSOU
%left tMUL tDIV

%%

Program:
    tINT tMAIN tLPAR tRPAR tLBRACE Body tRBRACE { printf("End of Program\n"); }
    ;

Body:
    Statements
    ;

Statements:
    Statement Statements
    | /* empty */
    ;

Statement:
    Declaration
    | Assignment
    | Print
    ;

Declaration:
    tINT tID tSEMI { printf("AFC %s\n", "variable_id"); } /* Placeholder for actual ID */
    | tINT tID tASSIGN Expression tSEMI { printf("STORE %s\n", "variable_id"); }
    ;

Assignment:
    tID tASSIGN Expression tSEMI { printf("STORE %s\n", "variable_id"); }
    ;

Print:
    tPRINTF tLPAR tID tRPAR tSEMI { printf("PRINT %s\n", "variable_id"); }
    ;

Expression:
    tNB { printf("AFC %s\n", "value"); }
    | tID { printf("LOAD %s\n", "variable_id"); }
    | Expression tADD Expression { printf("ADD\n"); }
    | Expression tSOU Expression { printf("SOU\n"); }
    | Expression tMUL Expression { printf("MUL\n"); }
    | Expression tDIV Expression { printf("DIV\n"); }
    | tLPAR Expression tRPAR
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    yyparse();
    return 0;
}
