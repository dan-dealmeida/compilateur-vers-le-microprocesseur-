#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define MAX_SYMBOLS 100

typedef struct {
    char name[64];
    int address;
    int is_const;
    int is_pointer;
    int is_initialized;
} Symbol;

// Initialize the symbol table (call once before parsing)
void init_symbol_table(void);

// Add a symbol. Returns its allocated memory address, or -1 if table is full / already declared.
int add_symbol(const char *name, int is_const, int is_pointer);

// Look up a symbol by name. Returns its memory address, or -1 if not found.
int lookup_symbol(const char *name);

#define MAX_FUNCTIONS 50
#define MAX_PARAMS 10

typedef struct {
    char name[64];
    int start_line;          // asm jump target for CALL
    int return_address;      // dedicated absolute memory address for return value
    int param_addresses[MAX_PARAMS];
    int num_params;
} FuncSymbol;

// Reset local variables but keep global address advancing (to stop pointer collisions)
void reset_local_symbol_table(void);

// Add a function. Start line is the current asm_get_line().
int add_function(const char *name, int start_line, int return_address, int *param_opts, int num_params);

// Look up a function.
FuncSymbol* lookup_function(const char *name);

// Returns the next available temporary address (above all declared variables).
int get_temp_addr(void);

// Free a temporary address (decrement the temp pointer).
void free_temp_addr(void);

#endif
