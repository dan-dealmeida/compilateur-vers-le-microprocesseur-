# Simple Makefile for the Lex/Yacc compiler
CC = gcc
LEX = flex
YACC = /opt/homebrew/opt/bison/bin/bison
TARGET = compiler

all: $(TARGET)

$(TARGET): compiler.tab.c lex.yy.c symbol_table.c symbol_table.h asm_output.c asm_output.h
	$(CC) compiler.tab.c lex.yy.c symbol_table.c asm_output.c -o $(TARGET)

compiler.tab.c compiler.tab.h: compiler.y symbol_table.h
	$(YACC) -d compiler.y

lex.yy.c: compiler.lex compiler.tab.h
	$(LEX) compiler.lex

test: $(TARGET)
	./$(TARGET) < test.c

clean:
	rm -f $(TARGET) compiler.tab.c compiler.tab.h lex.yy.c
