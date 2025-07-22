#include <stdint.h>
#define __USE_GNU
#include <dlfcn.h>
struct _3cpoint_3e {
  int32_t x;
  int32_t y;
};
int32_t (*v_printf)(char *, ...);
void (*v_exit)(int32_t);
void (*v_test_2dconditionals)();
void (*v_test_2dcalls_2d1)(char, int16_t, int32_t, int64_t, float, double);
void (*v_test_2dcalls)();
int32_t (*v_printi)(int32_t);
void (*v_test_2dbytes)();
void (*v_test_2dwords)();
void (*v_test_2dints)();
void (*v_test_2dfloats)();
void (*v_init_2d_3cpoint_3e)(struct _3cpoint_3e *, int32_t, int32_t);
void (*v_print_2d_3cpoint_3e)(struct _3cpoint_3e);
struct _3cpoint_3e (*v_make_2d_3cpoint_3e)(int32_t, int32_t);
void (*v_test_2dstructs)();
void *(*v_malloc)(int32_t);
void (*v_free)(void *);
void (*v_test_2dpointers)();
void (*v_test_2dforms)();
static void f_test_2dforms()
{
    {
    int32_t v___limit__;
    int32_t v_i;
    (v___limit__=10);
    (v_i=0);
    while (((int32_t)((v_i)<(v___limit__))))
    {
      {
        (v_printf)("%d ", v_i);
        (v_i=((int32_t)((v_i)+(1))));
      }
;
    }
;
  }
;
  (v_printf)("\012");
  (v_printf)("%d\012", (  {
    int32_t v_a;
    (v_a=1);
    (    {
      int32_t v_b;
      (v_b=((int32_t)((v_a)+(1))));
      (      {
        v_b;
      }
);
    }
);
  }
));
}
static void f_test_2dpointers()
{
    {
    struct _3cpoint_3e v_p;
    (v_p=(v_make_2d_3cpoint_3e)(1, 2));
    if (!(((int32_t)((4)==(((int32_t)(((void *)&(v_p.y))-((void *)&(v_p.x)))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 389);
      (v_exit)(1);
    }
;
  }
;
    {
    void *v_mem;
    (v_mem=(v_malloc)(1024));
        {
      char *v_pb;
      (v_pb=((char *)(v_mem)));
            {
        int16_t *v_pw;
        (v_pw=((int16_t *)(v_mem)));
                {
          int32_t *v_pl;
          (v_pl=((int32_t *)(v_mem)));
                    {
            (v_printf)("memory at %p\012", v_mem);
            ((v_pw)[0]=(258));
            if (((int32_t)((2)==((v_pb[0])))))
            {
              {
                (v_printf)("little endian\012");
                ((((int16_t *)(((void *)v_pw)+(2))))[0]=(772));
                if (!(((int32_t)((50594050)==((v_pl[0]))))))                 {
                  (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 406);
                  (v_exit)(1);
                }
;
              }
;
            }
            else
            {
              {
                if (!(((int32_t)((1)==((v_pb[0]))))))                 {
                  (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 407);
                  (v_exit)(1);
                }
;
                (v_printf)("big endian\012");
                ((((int16_t *)(((void *)v_pw)+(2))))[0]=(772));
                if (!(((int32_t)((16909060)==((v_pl[0]))))))                 {
                  (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 410);
                  (v_exit)(1);
                }
;
              }
;
            }
;
            ((v_pb)[8]=(42));
            if (!(((int32_t)((42)==((((char *)(((void *)v_pb)+(((int32_t)((8)*(1))))))[0]))))))             {
              (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 413);
              (v_exit)(1);
            }
;
            ((v_pw)[8]=(42));
            if (!(((int32_t)((42)==((((int16_t *)(((void *)v_pw)+(((int32_t)((8)*(2))))))[0]))))))             {
              (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 414);
              (v_exit)(1);
            }
;
            ((v_pl)[8]=(42));
            if (!(((int32_t)((42)==((((int32_t *)(((void *)v_pl)+(((int32_t)((8)*(4))))))[0]))))))             {
              (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 415);
              (v_exit)(1);
            }
;
            (v_free)(v_mem);
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
  (v_printf)("pointers ok\012");
}
static void f_test_2dstructs()
{
  if (!(((int32_t)((((int32_t)((2)*(4))))==(8)))))   {
    (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 344);
    (v_exit)(1);
  }
;
    {
    struct _3cpoint_3e v_p;
    (v_p.x=42);
    (v_p.y=666);
        {
      if (!(((int32_t)((42)==((v_p.x))))))       {
        (v_printf)("assertion failed at %s:%d\012", "?", 0);
        (v_exit)(1);
      }
;
      if (!(((int32_t)((666)==((v_p.y))))))       {
        (v_printf)("assertion failed at %s:%d\012", "?", 0);
        (v_exit)(1);
      }
;
    }
;
        {
      int32_t *v_py;
      int32_t *v_px;
      (v_py=&(v_p.y));
      (v_px=&(v_p.x));
      if (!(((int32_t)((42)==((v_px[0]))))))       {
        (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 355);
        (v_exit)(1);
      }
;
      if (!(((int32_t)((666)==((v_py[0]))))))       {
        (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 356);
        (v_exit)(1);
      }
;
    }
;
        {
      struct _3cpoint_3e *v_pp;
      (v_pp=&v_p);
      if (!(((int32_t)(((void *)((void *)(&v_p)))==((void *)((void *)(&(v_p.x))))))))       {
        (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 358);
        (v_exit)(1);
      }
;
      if (!(((int32_t)((4)==(((int32_t)(((void *)((void *)(&(v_p.y))))-((void *)((void *)(&v_p))))))))))       {
        (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 360);
        (v_exit)(1);
      }
;
      if (!(((int32_t)((42)==((((int32_t *)(v_pp))[0]))))))       {
        (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 363);
        (v_exit)(1);
      }
;
      if (!(((int32_t)((666)==((((int32_t *)(v_pp))[1]))))))       {
        (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 364);
        (v_exit)(1);
      }
;
    }
;
    (v_init_2d_3cpoint_3e)(&v_p, 123, 456);
        {
      if (!(((int32_t)((123)==((v_p.x))))))       {
        (v_printf)("assertion failed at %s:%d\012", "?", 0);
        (v_exit)(1);
      }
;
      if (!(((int32_t)((456)==((v_p.y))))))       {
        (v_printf)("assertion failed at %s:%d\012", "?", 0);
        (v_exit)(1);
      }
;
    }
;
    (v_print_2d_3cpoint_3e)(v_p);
    (v_p=(v_make_2d_3cpoint_3e)(777, 888));
        {
      if (!(((int32_t)((777)==((v_p.x))))))       {
        (v_printf)("assertion failed at %s:%d\012", "?", 0);
        (v_exit)(1);
      }
;
      if (!(((int32_t)((888)==((v_p.y))))))       {
        (v_printf)("assertion failed at %s:%d\012", "?", 0);
        (v_exit)(1);
      }
;
    }
;
        {
      struct _3cpoint_3e v_q;
      (v_q=(v_make_2d_3cpoint_3e)(111, 222));
            {
        if (!(((int32_t)((111)==((v_q.x))))))         {
          (v_printf)("assertion failed at %s:%d\012", "?", 0);
          (v_exit)(1);
        }
;
        if (!(((int32_t)((222)==((v_q.y))))))         {
          (v_printf)("assertion failed at %s:%d\012", "?", 0);
          (v_exit)(1);
        }
;
      }
;
            {
        if (!(((int32_t)((777)==((v_p.x))))))         {
          (v_printf)("assertion failed at %s:%d\012", "?", 0);
          (v_exit)(1);
        }
;
        if (!(((int32_t)((888)==((v_p.y))))))         {
          (v_printf)("assertion failed at %s:%d\012", "?", 0);
          (v_exit)(1);
        }
;
      }
;
      (v_p=v_q);
            {
        if (!(((int32_t)((111)==((v_p.x))))))         {
          (v_printf)("assertion failed at %s:%d\012", "?", 0);
          (v_exit)(1);
        }
;
        if (!(((int32_t)((222)==((v_p.y))))))         {
          (v_printf)("assertion failed at %s:%d\012", "?", 0);
          (v_exit)(1);
        }
;
      }
;
    }
;
        {
      if (!(((int32_t)((111)==((v_p.x))))))       {
        (v_printf)("assertion failed at %s:%d\012", "?", 0);
        (v_exit)(1);
      }
;
      if (!(((int32_t)((222)==((v_p.y))))))       {
        (v_printf)("assertion failed at %s:%d\012", "?", 0);
        (v_exit)(1);
      }
;
    }
;
    (v_p=(v_make_2d_3cpoint_3e)(34, 56));
        {
      if (!(((int32_t)((34)==((v_p.x))))))       {
        (v_printf)("assertion failed at %s:%d\012", "?", 0);
        (v_exit)(1);
      }
;
      if (!(((int32_t)((56)==((v_p.y))))))       {
        (v_printf)("assertion failed at %s:%d\012", "?", 0);
        (v_exit)(1);
      }
;
    }
;
    ((&v_p)[0]=((v_make_2d_3cpoint_3e)(78, 90)));
        {
      if (!(((int32_t)((78)==((v_p.x))))))       {
        (v_printf)("assertion failed at %s:%d\012", "?", 0);
        (v_exit)(1);
      }
;
      if (!(((int32_t)((90)==((v_p.y))))))       {
        (v_printf)("assertion failed at %s:%d\012", "?", 0);
        (v_exit)(1);
      }
;
    }
;
  }
;
  (v_printf)("structs ok\012");
}
static struct _3cpoint_3e f_make_2d_3cpoint_3e(int32_t v_x, int32_t v_y)
{
    {
    struct _3cpoint_3e v_p;
    (v_init_2d_3cpoint_3e)(&v_p, v_x, v_y);
    return v_p;
  }
;
}
static void f_print_2d_3cpoint_3e(struct _3cpoint_3e v_p)
{
  (v_printf)("<point>(%d %d)\012", (v_p.x), (v_p.y));
}
static void f_init_2d_3cpoint_3e(struct _3cpoint_3e *v_pp, int32_t v_x, int32_t v_y)
{
  (v_pp->x=v_x);
  (v_pp->y=v_y);
}
static void f_test_2dfloats()
{
    {
    float v_f7;
    float v_f2;
    float v_f1;
    (v_f7=7.000000);
    (v_f2=2.000000);
    (v_f1=-1.000000);
    if (!(((int32_t)((v_f1)==(-1.000000)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 296);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2.000000)==(v_f2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 296);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_f7)==(7.000000)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 296);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_f1)!=(1.000000)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 296);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_f1)<(2.000000)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 297);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_f2)<=(2.000000)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 297);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2.000000)<(v_f7)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 297);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2.000000)>(v_f1)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 298);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2.000000)>=(v_f2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 298);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_f7)>(2.000000)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 298);
      (v_exit)(1);
    }
