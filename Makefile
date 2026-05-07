# Simple Makefile for the Lex/Yacc compiler
CC = gcc
LEX = flex
YACC = /opt/homebrew/opt/bison/bin/bison
TARGET = compiler

all: $(TARGET) interpreter

$(TARGET): compiler.tab.c lex.yy.c symbol_table.c symbol_table.h asm_output.c asm_output.h
	$(CC) compiler.tab.c lex.yy.c symbol_table.c asm_output.c -o $(TARGET)

interpreter: interp.tab.c lex.interp.c interp_backend.c
	$(CC) interp.tab.c lex.interp.c interp_backend.c -o interpreter

compiler.tab.c compiler.tab.h: compiler.y symbol_table.h
	$(YACC) -d compiler.y

lex.yy.c: compiler.lex compiler.tab.h
	$(LEX) compiler.lex

interp.tab.c interp.tab.h: interp.y
	$(YACC) -d -p interp interp.y -o interp.tab.c

lex.interp.c: interp.lex interp.tab.h
	$(LEX) -P interp -o lex.interp.c interp.lex

test: $(TARGET)
	./$(TARGET) < test.c

clean:
	rm -f $(TARGET) interpreter compiler.tab.c compiler.tab.h lex.yy.c interp.tab.c interp.tab.h lex.interp.c target.asm target_encoded.asm
