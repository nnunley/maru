/* gc.c -- trivial single-threaded stop-world non-moving mark-sweep collector
**
** Copyright (c) 2008 Ian Piumarta
** All Rights Reserved
**
** Permission is hereby granted, free of charge, to any person obtaining a
** copy of this software and associated documentation files (the 'Software'),
** to deal in the Software without restriction, including without limitation
** the rights to use, copy, modify, merge, publish, distribute, and/or sell
** copies of the Software, and to permit persons to whom the Software is
** furnished to do so, provided that the above copyright notice(s) and this
** permission notice appear in all copies of the Software.  Inclusion of the
** the above copyright notice(s) and this permission notice in supporting
** documentation would be appreciated but is not required.
**
** THE SOFTWARE IS PROVIDED 'AS IS'.  USE ENTIRELY AT YOUR OWN RISK.
**
** Last edited: 2012-09-09 11:38:29 by piumarta on linux32
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <assert.h>

#include "gc.h"

#define GC_ALIGN	sizeof(long)
#define GC_QUANTUM	50*1024
#if defined(DEBUGGC)
# define ALLOCS_PER_GC	1
#else
# define ALLOCS_PER_GC	32768
#endif

#define VERBOSE		0

#define BITS_PER_WORD	(sizeof(long) * 8)

typedef struct _gcheader
{
  unsigned long		size  : BITS_PER_WORD - 8	__attribute__((__packed__));
  union {
    unsigned int	flags : 4;
    struct {
      unsigned int	used  : 1;
      unsigned int	atom  : 1;
      unsigned int	mark  : 1;
      unsigned int	weak  : 1;	/* an ephemeron: its first word a key, the rest marked only while the key lives */
    }							__attribute__((__packed__));
  }							__attribute__((__packed__));
  struct _gcheader *next;
  struct _gcfinaliser	*finalisers;
#ifndef NDEBUG
  const char	*file;
  long		 line;
  const char	*func;
#endif
#if defined(GC_APP_HEADER)
  GC_APP_HEADER
#endif
} gcheader;

static inline void *hdr2ptr(gcheader *hdr)	{ return (void *)(hdr + 1); }
static inline gcheader *ptr2hdr(void *ptr)	{ return (gcheader *)ptr - 1; }

#ifndef NDEBUG

GC_API void *GC_stamp(void *ptr, const char *file, long line, const char *func)
{
  gcheader *hdr= ptr2hdr(ptr);
  hdr->file= file;
  hdr->line= line;
  hdr->func= func;
  return ptr;
}

GC_API const char *GC_file(void *ptr)		{ return ptr2hdr(ptr)->file; }
GC_API long	   GC_line(void *ptr)		{ return ptr2hdr(ptr)->line; }
GC_API const char *GC_function(void *ptr)	{ return ptr2hdr(ptr)->func; }

#endif

typedef struct _gcfinaliser
{
  void			*ptr;
  GC_finaliser_t	 finaliser;
  void			*data;
  struct _gcfinaliser	*next;
} gcfinaliser;

static gcheader  gcbase= { 0, { -1 }, &gcbase };

static size_t	gcQuantum= GC_QUANTUM;
static long	gcCount=   ALLOCS_PER_GC;
static long	gcAllocs=  ALLOCS_PER_GC;
static size_t	gcHeap=    0;
static size_t	gcLive=    0;
static size_t	gcUsed=    0;			/* bytes of live and not yet collected blocks, headers included */
static int	gcFixedPace= 0;

static gcfinaliser *finalisable= 0;

//static void bkpt() {}

/* Memory may be bounded, and running out needn't be the end.  When what's in use reaches the limit and a collection doesn't
 * help, the program is told, with a reserve beyond the limit to run its handlers in.  If that's used up too, or it happens
 * again before a collection has made room for a whole reserve under the limit, the program exits.  The same holds when the
 * system refuses memory, for which a real block is held back.
 */
#define GC_RESERVE	(1024 * 1024)
#define GC_HEADROOM	(GC_RESERVE / 4)
#define GC_EXIT_OUT_OF_MEMORY	70			/* not 1, which any error ends a program with */
GC_API size_t GC_heap_limit= 0;				/* 0: as much as the system gives */
GC_API void (*GC_out_of_memory_function)(void)= 0;	/* expected not to return */
static void *gcReserve= 0;
static int   gcEmergency= 0;

/* Free blocks wait in lists by size, linked through their first word, so an allocation doesn't walk the heap: every
 * block stays on the list sweep walks, in address order within each chunk, and sweep rebuilds these lists, merging
 * neighbours as it goes.  Blocks over a thousand bytes share the last list, which is searched for one big enough.
 */
