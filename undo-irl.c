#include <stdint.h>
#define __USE_GNU
#include <dlfcn.h>
struct UndoSlot {
  int64_t object;
  int64_t index;
  int64_t world;
  int64_t kind;
  int64_t depth;
};
void *(*v_undo__calloc)(int64_t, int64_t);
void *(*v_undo__realloc)(void *, int64_t);
void (*v_undo__free)(void *);
void (*v_undo__fatal)(char *);
void *(*v_undo__head)(void *);
void *(*v_undo__tail)(void *);
void (*v_undo__set__tail)(void *, void *);
int64_t (*v_undo__kind)(void *);
int64_t (*v_undo__index)(void *);
void (*v_undo__replay)(void *);
void *v_undo__log;
int64_t v_undo__depth;
int64_t v_undo__paused;
struct UndoSlot *v_undo__slots;
int64_t v_undo__slots__size;
int64_t v_undo__slots__used;
int64_t *v_undo__worlds;
int64_t v_undo__worlds__max;
int64_t v_undo__last__world;
int64_t (*v_undo__slot__live)(struct UndoSlot *, int64_t);
int64_t (*v_undo__slot__find)(int64_t, int64_t, int64_t, int64_t, int64_t *);
void (*v_undo__slots__grow)();
int64_t (*v_undo__slot__add)(void *, int64_t, int64_t, int64_t);
int64_t (*v_undo__first)(void *, int64_t, int64_t);
void *(*v_undo__begin)();
void (*v_undo__commit)(void *);
void (*v_undo__rollback)(void *);
void (*v_undo__pause)();
void (*v_undo__resume)();
int64_t (*v_undo__log__size)();
int64_t undo_log_size()
{
    {
        {
      int64_t v_n;
      (v_n=0);
            {
        void *v_l;
        (v_l=v_undo__log);
        while (((int32_t)(((void *)v_l)!=(0))))
        {
          {
            (v_n=((int64_t)((v_n)+(1))));
            (v_l=(v_undo__tail)(v_l));
          }
;
        }
;
        return v_n;
      }
;
    }
;
  }
;
}
void undo_resume()
{
  (v_undo__paused=((int64_t)((v_undo__paused)-(1))));
}
void undo_pause()
{
  (v_undo__paused=((int64_t)((v_undo__paused)+(1))));
}
void undo_rollback(void *v_mark)
{
    {
    while ((((int32_t)(((void *)v_undo__log)!=((void *)v_mark))) && ((int32_t)(((void *)v_undo__log)!=(0)))))
    {
      {
        (v_undo__replay)((v_undo__head)(v_undo__log));
        (v_undo__log=(v_undo__tail)(v_undo__log));
      }
;
    }
;
    (v_undo__depth=((int64_t)((v_undo__depth)-(1))));
    (v_undo__paused=0);
  }
;
}
void undo_commit(void *v_mark)
{
    {
    if (((int32_t)((v_undo__depth)==(1))))
    {
(v_undo__log=0);
    }
    else
    {
      {
                {
          void *v_l;
          (v_l=v_undo__log);
                    {
            void *v_previous;
            (v_previous=0);
            while ((((int32_t)(((void *)v_l)!=((void *)v_mark))) && ((int32_t)(((void *)v_l)!=(0)))))
            {
              {
                                {
                  void *v_entry;
                  (v_entry=(v_undo__head)(v_l));
                  if (((int32_t)(((v_undo__slot__add)((v_undo__head)(v_entry), (v_undo__kind)(v_entry), (v_undo__index)(v_entry), ((int64_t)((v_undo__depth)-(1)))))!=(0))))
                  {
(v_previous=v_l);
                  }
                  else
                  {
if (((int32_t)(((void *)v_previous)==(0))))
                    {
(v_undo__log=(v_undo__tail)(v_l));
                    }
                    else
                    {
(v_undo__set__tail)(v_previous, (v_undo__tail)(v_l));
                    }
;
                  }
;
                  (v_l=(v_undo__tail)(v_l));
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
    (v_undo__depth=((int64_t)((v_undo__depth)-(1))));
  }
;
}
void *undo_begin()
{
    {
    (v_undo__depth=((int64_t)((v_undo__depth)+(1))));
    if (((int32_t)((v_undo__depth)>=(v_undo__worlds__max))))
    {
      {
        (v_undo__worlds__max=(((int32_t)((v_undo__worlds__max)==(0)))?64:((int64_t)((v_undo__worlds__max)*(2)))));
        (v_undo__worlds=((int64_t *)((v_undo__realloc)(v_undo__worlds, ((int64_t)((v_undo__worlds__max)*(((int64_t)(8)))))))));
        if (((int32_t)(((void *)v_undo__worlds)==(0))))
        {
(v_undo__fatal)("out of memory for the undo log");
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
    (v_undo__last__world=((int64_t)((v_undo__last__world)+(1))));
    ((v_undo__worlds)[v_undo__depth]=(v_undo__last__world));
    return v_undo__log;
  }
;
}
int64_t undo_first(void *v_object, int64_t v_kind, int64_t v_index)
{
  return ((int64_t)(((((int32_t)((v_undo__depth)!=(0))) && ((int32_t)((v_undo__paused)==(0)))) && ((int32_t)(((v_undo__slot__add)(v_object, v_kind, v_index, v_undo__depth))!=(0))))));
}
static int64_t f_undo__slot__add(void *v_object, int64_t v_kind, int64_t v_index, int64_t v_d)
{
    {
        {
      int64_t v_o;
      (v_o=((int64_t)(v_object)));
            {
        int64_t v_world;
        (v_world=(v_undo__worlds[v_d]));
                {
          int64_t v_spot;
          (v_spot=0);
          if (((int32_t)((((int64_t)((((int64_t)((v_undo__slots__used)+(1))))*(4))))>=(((int64_t)((v_undo__slots__size)*(3)))))))
          {
(v_undo__slots__grow)();
          }
          else
          {
;
          }
;
          if (((int32_t)(((v_undo__slot__find)(v_o, v_kind, v_index, v_world, (&v_spot)))>=(0))))
          {
return 0;
          }
          else
          {
;
          }
;
          if (((int32_t)((((v_undo__slots[v_spot]).world))==(0))))
          {
(v_undo__slots__used=((int64_t)((v_undo__slots__used)+(1))));
          }
          else
          {
;
          }
;
          ((v_undo__slots[v_spot]).object=v_o);
          ((v_undo__slots[v_spot]).kind=v_kind);
          ((v_undo__slots[v_spot]).index=v_index);
          ((v_undo__slots[v_spot]).world=v_world);
          ((v_undo__slots[v_spot]).depth=v_d);
          return 1;
        }
;
      }
;
    }
;
  }
;
}
static void f_undo__slots__grow()
{
    {
        {
      struct UndoSlot *v_old;
      (v_old=v_undo__slots);
            {
        int64_t v_n;
        (v_n=v_undo__slots__size);
                {
          int64_t v_count;
          (v_count=0);
                    {
            int64_t v_j;
            (v_j=0);
            while (((int32_t)((v_j)<(v_n))))
            {
              {
                if ((v_undo__slot__live)(v_old, v_j))
                {
(v_count=((int64_t)((v_count)+(1))));
                }
                else
                {
;
                }
;
                (v_j=((int64_t)((v_j)+(1))));
              }
;
            }
;
                        {
              int64_t v_size;
              (v_size=(((int32_t)((v_n)==(0)))?1024:v_n));
              while (((int32_t)((((int64_t)((v_count)*(4))))>=(v_size))))
              {
(v_size=((int64_t)((v_size)*(2))));
              }
;
              (v_undo__slots=((struct UndoSlot *)((v_undo__calloc)(v_size, ((int64_t)(40))))));
              if (((int32_t)(((void *)v_undo__slots)==(0))))
              {
(v_undo__fatal)("out of memory for the undo log");
              }
              else
              {
;
              }
;
              (v_undo__slots__size=v_size);
              (v_undo__slots__used=0);
                            {
                int64_t v_spot;
                (v_spot=0);
                (v_j=0);
                while (((int32_t)((v_j)<(v_n))))
                {
                  {
                    if ((v_undo__slot__live)(v_old, v_j))
                    {
                      {
                        (v_undo__slot__find)(((v_old[v_j]).object), ((v_old[v_j]).kind), ((v_old[v_j]).index), ((v_old[v_j]).world), (&v_spot));
                        ((v_undo__slots)[v_spot]=((v_old[v_j])));
                        (v_undo__slots__used=((int64_t)((v_undo__slots__used)+(1))));
                      }
;
                    }
                    else
                    {
;
                    }
;
                    (v_j=((int64_t)((v_j)+(1))));
                  }
;
                }
;
                if (((int32_t)(((void *)v_old)!=(0))))
                {
(v_undo__free)(v_old);
                }
                else
                {
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
;
  }
;
}
static int64_t f_undo__slot__find(int64_t v_object, int64_t v_kind, int64_t v_index, int64_t v_world, int64_t *v_spot)
{
    {
        {
      int64_t v_mask;
      (v_mask=((int64_t)((v_undo__slots__size)-(1))));
            {
        int64_t v_at;
        (v_at=((int64_t)((((int64_t)((((int64_t)((((int64_t)((((int64_t)((((int64_t)((v_object)>>(3))))*(31))))+(((int64_t)((v_kind)*(7)))))))+(((int64_t)((v_index)*(131)))))))+(((int64_t)((v_world)*(2654435761)))))))&(v_mask))));
        ((v_spot)[0]=(-1));
        while (1)
        {
          {
            if (((int32_t)((((v_undo__slots[v_at]).world))==(0))))
            {
              {
                if (((int32_t)(((v_spot[0]))<(0))))
                {
((v_spot)[0]=(v_at));
                }
                else
                {
;
                }
;
                return -1;
              }
;
            }
            else
            {
;
            }
;
            if ((((((int32_t)((((v_undo__slots[v_at]).world))==(v_world))) && ((int32_t)((((v_undo__slots[v_at]).object))==(v_object)))) && ((int32_t)((((v_undo__slots[v_at]).kind))==(v_kind)))) && ((int32_t)((((v_undo__slots[v_at]).index))==(v_index)))))
            {
return v_at;
            }
            else
            {
;
            }
;
            if ((((int32_t)(((v_spot[0]))<(0))) && (!((int64_t)((v_undo__slot__live)(v_undo__slots, v_at))))))
            {
((v_spot)[0]=(v_at));
            }
            else
            {
;
            }
;
            (v_at=((int64_t)((((int64_t)((v_at)+(1))))&(v_mask))));
          }
;
        }
;
        return -1;
      }
;
    }
;
  }
;
}
static int64_t f_undo__slot__live(struct UndoSlot *v_s, int64_t v_at)
{
  return ((int64_t)(((((int32_t)((((v_s[v_at]).world))!=(0))) && ((int32_t)((((v_s[v_at]).depth))<=(v_undo__depth)))) && ((int32_t)(((v_undo__worlds[((v_s[v_at]).depth)]))==(((v_s[v_at]).world)))))));
}
int64_t (*v_undo__log__size)() = undo_log_size;
void (*v_undo__resume)() = undo_resume;
void (*v_undo__pause)() = undo_pause;
void (*v_undo__rollback)(void *) = undo_rollback;
void (*v_undo__commit)(void *) = undo_commit;
void *(*v_undo__begin)() = undo_begin;
int64_t (*v_undo__first)(void *, int64_t, int64_t) = undo_first;
int64_t (*v_undo__slot__add)(void *, int64_t, int64_t, int64_t) = f_undo__slot__add;
void (*v_undo__slots__grow)() = f_undo__slots__grow;
int64_t (*v_undo__slot__find)(int64_t, int64_t, int64_t, int64_t, int64_t *) = f_undo__slot__find;
int64_t (*v_undo__slot__live)(struct UndoSlot *, int64_t) = f_undo__slot__live;
int64_t v_undo__last__world = 0;
int64_t v_undo__worlds__max = 0;
int64_t *v_undo__worlds = 0;
int64_t v_undo__slots__used = 0;
int64_t v_undo__slots__size = 0;
struct UndoSlot *v_undo__slots = 0;
int64_t v_undo__paused = 0;
int64_t v_undo__depth = 0;
void *v_undo__log = 0;
extern void (undo_replay)(void *);
void (*v_undo__replay)(void *) = undo_replay;
extern int64_t (undo_index)(void *);
int64_t (*v_undo__index)(void *) = undo_index;
extern int64_t (undo_kind)(void *);
int64_t (*v_undo__kind)(void *) = undo_kind;
extern void (undo_set_tail)(void *, void *);
void (*v_undo__set__tail)(void *, void *) = undo_set_tail;
extern void *(undo_tail)(void *);
void *(*v_undo__tail)(void *) = undo_tail;
extern void *(undo_head)(void *);
void *(*v_undo__head)(void *) = undo_head;
extern void (undo_fatal)(char *);
void (*v_undo__fatal)(char *) = undo_fatal;
extern void (undo_free)(void *);
void (*v_undo__free)(void *) = undo_free;
extern void *(undo_realloc)(void *, int64_t);
void *(*v_undo__realloc)(void *, int64_t) = undo_realloc;
extern void *(undo_calloc)(int64_t, int64_t);
void *(*v_undo__calloc)(int64_t, int64_t) = undo_calloc;
