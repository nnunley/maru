#!/usr/bin/env python3
import sys

def check_quotes(filename):
    with open(filename, 'r') as f:
        content = f.read()

    quote_count = 0
    line_num = 1
    in_string = False
    escape = False
    
    for i, char in enumerate(content):
        if char == '\n':
            line_num += 1
        elif escape:
            escape = False
        elif char == '\\':
            escape = True
        elif char == '"':
            quote_count += 1
            in_string = not in_string
            print(f'Quote #{quote_count} at line {line_num}: {"opening" if in_string else "closing"}')

    print(f'Total quotes: {quote_count}')
    if quote_count % 2 != 0:
        print('ERROR: Unmatched quotes!')
        return False
    else:
        print('SUCCESS: All quotes are balanced')
        return True

if __name__ == '__main__':
    check_quotes(sys.argv[1] if len(sys.argv) > 1 else 'core/compiler/emit.l')