#define GC_BIN_STEP	GC_ALIGN		/* a bin of small blocks holds one size, so taking from it is one step */
#define GC_BINS		128			/* the last holds everything too big for the others */

static gcheader *gcBins[GC_BINS];

static int GC_binFor(size_t size)
{
  size_t bin= size / GC_BIN_STEP;
  return bin < GC_BINS - 1 ? (int)bin : GC_BINS - 1;
}

static void GC_binAdd(gcheader *hdr)
{
  int bin= GC_binFor(hdr->size);
  *(gcheader **)hdr2ptr(hdr)= gcBins[bin];
  gcBins[bin]= hdr;
}

/* a free block of at least lbs, off its list */
static gcheader *GC_binTake(size_t lbs)
{
  gcheader **link;
  int bin;
  for (bin= GC_binFor(lbs);  bin < GC_BINS;  ++bin)
    for (link= &gcBins[bin];  *link;  link= (gcheader **)hdr2ptr(*link))
      if ((*link)->size >= lbs) {
	gcheader *hdr= *link;
	*link= *(gcheader **)hdr2ptr(hdr);
	return hdr;
      }
  return 0;
}

static void GC_addChunk(void *chunk, size_t size)
{
  gcheader *hdr= (gcheader *)chunk;
  hdr->flags= 0;
  hdr->next= gcbase.next;
  gcbase.next= hdr;
  hdr->size= size - sizeof(gcheader);
#if VERBOSE
  fprintf(stderr, "extend by %i at %p\n", (int)hdr->size, hdr);
#endif
  GC_binAdd(hdr);
}

static void GC_collectAndPace(void)
{
#if VERBOSE >= 1
  fprintf(stderr, "GC: collecting\n");
#endif
  GC_gcollect();
  /* no fewer allocations than there are live objects before the next: marking stays in proportion to allocating */
  gcAllocs= (!gcFixedPace && gcLive > (size_t)gcCount) ? (long)gcLive : gcCount;
}

static void GC_giveUp(void)
{
  fprintf(stderr, "GC: out of memory\n");
  exit(GC_EXIT_OUT_OF_MEMORY);
}

static void GC_emergency(void)
{
  if (gcEmergency || !GC_out_of_memory_function) GC_giveUp();
  gcEmergency= 1;
  GC_out_of_memory_function();
  GC_giveUp();						/* no handler took it */
}

GC_API void *GC_malloc(size_t lbs)
{
  gcheader *hdr;
  size_t split, need;
  int collected= 0;
  if (!--gcAllocs) GC_collectAndPace();
  lbs= (lbs + GC_ALIGN-1) & ~(GC_ALIGN-1);
  if (lbs < sizeof(gcheader *)) lbs= (sizeof(gcheader *) + GC_ALIGN-1) & ~(GC_ALIGN-1);
#if VERBOSE > 1
  fprintf(stderr, "malloc %i\n", (int)lbs);
#endif
  need= lbs + sizeof(gcheader);
  if (GC_heap_limit && gcUsed + need > GC_heap_limit + (gcEmergency ? GC_RESERVE : 0)) {
    /* a collection has to win real room: one that frees a few bytes at a time would repeat on every allocation */
    GC_collectAndPace();
    if (gcUsed + need + GC_HEADROOM > GC_heap_limit + (gcEmergency ? GC_RESERVE : 0)) GC_emergency();
  }
  split= lbs + sizeof(gcheader) + GC_ALIGN;
  while (!(hdr= GC_binTake(lbs))) {
    /* grow in proportion to the heap, and no further than a limit could ever use */
    size_t incr= gcHeap / 4 > gcQuantum ? gcHeap / 4 : gcQuantum;
    void *chunk;
    while (incr <= need) incr *= 2;
    if (GC_heap_limit) {
      size_t most= GC_heap_limit + GC_RESERVE + gcQuantum;
      size_t room= most > gcHeap ? most - gcHeap : 0;
      if (incr > room) incr= room > need + GC_ALIGN ? room : need + GC_ALIGN;
    }
    incr &= ~(GC_ALIGN-1);
    chunk= malloc(incr);
    if (chunk) {
      GC_addChunk(chunk, incr);
      gcHeap += incr;
    }
    else if (!collected) {				/* the system has no more: see what a collection frees first */
      collected= 1;
      GC_collectAndPace();
    }
    else if (gcReserve) {				/* room for a handler to run in, then tell the program */
      chunk= gcReserve;
      gcReserve= 0;
      GC_addChunk(chunk, GC_RESERVE);
      gcHeap += GC_RESERVE;
      GC_emergency();
    }
    else GC_giveUp();
  }
  if (hdr->size >= split) {
    gcheader *ins= (gcheader *)(hdr2ptr(hdr) + lbs);
    ins->flags= 0;
    ins->next= hdr->next;
    ins->size= hdr->size - lbs - sizeof(gcheader);
    hdr->next= ins;
    hdr->size= lbs;
    GC_binAdd(ins);
  }
  hdr->used= 1;
  hdr->finalisers= 0;
#if VERBOSE > 2
  fprintf(stderr, "MALLOC %p -> %p + %i\n", hdr2ptr(hdr), hdr, (int)GC_size(hdr2ptr(hdr)));
#endif
  memset(hdr2ptr(hdr), 0, hdr->size);
  gcUsed += sizeof(gcheader) + hdr->size;
  return hdr2ptr(hdr);
}

