#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define MAX_SYMBOLS 100

typedef struct {
    char name[64];
    int address;
    int is_const;
    int is_initialized;
} Symbol;

// Initialize the symbol table (call once before parsing)
void init_symbol_table(void);

// Add a symbol. Returns its allocated memory address, or -1 if table is full / already declared.
int add_symbol(const char *name, int is_const);

// Look up a symbol by name. Returns its memory address, or -1 if not found.
int lookup_symbol(const char *name);

// Returns the next available temporary address (above all declared variables).
int get_temp_addr(void);

// Free a temporary address (decrement the temp pointer).
void free_temp_addr(void);

#endif
