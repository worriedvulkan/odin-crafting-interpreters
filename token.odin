package main

import "core:fmt"

TokenType :: enum {
  // Single-character tokens.
  LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE,
  COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR,

  // One or two character tokens.
  BANG, BANG_EQUAL,
  EQUAL, EQUAL_EQUAL,
  GREATER, GREATER_EQUAL,
  LESS, LESS_EQUAL,

  // Literals.
  IDENTIFIER, STRING, NUMBER,

  // Keywords.
  AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR,
  PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE,

  EOF,
}

Token :: struct {
    type : TokenType,
    lexeme: string,
    literal: any,
    line: int,
}

token_to_string :: proc (token: ^Token) -> string {
    return fmt.aprintf("%v %v %v", token.type, token.lexeme, token.literal)
}

token_init :: proc(type: TokenType, lexeme: string, literal : any, line: int) -> Token {
    return Token{ type = type, lexeme = lexeme, literal = literal, line = line}
}