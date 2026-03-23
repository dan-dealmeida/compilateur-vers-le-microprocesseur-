# Simple Makefile for the Lex/Yacc compiler
CC = gcc
LEX = lex
YACC = yacc
TARGET = compiler

all: $(TARGET)

$(TARGET): y.tab.c lex.yy.c
	$(CC) y.tab.c lex.yy.c -o $(TARGET)

y.tab.c y.tab.h: compiler.y
	$(YACC) -d compiler.y

lex.yy.c: compiler.lex y.tab.h
	$(LEX) compiler.lex

test: $(TARGET)
	./$(TARGET) < test.c

clean:
	rm -f $(TARGET) y.tab.c y.tab.h lex.yy.c
