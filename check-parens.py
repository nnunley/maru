#!/usr/bin/env python3
import sys

def check_parens(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    paren_count = 0
    for i, line in enumerate(lines, 1):
        # Skip comments
        clean_line = ''
        in_string = False
        escape = False
        for c in line:
            if escape:
                escape = False
                continue
            if c == '\\':
                escape = True
                continue
            if c == '"' and not in_string:
                in_string = True
            elif c == '"' and in_string:
                in_string = False
            elif c == ';' and not in_string:
                break
            elif not in_string:
                clean_line += c
        
        open_count = clean_line.count('(')
        close_count = clean_line.count(')')
        paren_count += open_count - close_count
        
        if open_count != close_count and abs(open_count - close_count) > 2:
            print(f'Line {i}: open={open_count}, close={close_count}, total={paren_count}')
    
    print(f'Final paren count: {paren_count}')
    if paren_count != 0:
        print(f'ERROR: Unbalanced parentheses! Missing {abs(paren_count)} {")" if paren_count > 0 else "("}')

if __name__ == '__main__':
    check_parens(sys.argv[1] if len(sys.argv) > 1 else 'core/compiler/emit.l')