/* how often to collect: every allocation finds what a collection at the wrong moment would, whenever it falls */
GC_API void GC_collect_every(int allocations)
{
  gcCount= gcAllocs= allocations;
  gcFixedPace= 1;
}

/* 0 if the heap is as it should be: every block accounted for, every free block on the list for its size */
GC_API long GC_check_heap(void)
{
  gcheader *hdr;
  size_t bytes= 0, used= 0, freeBlocks= 0, binned= 0;
  int bin;
  for (hdr= gcbase.next;  hdr != &gcbase;  hdr= hdr->next) {
    if (hdr->size & (GC_ALIGN - 1)) return 1;
    bytes += sizeof(gcheader) + hdr->size;
    if (hdr->flags) used += sizeof(gcheader) + hdr->size;
    else ++freeBlocks;
  }
  if (bytes != gcHeap) return 2;
  if (used != gcUsed) return 6;
  for (bin= 0;  bin < GC_BINS;  ++bin)
    for (hdr= gcBins[bin];  hdr;  hdr= *(gcheader **)hdr2ptr(hdr)) {
      if (hdr->flags) return 3;
      if (GC_binFor(hdr->size) != bin) return 4;
      ++binned;
    }
  if (binned != freeBlocks) return 5;
  return 0;
}

GC_API void GC_set_heap_limit(size_t bytes)
{
  GC_heap_limit= bytes;
}

GC_API size_t GC_bytes_used(void)
{
  return gcUsed;
}

GC_API size_t GC_heap_bytes(void)
{
  return gcHeap;
}

GC_API void *GC_malloc_atomic(size_t lbs)
{
  void *mem= GC_malloc(lbs);
  ptr2hdr(mem)->atom= 1;
  return mem;
}

GC_API void *GC_realloc(void *ptr, size_t lbs)
{
  gcheader *hdr= ptr2hdr(ptr);
  void *mem;
  if (lbs <= hdr->size) return ptr;
  mem= GC_malloc(lbs);
  memcpy(mem, ptr, hdr->size);
  ptr2hdr(mem)->atom= hdr->atom;
  GC_free(ptr);
  return mem;
}

static gcheader *GC_freeHeader(gcheader *hdr)
{
#if VERBOSE > 2
  fprintf(stderr, "FREE %p -> %p %s:%ld %s\n", hdr2ptr(hdr), hdr, hdr->file, hdr->line, hdr->func);
  if (hdr->line == 0) {
    fflush(stdout);
    abort();
  }
#endif
  hdr->flags= 0;
  return hdr;
}

GC_API void GC_free(void *ptr)
{
  gcUsed -= sizeof(gcheader) + ptr2hdr(ptr)->size;
  GC_binAdd(GC_freeHeader(ptr2hdr(ptr)));
}

GC_API size_t GC_size(void *ptr)
{
  return ptr2hdr(ptr)->size;
}

GC_API void GC_default_pre_mark_function(void) {}

GC_pre_mark_function_t GC_pre_mark_function= GC_default_pre_mark_function;

GC_API void GC_default_mark_function(void *ptr)
{
  gcheader *hdr= ptr2hdr(ptr);
  void	  **pos= ptr;
  void	  **lim= hdr2ptr(hdr) + hdr->size - sizeof(void *);
  while (pos <= lim)
    {
      void *field= *pos;
      if (field && !((long)field & 1))
	GC_mark(field);
      ++pos;
    }
}

GC_mark_function_t GC_mark_function= GC_default_mark_function;

