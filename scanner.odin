package main

import "core:strings"

Scanner :: struct {
    reader: strings.Reader,
    tokens: [dynamic]Token,
    start: int,
    current: int,
    line: int,
}

scanner_init :: proc(source: string) -> (scanner: ^Scanner) {
    reader: strings.Reader
    strings.reader_init(&reader, source)
    scanner.reader = reader
    scanner.tokens = make([dynamic]Token)
    scanner.start = 0
    scanner.current = 0
    scanner.line = 1
    return 
}

scan_tokens :: proc(scanner: ^Scanner) {
    using scanner
    for is_at_end(scanner) == false {
        start = current
        scanToken(scanner)
    }
    append(&scanner.tokens, token_init(.EOF, "", nil, line))
}

is_at_end :: proc(scanner : ^Scanner) -> bool{
    return scanner.current >= strings.reader_length(&scanner.reader)
}

scanToken :: proc(s: ^Scanner) {
    switch c := advance(s); c {
        case "(": add_token(s, .LEFT_PAREN)
        case ")": add_token(s, .RIGHT_PAREN)
        case "{": add_token(s, .LEFT_BRACE)
        case "}": add_token(s, .RIGHT_BRACE)
        case ",": add_token(s, .COMMA)
        case ".": add_token(s, .DOT)
        case "-": add_token(s, .MINUS)
        case "+": add_token(s, .PLUS)
        case ";": add_token(s, .SEMICOLON)
        case "*": add_token(s, .STAR)
        case "!": add_token(s, match(s, "=") ? .BANG_EQUAL : .BANG)
        case "=": add_token(s, match(s, "=") ? .EQUAL_EQUAL : .EQUAL)
        case ">": add_token(s, match(s, "=") ? .GREATER_EQUAL : .GREATER)
        case "<": add_token(s, match(s, "=") ? .LESS_EQUAL : .LESS)
        case "/":
            if match(s, "/") {
                for {}
                // TODO Upto Chapter Index 4.6 Longer Lexemes
            }
        case: error(s.line, "", "Unexpected Character.")
    }
}

match :: proc(s: ^Scanner, expected: string) -> bool {
    if is_at_end(s) { return false }
    if substring(&s.reader, s.current) != expected { return false }
    s.current += 1
    return true
}

advance :: proc(s : ^Scanner) -> string {
    return substring(&s.reader, s.current + 1)
}

add_token :: proc(s: ^Scanner, type: TokenType, literal: any = nil) {
    str : = substring(&s.reader, s.start, s.current - s.start)
    append(&s.tokens, token_init(type, str, literal, s.line))
}

substring :: proc (reader: ^strings.Reader, index: int, length : int = 1) -> string {
    arr := make([]u8, length)
    strings.reader_read_at(reader, arr, i64(index))
    return string(arr)
}