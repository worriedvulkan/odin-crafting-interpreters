package main

import "core:fmt"
import "core:os"
import "core:log"
import "core:strings"
import "core:strconv"

main :: proc() {
    context.logger = log.create_console_logger()

    args := make([dynamic]string)
    if len(args) > 1 {
        log.info("Usage: jlox [script]")
        os.exit(64)
    } else if len(args) == 1 {
        run_file(args[0])
    }
    else {
        run_prompt()
    }
}

hadError := false

run_file :: proc(path: string) {
    byteArr, ok := os.read_entire_file(path)
    run(cast(string)byteArr)

    if hadError {
        os.exit(65)
    }
}

run_prompt :: proc() {
    input := ""
    bufferedReader := ""
    for {
        fmt.print("> ")
        line := ""
        if line == "" {break;}
        run(line)
        hadError = false
    }
}

run :: proc(source: string) {
    scanner := scanner_init(source)
    scan_tokens(scanner)
    for token in scanner.tokens {
        log.info(token)
    }
}

error :: proc(line: int, wherein: string , message: string) {
    fmt.printf("[line %v] Error %v: %v", line, wherein, message)
    hadError = true
}