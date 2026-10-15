// Title: PEG-based transformer provides front-, middle- and back-end stages in a simple compiler
// Authors: Ian Piumarta
// Source: VPRI Technical Report TR-2010-003 (2010), Figure 5 (C version of the example program, used for
//   benchmarking). Printed page 8, PDF page 9 (right column). Section B ("Code listings") refers to it.
// Transcribed from the page images; text-layer differences noted below.

#include <stdio.h>

long nfibs(long n)
{
  return (n < 2)
    ? 1
    : 1 + nfibs(n - 1) + nfibs(n - 2);
}

int main(int argc, char **argv)
{
  printf("%ld\n", nfibs(32));
  return 0;
}

// Transcription notes
// - Checked at the page image (150 dpi). Text layer agrees token for token.
// - The printf format string is printed as "%ld\n" with a backslash-n inside the string literal.
// - No glyph left uncertain.
