%{
#include <string.h>
#include <stdlib.h>
#include "compiler.tab.h"
%}

/* Definitions Section */
digit       [0-9]
letter      [a-zA-Z]
id          {letter}({letter}|{digit}|_)*
number      {digit}+([eE][+-]?{digit}+)?

%%

"main"      { return tMAIN; }
"int"       { return tINT; }
"const"     { return tCONST; }
"printf"    { return tPRINTF; }

{id}        { yylval.str = strdup(yytext); return tID; }
{number}    { yylval.nb = atoi(yytext); return tNB; }

"+"         { return tADD; }
"-"         { return tSOU; }
"*"         { return tMUL; }
"/"         { return tDIV; }
"="         { return tASSIGN; }

"{"         { return tLBRACE; }
"}"         { return tRBRACE; }
"("         { return tLPAR; }
")"         { return tRPAR; }
";"         { return tSEMI; }
","         { return tCOMMA; }

[ \t\n]     { /* Ignore whitespace */ }

.           { printf("Unknown character: %s\n", yytext); }

%%

int yywrap() {
    return 1;
}