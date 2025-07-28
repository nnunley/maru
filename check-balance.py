#!/usr/bin/env python3
import sys

def check_balance(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    stack = []
    line_num = 1
    col_num = 1
    i = 0
    
    while i < len(content):
        char = content[i]
        
        if char == '\n':
            line_num += 1
            col_num = 1
            i += 1
            continue
            
        if char == ';':
            # Skip to end of line
            while i < len(content) and content[i] != '\n':
                i += 1
            continue
            
        if char == '"':
            # Skip string literal
            i += 1
            col_num += 1
            while i < len(content):
                if content[i] == '"':
                    i += 1
                    col_num += 1
                    break
                elif content[i] == '\\' and i + 1 < len(content):
                    i += 2  # Skip escaped character
                    col_num += 2
                else:
                    if content[i] == '\n':
                        line_num += 1
                        col_num = 1
                    else:
                        col_num += 1
                    i += 1
            continue
            
        if char == '(':
            stack.append((line_num, col_num, char))
        elif char == ')':
            if not stack:
                print(f"ERROR: Unmatched closing paren at line {line_num}, col {col_num}")
                return False
            stack.pop()
            
        col_num += 1
        i += 1
    
    if stack:
        print(f"ERROR: {len(stack)} unmatched opening parens:")
        for line, col, char in stack[-10:]:  # Show last 10
            print(f"  Line {line}, col {col}")
        return False
    
    print("SUCCESS: All parentheses are balanced")
    return True

if __name__ == '__main__':
    check_balance(sys.argv[1] if len(sys.argv) > 1 else 'core/compiler/emit.l')