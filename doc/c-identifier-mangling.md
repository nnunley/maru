# C Identifier Mangling Rules for Maru

This document describes the rules for converting Maru symbols to valid C identifiers, with special attention to method specializations for multiple dispatch.

## Basic Character Mapping

The following character transformations are applied when a Maru symbol contains characters that are not valid in C identifiers:

| Maru Character | C Replacement | Example |
|----------------|---------------|---------|
| `-` (hyphen) | `_` | `define-subr` → `define_subr` |
| `+` | `_plus_` | `+` → `_plus_` |
| `*` | `_star_` | `*` → `_star_` |
| `/` | `_slash_` | `/` → `_slash_` |
| `<` | `_lt_` | `<` → `_lt_` |
| `>` | `_gt_` | `>` → `_gt_` |
| `=` | `_eq_` | `=` → `_eq_` |
| `!` | `_bang_` | `!` → `_bang_` |
| `?` | `_p_` | `defined?` → `defined_p_` |
| `$` | `_dollar_` | `_fdopen$stub` → `_fdopen_dollar_stub` |
| `&` | `_amp_` | `&rest` → `_amp_rest` |
| `%` | `_percent_` | `%typecheck` → `_percent_typecheck` |
| `@` | `_at_` | `@meta` → `_at_meta` |
| `:` | `_colon_` | `key:value` → `key_colon_value` |
| `.` | `_dot_` | `self.field` → `self_dot_field` |
| `~` | `_tilde_` | `~pattern` → `_tilde_pattern` |
| `^` | `_caret_` | `^power` → `_caret_power` |
| `|` | `_bar_` | `\|alternate\|` → `_bar_alternate_bar_` |
| `\` | `_backslash_` | `\escape` → `_backslash_escape` |

Characters not listed above that are also not valid C identifier characters (alphanumeric or underscore) are encoded as `_xNN_` where NN is the decimal ASCII value.

## Method Specialization Mangling Rules

Multiple dispatch methods require special mangling to ensure unique C function names for each specialization.

### Basic Method Pattern

```
method-name + "__" + type1 + "_" + type2 + ... + "_" + typeN
```

### Examples

1. **Single Dispatch**
   ```lisp
   (define-method print <string> (str)
     ...)
   ```
   C name: `print__string`

2. **Multiple Dispatch**
   ```lisp
   (define-method add <number> <number> (a b)
     ...)
   ```
   C name: `add__number_number`

3. **Complex Types**
   ```lisp
   (define-method new-<array> <long> (size)
     ...)
   ```
   C name: `new__lt_array_gt___long`

4. **Varargs Methods**
   ```lisp
   (define-method format <string> &rest (fmt args)
     ...)
   ```
   C name: `format__string__amp_rest`

### Type Name Mangling

Type names in method specializations follow the same character mapping rules:

- `<string>` → `_lt_string_gt_`
- `<array>` → `_lt_array_gt_`
- `<pair>` → `_lt_pair_gt_`
- `<symbol>` → `_lt_symbol_gt_`
- `<long>` → `_lt_long_gt_`

### Special Cases

1. **Generic Function Default Method**
   ```lisp
   (define-generic foo)
   ```
   C name: `foo__default`

2. **Method with No Specialization**
   ```lisp
   (define-method bar () ...)
   ```
   C name: `bar__void`

3. **Constructor Methods**
   ```lisp
   (define-method new <my-class> (arg)
     ...)
   ```
   C name: `new__my_class`

## Implementation Notes

The mangling is performed by the `c-print-mangled-name` function in `emit-c.l`. The function:

1. Converts the symbol to a string
2. Iterates through each character
3. Applies the transformation rules
4. Preserves alphanumeric characters and underscores

## Rationale

The mangling scheme is designed to:

- Preserve readability when possible
- Be reversible (you can deduce the original Maru name)
- Avoid conflicts with C keywords and standard library functions
- Support all Maru naming conventions
- Be consistent and predictable

## Future Considerations

1. **Namespace Prefixes**: May want to add prefixes to avoid conflicts with C standard library
2. **Length Limits**: Some C compilers have identifier length limits that may need addressing
3. **Unicode Support**: Current scheme is ASCII-only; Unicode characters would need encoding
4. **Demangling**: A reverse function to convert C names back to Maru names for debugging