/* marking is iterative: what's still to be scanned waits here, so a long list can't overflow the C stack */
static void  **gcMarkStack= 0;
static size_t  gcMarkTop=   0;
static size_t  gcMarkMax=   0;
static int     gcMarking=   0;

/* ephemerons met while marking (Hayes, "Ephemerons", 1997): each waits here until its key is marked from elsewhere, and
   only then are its other words marked; one whose key never is has every word cleared before the sweep */
static void  **gcWeak= 0;
static size_t  gcWeakTop= 0;
static size_t  gcWeakMax= 0;

static void GC_weak_push(void *ptr)
{
  if (gcWeakTop == gcWeakMax) {
    gcWeakMax= gcWeakMax ? gcWeakMax * 2 : 1024;
    gcWeak= realloc(gcWeak, sizeof(void *) * gcWeakMax);
    if (!gcWeak) { fprintf(stderr, "GC: out of memory for ephemerons\n"); abort(); }
  }
  gcWeak[gcWeakTop++]= ptr;
}

GC_API void GC_mark(void *ptr);

static int GC_weak_key_live(void *key)
{
  return !key || ((long)key & 1) || ptr2hdr(key)->mark;
}

/* after the roots: mark what each ephemeron with a live key holds, which may make more keys live, until none does; then
   clear the rest, whose keys only ephemerons held */
static void GC_weak_settle(void)
{
  int progress= 1;
  while (progress) {
    size_t i= 0;
    progress= 0;
    while (i < gcWeakTop) {
      void **obj= gcWeak[i];
      if (GC_weak_key_live(obj[0])) {
	void **pos= obj + 1;
	void **lim= hdr2ptr(ptr2hdr(obj)) + ptr2hdr(obj)->size - sizeof(void *);
	gcWeak[i]= gcWeak[--gcWeakTop];
	while (pos <= lim) { void *field= *pos++;  if (field && !((long)field & 1)) GC_mark(field); }
	progress= 1;
      }
      else
	++i;
    }
  }
  while (gcWeakTop) {
    void **obj= gcWeak[--gcWeakTop];
    memset(obj, 0, ptr2hdr(obj)->size);
  }
}

/* an object becomes an ephemeron; by address, so any evaluator reaches it through subr */
GC_API void GC_weaken(long address)	{ ptr2hdr((void *)address)->weak= 1; }

GC_API void GC_mark(void *ptr)
{
  if ((long)ptr & 1) return;
  gcheader *hdr= ptr2hdr(ptr);
#if VERBOSE > 3
  fprintf(stderr, "mark? %p -> %p used %d atom %d mark %d\n", ptr, hdr, hdr->used, hdr->atom, hdr->mark);
#endif
  if (hdr->mark) return;
  hdr->mark= 1;
  if (hdr->atom) return;
  if (hdr->weak) { GC_weak_push(ptr);  return; }
  if (gcMarkTop == gcMarkMax) {
    gcMarkMax= gcMarkMax ? gcMarkMax * 2 : 4096;
    gcMarkStack= realloc(gcMarkStack, sizeof(void *) * gcMarkMax);
    if (!gcMarkStack) { fprintf(stderr, "GC: out of memory for the mark stack\n"); abort(); }
  }
  gcMarkStack[gcMarkTop++]= ptr;
  if (gcMarking) return;
  gcMarking= 1;
  while (gcMarkTop) GC_mark_function(gcMarkStack[--gcMarkTop]);
  gcMarking= 0;
}

GC_API void GC_mark_leaf(void *ptr)
{
  ptr2hdr(ptr)->mark= 1;
}

GC_free_function_t GC_free_function= 0;