;
  }
;
  (v_printf)("floats ok\012");
}
static void f_test_2dints()
{
    {
    int32_t v_g;
    int32_t v_f;
    int32_t v_e;
    int32_t v_d;
    int32_t v_c;
    int32_t v_b;
    int32_t v_a;
    (v_g=17171);
    (v_f=320000);
    (v_e=160000);
    (v_d=80000);
    (v_c=40000);
    (v_b=2000);
    (v_a=1000);
    if (!(((int32_t)((160000)==(((int32_t)(v_e)))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 243);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((240000)==(((int32_t)(((int32_t)((v_d)+(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 244);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((320000)==(((int32_t)(((int32_t)((v_e)+(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 245);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-1000)==(((int32_t)(((int32_t)((v_a)-(v_b))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 246);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-158000)==(((int32_t)(((int32_t)((v_b)-(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 247);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2000000)==(((int32_t)(((int32_t)((v_a)*(v_b))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 248);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((40000000)==(((int32_t)(((int32_t)((v_a)*(v_c))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 249);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((((int32_t)(3955359744)))==(((int32_t)(((int32_t)((v_e)*(v_f))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 250);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)==(((int32_t)(((int32_t)((v_f)/(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 251);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((18)==(((int32_t)(((int32_t)((v_f)/(v_g))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 252);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((10922)==(((int32_t)(((int32_t)((v_f)%(v_g))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 253);
      (v_exit)(1);
    }
;
  }
;
    {
    int32_t v_x80kk;
    int32_t v_x0a00;
    (v_x80kk=2147483648);
    (v_x0a00=2560);
    if (!(((int32_t)((2560)==(((int32_t)(((int32_t)((v_x0a00)<<(0))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 255);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((20480)==(((int32_t)(((int32_t)((v_x0a00)<<(3))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 256);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((1342177280)==(((int32_t)(((int32_t)((v_x0a00)<<(19))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 257);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-1610612736)==(((int32_t)(((int32_t)((v_x0a00)<<(20))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 258);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((1073741824)==(((int32_t)(((int32_t)((v_x0a00)<<(21))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 259);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-1)==(((int32_t)(((int32_t)((v_x80kk)>>(31))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 260);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-2)==(((int32_t)(((int32_t)((v_x80kk)>>(30))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 261);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-4)==(((int32_t)(((int32_t)((v_x80kk)>>(29))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 262);
      (v_exit)(1);
    }
;
  }
;
    {
    int32_t v_l8;
    int32_t v_l7;
    int32_t v_l2;
    int32_t v_l1;
    (v_l8=526344);
    (v_l7=460551);
    (v_l2=131586);
    (v_l1=65793);
    if (!(((int32_t)((65793)==(((int32_t)((v_l1)&(v_l7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 265);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((131586)==(((int32_t)((v_l2)&(v_l7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 265);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((0)==(((int32_t)((v_l8)&(v_l7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 265);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((460551)==(((int32_t)((v_l1)|(v_l7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 266);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((460551)==(((int32_t)((v_l2)|(v_l7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 266);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((986895)==(((int32_t)((v_l8)|(v_l7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 266);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((394758)==(((int32_t)((v_l1)^(v_l7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 267);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((328965)==(((int32_t)((v_l2)^(v_l7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 267);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((986895)==(((int32_t)((v_l8)^(v_l7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 267);
      (v_exit)(1);
    }
;
  }
;
    {
    int32_t v_i7;
    int32_t v_i2;
    int32_t v_i1;
    (v_i7=7);
    (v_i2=2);
    (v_i1=-1);
    if (!(((int32_t)((v_i1)==(-1)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 270);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)==(v_i2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 270);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_i7)==(7)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 270);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_i1)!=(1)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 270);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_i1)<(2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 271);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_i2)<=(2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 271);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)<(v_i7)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 271);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)>(v_i1)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 272);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)>=(v_i2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 272);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_i7)>(2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 272);
      (v_exit)(1);
    }
;
  }
;
    {
    int32_t v_x;
    (v_x=305419896);
    if (!(((int32_t)((305419896)==(v_x)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 277);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((120)==(((int32_t)(((char)(v_x)))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 278);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((22136)==(((int32_t)(((int16_t)(v_x)))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 279);
      (v_exit)(1);
    }
;
  }
;
    {
    int32_t v_l;
    int16_t v_w;
    char v_b;
    (v_l=12);
    (v_w=12);
    (v_b=12);
    if (!(((int32_t)((v_b)==(12)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 283);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_w)==(12)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 284);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_l)==(12)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 285);
      (v_exit)(1);
    }
;
  }
;
  if (!(((int32_t)((4)==(((int32_t)((((int32_t)((((int32_t)((((int32_t)((5)*(6))))-(((int32_t)((100)/(5)))))))+(((int32_t)((((int32_t)((7)*(8))))-(((int32_t)((100)/(2))))))))))%(((int32_t)((96)>>(((int32_t)((1)<<(2))))))))))))))   {
    (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 290);
    (v_exit)(1);
  }
;
  (v_printf)("ints ok\012");
}
static void f_test_2dwords()
{
    {
    int16_t v_g;
    int16_t v_f;
    int16_t v_e;
    int16_t v_d;
    int16_t v_c;
    int16_t v_b;
    int16_t v_a;
    (v_g=1717);
    (v_f=32000);
    (v_e=16000);
    (v_d=8000);
    (v_c=4000);
    (v_b=200);
    (v_a=100);
    if (!(((int32_t)((16000)==(((int32_t)(v_e)))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 206);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((24000)==(((int32_t)(((int16_t)((v_d)+(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 207);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((32000)==(((int32_t)(((int16_t)((v_e)+(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 208);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-17536)==(((int32_t)(((int16_t)((v_e)+(v_f))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 209);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-100)==(((int32_t)(((int16_t)((v_a)-(v_b))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 210);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-15800)==(((int32_t)(((int16_t)((v_b)-(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 211);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((20000)==(((int32_t)(((int16_t)((v_a)*(v_b))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 212);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((6784)==(((int32_t)(((int16_t)((v_a)*(v_c))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 213);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-32768)==(((int32_t)(((int16_t)((v_e)*(v_f))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 214);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)==(((int32_t)(((int16_t)((v_f)/(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 215);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((18)==(((int32_t)(((int16_t)((v_f)/(v_g))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 216);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((1094)==(((int32_t)(((int16_t)((v_f)%(v_g))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 217);
      (v_exit)(1);
    }
;
  }
;
    {
    int16_t v_x8000;
    int16_t v_x0a00;
    (v_x8000=32768);
    (v_x0a00=2560);
    if (!(((int32_t)((2560)==(((int32_t)(((int16_t)((v_x0a00)<<(0))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 220);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((20480)==(((int32_t)(((int16_t)((v_x0a00)<<(3))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 221);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((16384)==(((int32_t)(((int16_t)((v_x0a00)<<(5))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 222);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-32768)==(((int32_t)(((int16_t)((v_x8000)>>(0))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 223);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-16384)==(((int32_t)(((int16_t)((v_x8000)>>(1))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 224);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-2)==(((int32_t)(((int16_t)((v_x8000)>>(14))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 225);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-1)==(((int32_t)(((int16_t)((v_x8000)>>(15))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 226);
      (v_exit)(1);
    }
;
  }
;
    {
    int16_t v_w8;
    int16_t v_w7;
    int16_t v_w2;
    int16_t v_w1;
    (v_w8=2056);
    (v_w7=1799);
    (v_w2=514);
    (v_w1=257);
    if (!(((int32_t)((257)==(((int16_t)((v_w1)&(v_w7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 229);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((514)==(((int16_t)((v_w2)&(v_w7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 229);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((0)==(((int16_t)((v_w8)&(v_w7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 229);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((1799)==(((int16_t)((v_w1)|(v_w7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 230);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((1799)==(((int16_t)((v_w2)|(v_w7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 230);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((3855)==(((int16_t)((v_w8)|(v_w7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 230);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((1542)==(((int16_t)((v_w1)^(v_w7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 231);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((1285)==(((int16_t)((v_w2)^(v_w7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 231);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((3855)==(((int16_t)((v_w8)^(v_w7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 231);
      (v_exit)(1);
    }
;
  }
;
    {
    int16_t v_w7;
    int16_t v_w2;
    int16_t v_w1;
    (v_w7=7);
    (v_w2=2);
    (v_w1=-1);
    if (!(((int32_t)((v_w1)==(-1)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 234);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)==(v_w2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 234);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_w7)==(7)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 234);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_w1)!=(1)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 234);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_w1)<(2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 235);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_w2)<=(2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 235);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)<(v_w7)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 235);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)>(v_w1)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 236);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)>=(v_w2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 236);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_w7)>(2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 236);
      (v_exit)(1);
    }
;
  }
;
  (v_printf)("words ok\012");
}
static void f_test_2dbytes()
{
    {
    char v_e;
    char v_d;
    char v_c;
    char v_b;
    char v_a;
    (v_e=160);
    (v_d=80);
    (v_c=40);
    (v_b=20);
    (v_a=10);
    if (!(((int32_t)((-96)==(((int32_t)(v_e)))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 162);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((160)==(((int32_t)((255)&(((int32_t)(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 162);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-16)==(((int32_t)(((char)((v_d)+(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 163);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((240)==(((int32_t)((255)&(((int32_t)(((char)((v_d)+(v_e)))))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 163);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((64)==(((int32_t)(((char)((v_e)+(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 164);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((64)==(((int32_t)((255)&(((int32_t)(((char)((v_e)+(v_e)))))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 165);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-10)==(((int32_t)(((char)((v_a)-(v_b))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 166);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((246)==(((int32_t)((255)&(((int32_t)(((char)((v_a)-(v_b)))))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 166);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((116)==(((int32_t)(((char)((v_b)-(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 167);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((116)==(((int32_t)((255)&(((int32_t)(((char)((v_b)-(v_e)))))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 167);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-56)==(((int32_t)(((char)((v_a)*(v_b))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 168);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((200)==(((int32_t)((255)&(((int32_t)(((char)((v_a)*(v_b)))))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 168);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-112)==(((int32_t)(((char)((v_a)*(v_c))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 169);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((144)==(((int32_t)((255)&(((int32_t)(((char)((v_a)*(v_c)))))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 169);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((32)==(((int32_t)(((char)((v_a)*(v_d))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 170);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((32)==(((int32_t)((255)&(((int32_t)(((char)((v_a)*(v_d)))))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 170);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)==(((int32_t)(((char)((v_b)/(v_a))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 171);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)==(((int32_t)(((char)((v_c)/(v_b))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 172);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((4)==(((int32_t)(((char)((v_d)/(v_b))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 173);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-1)==(((int32_t)(((char)((v_e)/(v_d))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 175);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((10)==(((int32_t)(((char)((v_a)%(v_b))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 176);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((0)==(((int32_t)(((char)((v_b)%(v_a))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 176);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((20)==(((int32_t)(((char)((v_b)%(v_c))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 177);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((0)==(((int32_t)(((char)((v_c)%(v_b))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 177);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((40)==(((int32_t)(((char)((v_c)%(v_d))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 178);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((0)==(((int32_t)(((char)((v_d)%(v_c))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 178);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((80)==(((int32_t)(((char)((v_d)%(v_e))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 180);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-16)==(((int32_t)(((char)((v_e)%(v_d))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 180);
      (v_exit)(1);
    }
;
  }
;
    {
    char v_x80;
    char v_x0a;
    (v_x80=128);
    (v_x0a=10);
    if (!(((int32_t)((10)==(((int32_t)(((char)((v_x0a)<<(0))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 183);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((80)==(((int32_t)(((char)((v_x0a)<<(3))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 184);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-96)==(((int32_t)(((char)((v_x0a)<<(4))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 185);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-128)==(((int32_t)(((char)((v_x80)>>(0))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 186);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-64)==(((int32_t)(((char)((v_x80)>>(1))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 187);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-2)==(((int32_t)(((char)((v_x80)>>(6))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 188);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((-1)==(((int32_t)(((char)((v_x80)>>(7))))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 189);
      (v_exit)(1);
    }
;
  }
;
    {
    char v_b8;
    char v_b7;
    char v_b2;
    char v_b1;
    (v_b8=8);
    (v_b7=7);
    (v_b2=2);
    (v_b1=1);
    if (!(((int32_t)((1)==(((char)((v_b1)&(v_b7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 192);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)==(((char)((v_b2)&(v_b7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 192);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((0)==(((char)((v_b8)&(v_b7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 192);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((7)==(((char)((v_b1)|(v_b7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 193);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((7)==(((char)((v_b2)|(v_b7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 193);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((15)==(((char)((v_b8)|(v_b7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 193);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((6)==(((char)((v_b1)^(v_b7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 194);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((5)==(((char)((v_b2)^(v_b7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 194);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((15)==(((char)((v_b8)^(v_b7))))))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 194);
      (v_exit)(1);
    }
;
  }
;
    {
    char v_b7;
    char v_b2;
    char v_b1;
    (v_b7=7);
    (v_b2=2);
    (v_b1=-1);
    if (!(((int32_t)((v_b1)==(-1)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 197);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)==(v_b2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 197);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_b7)==(7)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 197);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_b1)!=(1)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 197);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_b1)<(2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 198);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_b2)<=(2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 198);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)<(v_b7)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 198);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)>(v_b1)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 199);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((2)>=(v_b2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 199);
      (v_exit)(1);
    }
;
    if (!(((int32_t)((v_b7)>(2)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 199);
      (v_exit)(1);
    }
;
  }
;
  (v_printf)("bytes ok\012");
}
static int32_t f_printi(int32_t v_i)
{
  (v_printf)("%d\012", v_i);
  return v_i;
}
static void f_test_2dcalls()
{
    {
    double v_f64;
    float v_f32;
    int64_t v_i64;
    int32_t v_i32;
    int16_t v_i16;
    char v_i8;
    (v_f64=7.800000);
    (v_f32=5.600000);
    (v_i64=4);
    (v_i32=3);
    (v_i16=2);
    (v_i8=1);
    (v_test_2dcalls_2d1)(v_i8, v_i16, v_i32, v_i64, v_f32, v_f64);
    (v_printf)("%d %d %d %lld %f %f \012", ((int32_t)(v_i8)), ((int32_t)(v_i16)), v_i32, v_i64, ((double)(v_f32)), v_f64);
  }
;
}
static void f_test_2dcalls_2d1(char v_i8, int16_t v_i16, int32_t v_i32, int64_t v_i64, float v_f32, double v_f64)
{
  (v_printf)("%d %d %d %lld %f %f \012", ((int32_t)(v_i8)), ((int32_t)(v_i16)), v_i32, v_i64, ((double)(v_f32)), v_f64);
}
static void f_test_2dconditionals()
{
    {
    int32_t v_i;
    int32_t v_x;
    (v_i=0);
    (v_x=0);
    while (((int32_t)((v_i)<(10))))
    {
      {
        (v_printf)("%d %d  ", v_i, v_x);
        (v_x=((int32_t)((v_x)+((v_i=((int32_t)((v_i)+(1))))))));
      }
;
    }
;
    if (!(((int32_t)((v_x)==(55)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 97);
      (v_exit)(1);
    }
;
    (v_printf)("\012");
    (v_x=0);
    (v_i=0);
    while (((int32_t)(((v_i=((int32_t)((v_i)+(1)))))<(10))))
    {
      {
        if (((int32_t)((v_i)<(5))))
        {
          {
            (v_printf)("%i<5 ", v_i);
            (v_x=((int32_t)((v_x)+(v_i))));
          }
;
        }
        else
        {
;
        }
;
        (v_printf)("%s ", (((int32_t)((0)==(((int32_t)((v_i)%(2))))))?"even":"odd"));
      }
;
    }
;
    (v_printf)("\012");
    if (!(((int32_t)((v_x)==(10)))))     {
      (v_printf)("assertion failed at %s:%d\012", "maru-check.k", 112);
      (v_exit)(1);
    }
;
  }
;
}
int32_t f_main(int32_t v_argc, char **v_argv)
{
  (v_printf)("%d\012", (v_printf)("Hello, world\012"));
  (v_test_2dconditionals)();
  (v_test_2dcalls)();
  (v_test_2dbytes)();
  (v_test_2dwords)();
  (v_test_2dints)();
  (v_test_2dfloats)();
  (v_test_2dstructs)();
  (v_test_2dpointers)();
  (v_test_2dforms)();
  return 0;
}
int main(int argc, char **argv)
{
  (v_test_2dforms=f_test_2dforms);
  (v_test_2dpointers=f_test_2dpointers);
  (v_free=dlsym(RTLD_DEFAULT, "free"));
  (v_malloc=dlsym(RTLD_DEFAULT, "malloc"));
  (v_test_2dstructs=f_test_2dstructs);
  (v_make_2d_3cpoint_3e=f_make_2d_3cpoint_3e);
  (v_print_2d_3cpoint_3e=f_print_2d_3cpoint_3e);
  (v_init_2d_3cpoint_3e=f_init_2d_3cpoint_3e);
  (v_test_2dfloats=f_test_2dfloats);
  (v_test_2dints=f_test_2dints);
  (v_test_2dwords=f_test_2dwords);
  (v_test_2dbytes=f_test_2dbytes);
  (v_printi=f_printi);
  (v_test_2dcalls=f_test_2dcalls);
  (v_test_2dcalls_2d1=f_test_2dcalls_2d1);
  (v_test_2dconditionals=f_test_2dconditionals);
  ;
  (v_exit=dlsym(RTLD_DEFAULT, "exit"));
  (v_printf=dlsym(RTLD_DEFAULT, "printf"));
  f_main(argc, argv);
  return 0;
}
