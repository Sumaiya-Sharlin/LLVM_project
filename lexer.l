/*
%{
#include <stdio.h>
#include <stdlib.h>

// Token definitions
enum TokenType {
    TOK_PLUS, TOK_MINUS, TOK_MUL, TOK_DIV, TOK_DOUBLE,
    TOK_IF, TOK_ELSE, TOK_FOR,
    TOK_IDENTIFIER, TOK_NUMBER,
    TOK_LPAREN, TOK_RPAREN, TOK_LBRACE, TOK_RBRACE, TOK_SEMICOLON,
    TOK_ASSIGN, TOK_UNKNOWN
};

// Required by Flex to avoid undefined reference to yywrap
int yywrap(void) {
    return 1;
}
%}

%%
"double"    { return TOK_DOUBLE; }
"if"        { return TOK_IF; }
"else"      { return TOK_ELSE; }
"for"       { return TOK_FOR; }
"+"         { return TOK_PLUS; }
"-"         { return TOK_MINUS; }
"*"         { return TOK_MUL; }
"/"         { return TOK_DIV; }
"("         { return TOK_LPAREN; }
")"         { return TOK_RPAREN; }
"{"         { return TOK_LBRACE; }
"}"         { return TOK_RBRACE; }
";"         { return TOK_SEMICOLON; }
"="         { return TOK_ASSIGN; }
[a-zA-Z_][a-zA-Z0-9_]* { return TOK_IDENTIFIER; }
[0-9]+(\.[0-9]+)? { return TOK_NUMBER; }
[ \t\n]+    ; // Ignore whitespace
.           { printf("Unknown token: %s\n", yytext); return -1; }

%%

*/



%{
#include <stdio.h>
#include <stdlib.h>

// Token definitions
enum TokenType {
    TOK_PLUS, TOK_MINUS, TOK_MUL, TOK_DIV, TOK_DOUBLE,
    TOK_IF, TOK_ELSE, TOK_FOR,
    TOK_IDENTIFIER, TOK_NUMBER,
    TOK_LPAREN, TOK_RPAREN, TOK_LBRACE, TOK_RBRACE, TOK_SEMICOLON,
    TOK_ASSIGN, TOK_UNKNOWN
};

// Required by Flex to avoid undefined reference to yywrap
int yywrap(void) {
    return 1;
}

// Function to print tokens
void print_token(int token, const char* lexeme) {
    switch (token) {
        case TOK_PLUS: printf("PLUS: %s\n", lexeme); break;
        case TOK_MINUS: printf("MINUS: %s\n", lexeme); break;
        case TOK_MUL: printf("MULTIPLY: %s\n", lexeme); break;
        case TOK_DIV: printf("DIVIDE: %s\n", lexeme); break;
        case TOK_DOUBLE: printf("DOUBLE: %s\n", lexeme); break;
        case TOK_IF: printf("IF: %s\n", lexeme); break;
        case TOK_ELSE: printf("ELSE: %s\n", lexeme); break;
        case TOK_FOR: printf("FOR: %s\n", lexeme); break;
        case TOK_IDENTIFIER: printf("IDENTIFIER: %s\n", lexeme); break;
        case TOK_NUMBER: printf("NUMBER: %s\n", lexeme); break;
        case TOK_LPAREN: printf("LEFT PAREN: %s\n", lexeme); break;
        case TOK_RPAREN: printf("RIGHT PAREN: %s\n", lexeme); break;
        case TOK_LBRACE: printf("LEFT BRACE: %s\n", lexeme); break;
        case TOK_RBRACE: printf("RIGHT BRACE: %s\n", lexeme); break;
        case TOK_SEMICOLON: printf("SEMICOLON: %s\n", lexeme); break;
        case TOK_ASSIGN: printf("ASSIGN: %s\n", lexeme); break;
        default: printf("UNKNOWN: %s\n", lexeme); break;
    }
}
%}

%%
"+"         { print_token(TOK_PLUS, yytext); }
"-"         { print_token(TOK_MINUS, yytext); }
"*"         { print_token(TOK_MUL, yytext); }
"/"         { print_token(TOK_DIV, yytext); }
"double"    { print_token(TOK_DOUBLE, yytext); }
"if"        { print_token(TOK_IF, yytext); }
"else"      { print_token(TOK_ELSE, yytext); }
"for"       { print_token(TOK_FOR, yytext); }
[a-zA-Z_][a-zA-Z0-9_]* { print_token(TOK_IDENTIFIER, yytext); }
[0-9]+(\.[0-9]+)? { print_token(TOK_NUMBER, yytext); }
"("         { print_token(TOK_LPAREN, yytext); }
")"         { print_token(TOK_RPAREN, yytext); }
"{"         { print_token(TOK_LBRACE, yytext); }
"}"         { print_token(TOK_RBRACE, yytext); }
";"         { print_token(TOK_SEMICOLON, yytext); }
"="         { print_token(TOK_ASSIGN, yytext); }
[ \t\n]+    ; // Ignore whitespace
.           { print_token(TOK_UNKNOWN, yytext); }
%%

int main(int argc, char** argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
        return 1;
    }

    FILE* file = fopen(argv[1], "r");
    if (!file) {
        perror("Error opening file");
        return 1;
    }

    yyin = file;  // Set the input for Flex
    yylex();      // Start lexical analysis
    fclose(file);
    return 0;
}