GC_API void GC_sweep(void)
{
  gcheader *hdr= gcbase.next;
  memset(gcBins, 0, sizeof(gcBins));
  gcLive= 0;
  gcUsed= 0;
  do {
#if VERBOSE > 3
    fprintf(stderr, "sweep? %p %d\n", hdr, hdr->flags);
#endif
    if (hdr->flags)
      {
	if (hdr->mark) {
	  hdr->mark= 0;
	  ++gcLive;
	  gcUsed += sizeof(gcheader) + hdr->size;
	}
	else {
	  if (hdr->finalisers) {
	    while (hdr->finalisers) {
	      gcfinaliser *gcf= hdr->finalisers;
	      hdr->finalisers= gcf->next;
	      gcf->next= finalisable;
	      finalisable= gcf;
	    }
	    gcUsed += sizeof(gcheader) + hdr->size;
	  }
	  else {
	    if (GC_free_function) GC_free_function(hdr2ptr(hdr));
	    hdr= GC_freeHeader(hdr);
	  }
	}
      }
    if (!hdr->flags) {
      while (hdr->next != &gcbase && !hdr->next->flags && hdr2ptr(hdr) + hdr->size == (char *)hdr->next) {
	hdr->size += sizeof(gcheader) + hdr->next->size;
	hdr->next= hdr->next->next;
      }
      GC_binAdd(hdr);
    }
    hdr= hdr->next;
  } while (hdr != &gcbase);
  /* ready for next time, once there's room again */
  if (!gcReserve) gcReserve= malloc(GC_RESERVE);
  if (gcEmergency && gcReserve && (!GC_heap_limit || gcUsed + GC_RESERVE <= GC_heap_limit)) gcEmergency= 0;
  while (finalisable)
    {
      gcfinaliser *gcf= finalisable;
      gcf->finaliser(gcf->ptr, gcf->data);
      finalisable= gcf->next;
      free(gcf);
    }
}

static void ***roots= 0;
static size_t numRoots= 0;
static size_t maxRoots= 0;

struct GC_StackRoot *GC_stack_roots= 0;

GC_API void GC_add_root(void *root)
{
  if (numRoots == maxRoots)
    roots= maxRoots
      ? realloc(roots, sizeof(roots[0]) * (maxRoots *= 2))
      : malloc (       sizeof(roots[0]) * (maxRoots= 128));
  roots[numRoots++]= (void **)root;
  assert(root);
}

GC_API void GC_delete_root(void *root)
{
  int i;
  for (i= 0;  i < numRoots;  ++i)
    if (roots[i] == (void **)root)
      break;
  if (i < numRoots)
    {
      memmove(roots + i, roots + i + 1, sizeof(roots[0]) * (numRoots - i));
      --numRoots;
    }
}

GC_API long GC_collections= 0;
GC_API long GC_collection_count(void)	{ return GC_collections; }	/* a weak table drops cleared entries when this moves */

GC_API void GC_gcollect(void)
{
  int i;
  struct GC_StackRoot *sr;
  ++GC_collections;
#if !defined(NDEBUG)
  {
#  undef static
    static char *cursors= "-/|\\";
    static int cursor= 0;
    if (GC_collections % 1000 == 0) {
      if (0 == cursors[cursor]) cursor= 0;
      fprintf(stderr, "%c\010", cursors[cursor]);
      ++cursor;
    }
#  if (NONSTATIC)
#    define static
#  endif
  }
#endif
  GC_pre_mark_function();
#if VERBOSE >= 1
  fprintf(stderr, "*** GC: mark roots\n");
#endif
  for (i= 0;  i < numRoots;  ++i)
    if (*roots[i]) {
#    if VERBOSE >= 2
      fprintf(stderr, "*** GC: root %i *%p -> %p\n", i, roots[i], *roots[i]);
#    endif
      GC_mark(*roots[i]);
    }
#if VERBOSE > 0
  fprintf(stderr, "*** GC: mark stack\n");
#endif
  for (sr= GC_stack_roots;  sr;  sr= sr->next)	{
#if VERBOSE > 2 && defined(DEBUGGC)
    fprintf(stderr, "*** GC: stack root %p %s %s:%ld\n", *sr->root, sr->name, sr->file, sr->line);
#endif
    if (*(sr->root)) GC_mark(*(sr->root));
  }
  GC_weak_settle();
#if VERBOSE > 0
  fprintf(stderr, "*** GC: sweep\n");
#endif
  GC_sweep();
#if VERBOSE > 0
  fprintf(stderr, "*** GC: done\n");
#endif
}

GC_API size_t GC_count_objects(void)
{
  gcheader *hdr= gcbase.next;
  size_t count= 0;
  do {
    if (hdr->used)
      ++count;
    hdr= hdr->next;
  } while (hdr != &gcbase);
  return count;
}

GC_API size_t GC_count_bytes(void)
{
  gcheader *hdr= gcbase.next;
  size_t count= 0;
  do {
    if (hdr->used)
      count += hdr->size;
    hdr= hdr->next;
  } while (hdr != &gcbase);
  return count;
}

