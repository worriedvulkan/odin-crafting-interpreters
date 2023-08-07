package main

import "core:unicode/utf8"
import "core:unicode"
import "core:strconv"

Scanner :: struct {
    chars: []rune,
    tokens: [dynamic]Token,
    start: int,
    current: int,
    line: int,
}

Keywords := map[string]TokenType {
    "and" = .AND,
    "class" = .CLASS,
    "else" = .ELSE,
    "false"= .FALSE,
    "for"= .FOR,
    "fun"= .FUN,
    "if"= .IF,
    "nil"= .NIL,
    "or"= .OR,
    "print"= .PRINT,
    "return"= .RETURN,
    "super"= .SUPER,
    "this"= .THIS,
    "true"= .TRUE,
    "var"= .VAR,
    "while"= .WHILE,
}

scanner_init :: proc(source: string) -> (scanner: ^Scanner) {
    scanner.chars = utf8.string_to_runes(source)
    scanner.tokens = make([dynamic]Token)
    scanner.start = 0
    scanner.current = 0
    scanner.line = 1
    return 
}

scan_tokens :: proc(s: ^Scanner) {
    for is_at_end(s) == false {
        s.start = s.current
        scanToken(s)
    }
    append(&s.tokens, token_init(.EOF, "", nil, s.line))
}

is_at_end :: proc(s : ^Scanner) -> bool{
    return s.current >= len(s.chars)
}

scanToken :: proc(s: ^Scanner) {
    switch c := advance(s); c {
        case '(': add_token(s, .LEFT_PAREN)
        case ')': add_token(s, .RIGHT_PAREN)
        case '{': add_token(s, .LEFT_BRACE)
        case '}': add_token(s, .RIGHT_BRACE)
        case ',': add_token(s, .COMMA)
        case '.': add_token(s, .DOT)
        case '-': add_token(s, .MINUS)
        case '+': add_token(s, .PLUS)
        case ';': add_token(s, .SEMICOLON)
        case '*': add_token(s, .STAR)
        case '!': add_token(s, match(s, '=') ? .BANG_EQUAL : .BANG)
        case '=': add_token(s, match(s, '=') ? .EQUAL_EQUAL : .EQUAL)
        case '>': add_token(s, match(s, '=') ? .GREATER_EQUAL : .GREATER)
        case '<': add_token(s, match(s, '=') ? .LESS_EQUAL : .LESS)
        case '/':
            if match(s, '/') {
                for peek(s) != '\n' && is_at_end(s) == false { advance(s) }
            } else {
                add_token(s, .SLASH)
            }
        case ' ', '\r', '\t': break
        case '\n': s.line += 1
        case '\'': string_method(s)
        case 'o': 
            if match(s, 'r') { add_token(s, .OR)}
        case: 
            if unicode.is_digit(c) {
                number(s)
            } else if unicode.is_alpha(c) {

            } else { 
                error(s.line, "", "Unexpected Character.") 
            }
    }
}

match :: proc(s: ^Scanner, expected: rune) -> bool {
    if is_at_end(s) { return false }
    if s.chars[s.current] != expected { return false }
    s.current += 1
    return true
}

peek :: proc (s: ^Scanner) -> rune {
    if is_at_end(s) { return '\u0000' }
    return s.chars[s.current]
}

string_method :: proc(s : ^Scanner) {
    for peek(s) != '"' && is_at_end(s) == false { 
        if peek(s) != '\n' { s.line += 1 }
        advance(s)
    }

    if is_at_end(s) {
        error(s.line, "", "Unterminated String..")
        return
    }

    advance(s)

    value := s.chars[s.start + 1 : s.current - 1]
    add_token(s, .STRING, value)
}

advance :: proc(s : ^Scanner) -> rune {
    s.current += 1
    return s.chars[s.current]
}

add_token :: proc(s: ^Scanner, type: TokenType, literal: any = nil) {
    str:= utf8.runes_to_string(s.chars[s.start:s.current])
    append(&s.tokens, token_init(type, str, literal, s.line))
}

number :: proc(s : ^Scanner) {
    for unicode.is_digit(peek(s)) { advance(s) }

    if peek(s) == '.' && unicode.is_digit(peek_next(s)) {
        advance(s)

        for unicode.is_digit(peek(s)) { advance(s) }
    }

    str := utf8.runes_to_string(s.chars[s.start : s.current])
    double, err := strconv.parse_f64(str)
    add_token(s, .NUMBER, double)
}

identifier :: proc(s: ^Scanner) {
    for is_alpha_numeric(peek(s)){ advance(s) }
    text := utf8.runes_to_string(s.chars[s.start : s.current])
    type := Keywords[text] or_else .IDENTIFIER
    add_token(s, type)
}

is_alpha_numeric :: proc(r : rune) -> bool {
    return unicode.is_alpha(r) || unicode.is_number(r)
}

peek_next :: proc(s: ^Scanner) -> rune {
    if s.current + 1 >= len(s.chars) { return '\u0000' }
    return s.chars[s.current + 1]
}