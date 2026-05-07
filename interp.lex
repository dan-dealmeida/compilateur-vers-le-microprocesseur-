%{
#include "interp.tab.h"
#include <stdlib.h>
%}

%option noyywrap

%%
-?[0-9]+    { interplval.val = atoi(yytext); return tNUMBER; }
\n          { return tNEWLINE; }
[ \t\r]+    { /* ignore whitespace */ }
.           { /* ignore unrecognized */ }
%%