GC_API double GC_count_fragments(void)
{
  gcheader *hdr= gcbase.next;
  size_t used= 0;
  size_t free= 0;
  do {
    if (hdr->used) {
      ++used;
      //printf("%p\t%7d\n",   hdr, (int)hdr->size);
    }
    else {
      while ((!hdr->next->used) && (hdr2ptr(hdr) + hdr->size == hdr->next)) {
	hdr->size += sizeof(gcheader) + hdr->next->size;
	hdr->next= hdr->next->next;
      }
      ++free;
      //printf("%p\t\t%7d\n", hdr, (int)hdr->size); 
    }
    hdr= hdr->next;
  } while (hdr != &gcbase);
  return (double)free / (double)used;
}

GC_API void *GC_first_object(void)
{
    gcheader *hdr= gcbase.next;
    while (!hdr->used && hdr != &gcbase) hdr= hdr->next;
    if (hdr == &gcbase) return 0;
    return hdr2ptr(hdr);
}

GC_API void *GC_next_object(void *ptr)
{
    if (!ptr) return 0;
    gcheader *hdr= ptr2hdr(ptr)->next;
    while (!hdr->used && hdr != &gcbase) hdr= hdr->next;
    if (hdr == &gcbase) return 0;
    return hdr2ptr(hdr);
}

GC_API int GC_atomic(void *ptr)
{
  return ptr2hdr(ptr)->atom;
}

#ifndef NDEBUG

GC_API void *GC_check(void *ptr)
{
  gcheader *hdr= ptr2hdr(ptr);
  if (!hdr->used) {
    hdr->used= 1;
    printf("accessible dead object %p %s:%ld %s\n", ptr, hdr->file, hdr->line, hdr->func);
  }
  return ptr;
}

#endif

GC_API void GC_register_finaliser(void *ptr, GC_finaliser_t finaliser, void *data)
{
  gcheader    *gch = ptr2hdr(ptr);
  gcfinaliser *gcf = (struct _gcfinaliser *)malloc(sizeof(struct _gcfinaliser));
  gcf->ptr         = ptr;
  gcf->finaliser   = finaliser;
  gcf->data        = data;
  gcf->next        = gch->finalisers;
  gch->finalisers  = gcf;
}

#if defined(GC_SAVE)

#include <stdint.h>

#define GC_MAGIC	0x4f626a4d

//static void put8  (FILE *out, uint8_t  value)	{ fwrite(&value, sizeof(value), 1, out); }
//static void put16 (FILE *out, uint16_t value)	{ fwrite(&value, sizeof(value), 1, out); }
static void put32 (FILE *out, uint32_t value)	{ fwrite(&value, sizeof(value), 1, out); }
//static void put64 (FILE *out, uint64_t value)	{ fwrite(&value, sizeof(value), 1, out); }

static void putobj(FILE *out, void *value)
{
    //printf("  field %p\n", value);
    if (value && !((long)value & 1))
	fwrite(&ptr2hdr(value)->finalisers, sizeof(void *), 1, out);
    else
	fwrite(&value, sizeof(void *), 1, out);
}

GC_API void GC_saver(FILE *out, void *ptr)
{
    gcheader *hdr= ptr2hdr(ptr);
    if (out) {
	if (hdr->atom)
	    fwrite(hdr2ptr(hdr), hdr->size, 1, out);
	else {
	    int i;
	    for (i= 0;  i < hdr->size;  i += sizeof(void *))
		putobj(out, *(void **)(ptr + i));
	}
    }
}

GC_API void GC_save(FILE *out, void (*saver)(FILE *, void *))
{
    long numObjs= 0;
    long numBytes= 0;
    gcheader *hdr= gcbase.next;
    int i;
    if (!saver) saver= GC_saver;
    do {
	if (hdr->used) {
	    hdr->finalisers= (void *)(numBytes + sizeof(gcheader));
	    numBytes += sizeof(gcheader) + hdr->size;
	    ++numObjs;
	}
	hdr= hdr->next;
    } while (hdr != &gcbase);
    printf("saving %ld bytes, %ld objects, %ld roots\n", numBytes, numObjs, (long)numRoots);
    put32(out, GC_MAGIC);
    put32(out, numObjs);
    put32(out, numBytes);
    hdr= gcbase.next;
    do {
	if (hdr->used) {
	    //printf("writing object %p -> %p\n", hdr2ptr(hdr), hdr->finalisers);
	    put32(out, hdr->size);
	    put32(out, hdr->flags);
	    saver(out, hdr2ptr(hdr));
	    --numObjs;
	}
	hdr= hdr->next;
    } while (hdr != &gcbase);					assert(numObjs == 0);
    put32(out, GC_MAGIC + 1);
    put32(out, numRoots);
    for (i= 0;  i < numRoots;  ++i) {
	void *p= *roots[i];
	//printf("writing root %p -> %p\n", roots[i], p);
	putobj(out, p);
    }
    put32(out, GC_MAGIC + 2);
    hdr= gcbase.next;
    do {
	hdr->finalisers= 0;
	hdr= hdr->next;
    } while (hdr != &gcbase);
}

