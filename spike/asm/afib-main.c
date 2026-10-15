#include <stdio.h>
long fib(long), big(void);
long cfib(long n) { return n < 2 ? n : cfib(n-1) + cfib(n-2); }
int main(void) {
  int ok = 1;
  for (long n = 0; n <= 25; n++) if (fib(n) != cfib(n)) { printf("fib(%ld) = %ld, want %ld\n", n, fib(n), cfib(n)); ok = 0; }
  printf("fib(25) = %ld\nbig() = %#lx\n", fib(25), big());
  if (big() != 0x123456789abcdef0) ok = 0;
  puts(ok ? "native ok" : "FAIL");
  return !ok;
}
