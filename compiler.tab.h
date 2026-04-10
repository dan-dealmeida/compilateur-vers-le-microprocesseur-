/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_COMPILER_TAB_H_INCLUDED
# define YY_YY_COMPILER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    tID = 258,                     /* tID  */
    tNB = 259,                     /* tNB  */
    tMAIN = 260,                   /* tMAIN  */
    tINT = 261,                    /* tINT  */
    tCONST = 262,                  /* tCONST  */
    tPRINTF = 263,                 /* tPRINTF  */
    tIF = 264,                     /* tIF  */
    tELSE = 265,                   /* tELSE  */
    tWHILE = 266,                  /* tWHILE  */
    tADD = 267,                    /* tADD  */
    tSOU = 268,                    /* tSOU  */
    tMUL = 269,                    /* tMUL  */
    tDIV = 270,                    /* tDIV  */
    tASSIGN = 271,                 /* tASSIGN  */
    tEQU = 272,                    /* tEQU  */
    tINF = 273,                    /* tINF  */
    tSUP = 274,                    /* tSUP  */
    tLBRACE = 275,                 /* tLBRACE  */
    tRBRACE = 276,                 /* tRBRACE  */
    tLPAR = 277,                   /* tLPAR  */
    tRPAR = 278,                   /* tRPAR  */
    tSEMI = 279,                   /* tSEMI  */
    tCOMMA = 280                   /* tCOMMA  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 18 "compiler.y"

    int nb;
    char *str;

#line 94 "compiler.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_COMPILER_TAB_H_INCLUDED  */
