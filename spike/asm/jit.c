#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <pthread.h>
#include <libkern/OSCacheControl.h>
static const unsigned code[] = { 0xf100081f,0x5400018b,0xa9be7bfd,0xa90153f3,0xaa0003f3,0xd1000660,0x97fffffa,0xaa0003f4,0xd1000a60,0x97fffff7,0x8b140000,0xa94153f3,0xa8c27bfd,0xd65f03c0,0xd29bde00,0xf2b35780,0xf2cacf00,0xf2e24680,0xd65f03c0 };   /* fib and big, as the A64 table encoded them */
int main(void) {
  void *m = mmap(0, 16384, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANON | MAP_JIT, -1, 0);
  if (m == MAP_FAILED) { perror("mmap"); return 1; }
  pthread_jit_write_protect_np(0);            /* this thread may write */
  memcpy(m, code, sizeof code);
  pthread_jit_write_protect_np(1);            /* this thread may execute */
  sys_icache_invalidate(m, sizeof code);
  long (*fib)(long) = (long (*)(long))m;
  long (*big)(void) = (long (*)(void))((char *)m + 56);
  printf("jit fib(25) = %ld, big() = %#lx\n", fib(25), big());
  void *h = malloc(64); memcpy(h, code, sizeof code);   /* what eval.c does today */
  printf("mprotect on heap: %s\n", mprotect((void *)((long)h & -16384L), 16384, PROT_READ|PROT_WRITE|PROT_EXEC) ? "refused" : "allowed");
  return 0;
}
