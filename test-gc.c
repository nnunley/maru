#include <stdint.h>
#define __USE_GNU
#include <dlfcn.h>
struct _3ccell_3e {
  int32_t head;
  struct _3ccell_3e *tail;
};
struct _3cheader_3e {
  int32_t size;
  int32_t flags;
  struct _3cheader_3e *next;
  int32_t type;
};
int32_t (*v_printf)(char *, ...);
void (*v_exit)(int32_t);
void *(*v_malloc)(int32_t);
void (*v_free)(void *);
void *(*v_memset)(void *, int32_t, int32_t);
void *(*v_memcpy)(void *, void *, int32_t);
struct _3cheader_3e *v_gc__memory__base;
struct _3cheader_3e *v_gc__memory__last;
int32_t v_gc__alloc__count;
int32_t v_gc__root__count;
void ***v_gc__roots;
int32_t v_gc__root__max;
int32_t v_gc__objects__live;
int32_t v_gc__bytes__used;
int32_t v_gc__bytes__free;
int32_t v_gc__allocation__count;
int32_t v_gc__collection__count;
int32_t v_log2_2dsizeof_2dlong;
void (*v_fatal)(char *);
int32_t (*v_max)(int32_t, int32_t);
void *(*v_new__memory__block)(int32_t);
void (*v_gc__initialise)();
void (*v_gc__push__root)(void *);
void (*v_gc__pop__root)(void *);
void (*v_gc__grow__memory)(int32_t);
int32_t (*v_gc__size)(void *);
void (*v_gc__sweep)();
void (*v_gc__mark__and__trace)(void *);
void (*v_gc__gcollect)();
void *(*v_gc__malloc)(int32_t);
void *(*v_gc__malloc__atomic)(int32_t);
struct _3ccell_3e *(*v_make__cell)(int32_t, struct _3ccell_3e *);
struct _3ccell_3e *(*v_make__list)(int32_t);
void (*v_print__list)(struct _3ccell_3e *);
void (*v_info)();
static int32_t f_main(int32_t v_argc, char **v_argv)
{
  (v_gc__initialise)();
    {
    struct _3ccell_3e *v_obj;
    int32_t v_i;
    (v_obj=((struct _3ccell_3e *)(0)));
    (v_i=0);
        {
      (v_gc__push__root)(&v_obj);
      while (((int32_t)((v_i)<(10000))))
      {
        {
          if (!(((int32_t)((v_i)%(10)))))           {
            (v_info)();
          }
;
          (v_obj=(v_make__list)(256));
          (v_i=((int32_t)((v_i)+(1))));
        }
;
      }
;
      (v_gc__gcollect)();
      (v_gc__pop__root)(&v_obj);
    }
;
  }
;
  (v_gc__gcollect)();
  (v_info)();
  return ((int32_t)(0));
}
static void f_info()
{
  (v_printf)("GC: %d used, %d free, %d allocations, %d collections, %d live\012", v_gc__bytes__used, v_gc__bytes__free, v_gc__allocation__count, v_gc__collection__count, v_gc__objects__live);
}
static void f_print__list(struct _3ccell_3e *v_list)
{
    {
    struct _3ccell_3e *v_l;
    (v_l=v_list);
    while (v_l)
    {
      {
        (v_printf)("%08x.%-5i      ", v_list, (v_list->head));
        (v_l=(v_l->tail));
      }
;
    }
;
  }
;
  if (v_list)
  {
(v_printf)("\012");
  }
  else
  {
;
  }
;
}
static struct _3ccell_3e *f_make__list(int32_t v_size)
{
  if (v_size)
  {
    {
      struct _3ccell_3e *v_list;
      (v_list=(v_make__list)(((int32_t)((v_size)-(1)))));
      (v_gc__push__root)(&v_list);
      (v_list=(v_make__cell)(((int32_t)((1)|(((int32_t)((v_size)<<(1)))))), v_list));
      (v_gc__pop__root)(&v_list);
      return v_list;
    }
;
  }
  else
  {
return 0;
  }
;
}
static struct _3ccell_3e *f_make__cell(int32_t v_head, struct _3ccell_3e *v_tail)
{
    {
    struct _3ccell_3e *v_cell;
    (v_cell=((struct _3ccell_3e *)((v_gc__malloc)(8))));
    (v_cell->head=v_head);
    (v_cell->tail=v_tail);
    return v_cell;
  }
;
}
static void *f_gc__malloc__atomic(int32_t v_size)
{
    {
    void *v_obj;
    (v_obj=(v_gc__malloc)(v_size));
    (((struct _3cheader_3e *)(((void *)((struct _3cheader_3e *)(v_obj)))-(1)))->flags=3);
    return v_obj;
  }
;
}
static void *f_gc__malloc(int32_t v_size)
{
  (v_size=((int32_t)((((int32_t)((v_size)+(((int32_t)(((int32_t)((4)-(1)))))))))&(((int32_t)((-((int32_t)(4)))))))));
  if (((int32_t)((v_gc__alloc__count)==(32768)))) (v_gc__gcollect)();
    {
    struct _3cheader_3e *v_first;
    (v_first=(v_gc__memory__last->next));
        {
      struct _3cheader_3e *v_chunk;
      (v_chunk=v_first);
            {
        int32_t v_ssize;
        (v_ssize=((int32_t)((v_size)+(16))));
                {
          while (1)
          {
            {
              while ((              {
                (v_printf)("alloc? %d %p %p [%p] %d >= %d %d\012", (v_chunk->flags), v_chunk, (v_chunk->next), v_first, (v_chunk->size), v_size, ((int32_t)((v_size)<=((v_chunk->size)))));
                if (((int32_t)((0)==((v_chunk->flags)))))
                {
                  {
                    int32_t v_csize;
                    (v_csize=(v_chunk->size));
                    while ((((int32_t)((0)==(((v_chunk->next)->flags)))) && ((int32_t)(((void *)(v_chunk->next))==((void *)((struct _3cheader_3e *)(((void *)v_chunk)+(1))))))))
                    {
                      {
                        struct _3cheader_3e *v_next;
                        (v_next=(v_chunk->next));
                        (v_chunk->next=(v_next->next));
                        (v_csize=(v_chunk->size=((int32_t)((v_csize)+(((int32_t)((16)+((v_next->size)))))))));
                        if (((int32_t)(((void *)v_next)==((void *)v_gc__memory__last)))) (v_gc__memory__last=v_chunk);
                      }
;
                    }
;
                    if ((((int32_t)((v_ssize)<(v_csize))) || ((int32_t)((v_size)==(v_csize)))))
                    {
                      {
                        (v_printf)("csize %d\012", v_csize);
                        if (((int32_t)((v_csize)>(v_ssize))))                         {
                          struct _3cheader_3e *v_split;
                          (v_split=((struct _3cheader_3e *)(((void *)(((void *)((void *)(v_chunk)))+(v_ssize))))));
                          (v_printf)("split %d: %p + %d -> %p + %d\012", v_csize, v_chunk, v_size, v_split, ((int32_t)((v_csize)-(((int32_t)((v_size)+(16)))))));
                          (v_split->size=((int32_t)((v_csize)-(((int32_t)((v_size)+(16)))))));
                          (v_split->flags=0);
                          (v_split->next=(v_chunk->next));
                          (v_chunk->size=v_size);
                          (v_chunk->next=v_split);
                          (v_csize=v_size);
                        }
;
                        (v_chunk->flags=1);
                        (v_gc__memory__last=v_chunk);
                        (v_printf)("alloc chunk %p\012", v_chunk);
                                                {
                          struct _3cheader_3e *v_obj;
                          (v_obj=((struct _3cheader_3e *)(((void *)v_chunk)+(1))));
                          (v_memset)(v_obj, ((int32_t)(0)), v_csize);
                          (v_gc__alloc__count=((int32_t)((v_gc__alloc__count)+(1))));
                          (v_gc__allocation__count=((int32_t)((v_gc__allocation__count)+(1))));
                          return v_obj;
                        }
;
                      }
;
                    }
                    else
                    {
;
                    }
;
                  }
;
                }
                else
                {
;
                }
;
                ((int32_t)(((void *)v_first)!=((void *)(v_chunk=(v_chunk->next)))));
              }
))
              {
;
              }
;
              (v_gc__grow__memory)((v_max)(((int32_t)((16)+(v_size))), 59392));
            }
;
          }
;
        }
;
      }
;
    }
;
  }
;
  return 0;
}
static void f_gc__gcollect()
{
  if (!(((int32_t)((1023)&((v_gc__collection__count=((int32_t)((v_gc__collection__count)+(1))))))))) (v_printf)("%d collections\012", v_gc__collection__count, 1);
    {
    int32_t v_i;
    (v_i=((int32_t)(0)));
    while (((int32_t)((v_i)<(v_gc__root__count))))
    {
      {
                {
          void **v_ptr;
          (v_ptr=(v_gc__roots[v_i]));
          (v_printf)("mark gc root %d : %p -> %p\012", v_i, v_ptr, (v_ptr[0]));
        }
;
        (v_gc__mark__and__trace)(((v_gc__roots[v_i])[0]));
        (v_i=((int32_t)((1)+(v_i))));
      }
;
    }
;
  }
;
  (v_gc__sweep)();
  (v_gc__alloc__count=0);
}
static void f_gc__mark__and__trace(void *v_obj)
{
  if (v_obj && (!((int32_t)(((int32_t)((1)&(((int32_t)(v_obj)))))))))   {
    struct _3cheader_3e *v_ptr;
    (v_ptr=((struct _3cheader_3e *)(((void *)((struct _3cheader_3e *)(v_obj)))-(1))));
        {
      int32_t v_flags;
      (v_flags=(v_ptr->flags));
            {
        (v_printf)("mark and trace %p flags %d\012", v_obj, v_flags);
        if (!(((int32_t)((1)&(v_flags))))) (v_fatal)("attempt to mark dead object");
        if (!(((int32_t)((v_flags)&(4)))))         {
          (v_ptr->flags=((int32_t)((v_flags)|(4))));
          if (!(((int32_t)((v_flags)&(2)))))           {
            int32_t v_size;
            (v_size=((int32_t)(((v_ptr->size))>>(v_log2_2dsizeof_2dlong))));
            (v_printf)("mark %p %d type %d\012", v_ptr, v_size, (v_ptr->type));
            while (v_size)
            {
              {
                (v_size=((int32_t)((v_size)-(1))));
                (v_printf)("@%d %p\012", v_size, (((void **)(v_obj))[v_size]));
                (v_gc__mark__and__trace)((((void **)(v_obj))[v_size]));
              }
;
            }
;
          }
;
        }
;
      }
;
    }
;
  }
;
}
static void f_gc__sweep()
{
  (v_printf)("sweep\012");
    {
    int32_t v_nfree;
    int32_t v_nused;
    int32_t v_nobjs;
    struct _3cheader_3e *v_ptr;
    (v_nfree=((int32_t)(0)));
    (v_nused=((int32_t)(0)));
    (v_nobjs=((int32_t)(0)));
    (v_ptr=v_gc__memory__base);
    while (v_ptr)
    {
      {
        (v_printf)("sweep? %d %p + %d\012", (v_ptr->flags), v_ptr, (v_ptr->size));
                {
          int32_t v_flags;
          (v_flags=(v_ptr->flags));
          if (((int32_t)((v_flags)&(4))))
          {
            {
              (v_nused=((int32_t)((v_nused)+((v_ptr->size)))));
              (v_nobjs=((int32_t)((v_nobjs)+(1))));
              (v_ptr->flags=((int32_t)((v_flags)^(4))));
            }
;
          }
          else
          {
            {
              (v_printf)("collect %p %d\012", v_ptr, (v_ptr->size));
              (v_nfree=((int32_t)((v_nfree)+((v_ptr->size)))));
              (v_ptr->flags=0);
            }
;
          }
;
        }
;
        if (((int32_t)(((void *)v_gc__memory__base)==((void *)(v_ptr=(v_ptr->next)))))) (v_ptr=0);
      }
;
    }
;
    (v_gc__objects__live=v_nobjs);
    (v_gc__bytes__used=v_nused);
    (v_gc__bytes__free=v_nfree);
    (v_printf)("GC: %d used, %d free, %d allocations\012", v_nused, v_nfree, v_gc__alloc__count);
  }
;
}
static int32_t f_gc__size(void *v_obj)
{
  return (((struct _3cheader_3e *)(((void *)((struct _3cheader_3e *)(v_obj)))-(1)))->size);
}
static void f_gc__grow__memory(int32_t v_size)
{
    {
    struct _3cheader_3e *v_brk;
    (v_brk=((struct _3cheader_3e *)((v_new__memory__block)(v_size))));
    (v_brk->next=(v_gc__memory__last->next));
    (v_gc__memory__last->next=v_brk);
  }
;
}
static void f_gc__pop__root(void *v_ptr)
{
  if (!(v_gc__root__count)) (v_fatal)("root table underflow");
  (v_gc__root__count=((int32_t)((v_gc__root__count)-(1))));
  (v_printf)("gc POP  root %d at %p\012", v_gc__root__count, v_ptr);
  if (!(((int32_t)(((void *)v_ptr)==((void *)(v_gc__roots[v_gc__root__count])))))) (v_fatal)("non-lifo root");
}
static void f_gc__push__root(void *v_ptr)
{
  if (((int32_t)((v_gc__root__count)==(v_gc__root__max))))   {
    void *v_roots;
    (v_roots=(v_malloc)(((int32_t)((4)*((v_gc__root__max=(v_max)(32, ((int32_t)((2)*(v_gc__root__max))))))))));
    (v_memcpy)(v_roots, v_gc__roots, ((int32_t)((4)*(v_gc__root__count))));
    if (v_gc__roots) (v_free)(v_gc__roots);
    (v_gc__roots=v_roots);
  }
;
  ((v_gc__roots)[v_gc__root__count]=(v_ptr));
  (v_printf)("gc PUSH root %d at %p\012", v_gc__root__count, v_ptr);
  (v_gc__root__count=((int32_t)((1)+(v_gc__root__count))));
}
static void f_gc__initialise()
{
    {
    void *v_ptr;
    (v_ptr=(v_new__memory__block)(59392));
    (v_gc__memory__base=v_ptr);
    (v_gc__memory__last=v_ptr);
  }
;
}
static void *f_new__memory__block(int32_t v_size)
{
    {
    struct _3cheader_3e *v_ptr;
    (v_ptr=((struct _3cheader_3e *)((v_malloc)(v_size))));
    if (!(v_ptr)) (v_fatal)("out of memory");
    (v_ptr->size=((int32_t)((v_size)-(16))));
    (v_ptr->flags=0);
    (v_ptr->next=v_ptr);
    (v_printf)("BRK %p %d %d/%d\012", v_ptr, v_size, v_gc__alloc__count, 32768);
    return v_ptr;
  }
;
}
static int32_t f_max(int32_t v_a, int32_t v_b)
{
  return (((int32_t)((v_a)>=(v_b)))?v_a:v_b);
}
static void f_fatal(char *v_reason)
{
  (v_printf)("\012maru: %s\012", v_reason);
  (v_exit)(((int32_t)(1)));
}
int main(int argc, char **argv)
{
  ;
  (v_info=f_info);
  (v_print__list=f_print__list);
  (v_make__list=f_make__list);
  (v_make__cell=f_make__cell);
  (v_gc__malloc__atomic=f_gc__malloc__atomic);
  (v_gc__malloc=f_gc__malloc);
  (v_gc__gcollect=f_gc__gcollect);
  (v_gc__mark__and__trace=f_gc__mark__and__trace);
  (v_gc__sweep=f_gc__sweep);
  (v_gc__size=f_gc__size);
  (v_gc__grow__memory=f_gc__grow__memory);
  (v_gc__pop__root=f_gc__pop__root);
  (v_gc__push__root=f_gc__push__root);
  (v_gc__initialise=f_gc__initialise);
  (v_new__memory__block=f_new__memory__block);
  (v_max=f_max);
  (v_fatal=f_fatal);
  (v_log2_2dsizeof_2dlong=3);
  (v_gc__collection__count=0);
  (v_gc__allocation__count=0);
  (v_gc__bytes__free=0);
  (v_gc__bytes__used=0);
  (v_gc__objects__live=0);
  (v_gc__root__max=0);
  (v_gc__roots=0);
  (v_gc__root__count=0);
  (v_gc__alloc__count=0);
  (v_gc__memory__last=0);
  (v_gc__memory__base=0);
  (v_memcpy=dlsym(RTLD_DEFAULT, "memcpy"));
  (v_memset=dlsym(RTLD_DEFAULT, "memset"));
  (v_free=dlsym(RTLD_DEFAULT, "free"));
  (v_malloc=dlsym(RTLD_DEFAULT, "malloc"));
  (v_exit=dlsym(RTLD_DEFAULT, "exit"));
  (v_printf=dlsym(RTLD_DEFAULT, "printf"));
  f_main(argc, argv);
  return 0;
}