static int32_t get32(FILE *in, int32_t *p)	{ if(fread(p, sizeof(*p), 1, in));  return *p; }

static void *getobj(FILE *in, void **value)
{
    if (fread(value, sizeof(void *), 1, in));
    if (*value && !(((long)*value) & 1)) *value += (long)gcbase.next;
    //printf("  field %p\n", *value);
    return *value;
}

GC_API void GC_loader(FILE *in, void *ptr)
{
    gcheader *hdr= ptr2hdr(ptr);
    if (hdr->atom)	{ if (fread(hdr2ptr(hdr), hdr->size, 1, in)); }
    else		{ int i;  for (i= 0;  i < hdr->size;  i += sizeof(void *))  getobj(in, ptr + i); }
}

GC_API int GC_load(FILE *in, void (*loader)(FILE *, void*))
{
    int32_t  magic    = 0;
    int32_t  numObjs  = 0;
    int32_t  numBytes = 0;
    int32_t  tmp32;
    int      i;
    if (!loader) loader= GC_loader;
    if (get32(in, &magic) != GC_MAGIC) return 0;
    get32(in, &numObjs);
    get32(in, &numBytes);
    //printf("loading %i bytes, %i objects\n", (int)numBytes, (int)numObjs);
    size_t heapBytes= numBytes + sizeof(gcheader);
    gcheader *hdr= (gcheader *)malloc(heapBytes + GC_ALIGN);	/* the empty block at the end still holds a free list's link */
    if (!hdr) {
	fprintf(stderr, "GC_load: could not allocate %i bytes\n", numBytes);
	exit(1);
    }
    memset(hdr, 0, heapBytes + GC_ALIGN);
    gcbase.next= hdr;
    hdr->flags= 0;
    hdr->next= &gcbase;
    hdr->size= numBytes;
    while (numObjs--) {
	void *ptr= hdr2ptr(hdr);
	//printf("reading object %p -> %p\n", hdr2ptr(hdr) - (long)gcbase.next, hdr2ptr(hdr));
	hdr->size=  get32(in, &tmp32);
	hdr->flags= get32(in, &tmp32);
	loader(in, hdr2ptr(hdr));
	numBytes -= sizeof(gcheader) + hdr->size;		assert(numBytes >= 0);
	hdr->next= ptr + hdr->size;
	hdr= hdr->next;
	hdr->flags= 0;
	hdr->next= &gcbase;
	hdr->size= numBytes;
    };								assert(numBytes == 0);
    get32(in, &tmp32);
    assert(tmp32 == GC_MAGIC + 1);
    if (numRoots != get32(in, &tmp32)) {
	fprintf(stderr, "GC_load: wrong number of roots (expected %i, found %i)\n", (int)numRoots, (int)tmp32);
	exit(1);
    }
    for (i= 0;  i < numRoots;  ++i)  getobj(in, roots[i]);
    gcHeap= heapBytes;						/* the heap is now the image, and its books start from it */
    gcUsed= 0;
    memset(gcBins, 0, sizeof(gcBins));
    for (hdr= gcbase.next;  hdr != &gcbase;  hdr= hdr->next)
      if (hdr->flags) gcUsed += sizeof(gcheader) + hdr->size;
      else GC_binAdd(hdr);
    get32(in, &tmp32);
    assert(tmp32 == GC_MAGIC + 2);
    return 1;
}

#endif

#if 0

#undef VERBOSE
//#define VERBOSE 1

#include <stdlib.h>

long objs= 0, bytes= 0;

#define RAND(N)	({ long n= (1 + (int)((float)N * (rand() / (RAND_MAX + 1.0))));  bytes += n;  n; })

struct cell { int tag;  struct cell *next; };

void *mklist(int n)
{
  struct cell *cell;
  if (!n) return 0;
  cell= GC_malloc(8);  ++objs;  bytes += 8;
  GC_PROTECT(cell);
  cell->tag= n << 1 | 1;
  cell->next= mklist(n - 1);
  GC_UNPROTECT(cell);
  return cell;
}

void delist(struct cell *cell)
{
  if (cell && cell->next && cell->next->next) {
    cell->next= cell->next->next;
    delist(cell->next->next);
  }
}

int main()
{
  int i, j;
  void *a, *b, *c, *d, *e;
  for (i= 0;  i < 10000;  ++i) {
    a= 0;  GC_PROTECT(a);
    b= 0;  GC_PROTECT(b);
    c= 0;  GC_PROTECT(c);
    d= 0;  GC_PROTECT(d);
    e= 0;  GC_PROTECT(e);
#if !VERBOSE
# define printf(...)
#endif
    //#define GC_malloc malloc
    //#define GC_free free
    a= GC_malloc(RAND(1));	    printf("%p\n", a);	++objs;
    b= GC_malloc(RAND(10));	    printf("%p\n", b);	++objs;
    c= GC_malloc(RAND(100));	    printf("%p\n", c);	++objs;
    d= GC_malloc(RAND(1000));	    printf("%p\n", d);	++objs;
    e= GC_malloc(RAND(10000));	    printf("%p\n", e);	++objs;
    GC_free(a);  a= 0;
    GC_free(b);  b= 0;
    //    GC_free(c);
    GC_free(d);  d= 0;
    GC_free(e);  e= 0;
    a= GC_malloc(RAND(100));	    printf("%p\n", a);	++objs;
    b= GC_malloc(RAND(200));	    printf("%p\n", b);	++objs;
    c= GC_malloc(RAND(300));	    printf("%p\n", c);	++objs;
    d= GC_malloc(RAND(400));	    printf("%p\n", d);	++objs;
    e= GC_malloc(RAND(500));	    printf("%p\n", e);	++objs;
    GC_free(e);  e= 0;
    GC_free(d);  d= 0;
    //    GC_free(c);
    GC_free(b);  b= 0;
    GC_free(a);  a= 0;
    a= GC_malloc(RAND(4));	    printf("%p\n", a);	++objs;
    b= GC_malloc(RAND(16));	    printf("%p\n", b);	++objs;
    c= GC_malloc(RAND(64));	    printf("%p\n", c);	++objs;
    d= GC_malloc(RAND(256));	    printf("%p\n", d);	++objs;
    e= GC_malloc(RAND(1024));	    printf("%p\n", e);	++objs;
    GC_free(e);  e= 0;
    GC_free(b);  b= 0;
    //    GC_free(c);
    GC_free(d);  d= 0;
    GC_free(a);  a= 0;
    a= GC_malloc(RAND(713));	    printf("%p\n", a);	++objs;
    b= GC_malloc(RAND(713));	    printf("%p\n", b);	++objs;
    c= GC_malloc(RAND(713));	    printf("%p\n", c);	++objs;
    d= GC_malloc(RAND(713));	    printf("%p\n", d);	++objs;
    e= GC_malloc(RAND(713));	    printf("%p\n", e);	++objs;
    GC_free(a);  a= 0;
    GC_free(c);  c= 0;
    //    GC_free(e);
    GC_free(d);  d= 0;
    GC_free(b);  b= 0;
#undef printf
    if (i % 1000 == 0) printf("alloc: %ld bytes in %ld objects; alive: %ld bytes in %ld objects\n", bytes, objs, GC_count_bytes(), GC_count_objects());
    GC_gcollect();
    if (i % 1000 == 0) printf("   gc: %ld bytes in %ld objects; alive: %ld bytes in %ld objects\n", bytes, objs, GC_count_bytes(), GC_count_objects());
    GC_UNPROTECT(a);
  }
  {
    a= 0;
    GC_PROTECT(a);
    for (i= 0;  i < 10;  ++i) {
      for (j= 0;  j < 100;  ++j) {
	a= mklist(2000);
	delist(a);
#if VERBOSE
	{
	  struct cell *c= a;
	  printf("----\n");
	  while (c) {
	    printf("%p %d %p\n", c, c->tag >> 1, c->next);
	    c= c->next;
	  }
	}
#endif
      }
    printf("alloc: %ld bytes in %ld objects; alive: %ld bytes in %ld objects\n", bytes, objs, GC_count_bytes(), GC_count_objects());
    GC_gcollect();
    printf("   gc: %ld bytes in %ld objects; alive: %ld bytes in %ld objects\n", bytes, objs, GC_count_bytes(), GC_count_objects());
    }
    GC_UNPROTECT(a);
  }
  printf("alive: %ld bytes in %ld objects\n", GC_count_bytes(), GC_count_objects());
  GC_gcollect();
  printf("   gc: %ld bytes in %ld objects\n", GC_count_bytes(), GC_count_objects());
  printf("   gc: %ld collections\n", GC_collections);
  return 0;
}

#endif
