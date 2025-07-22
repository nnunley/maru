#include <stdint.h>
#define __USE_GNU
#include <dlfcn.h>
struct _3cPoint_3e {
  int32_t x;
  int32_t y;
};
int32_t (*v_printf)(char *, ...);
int32_t (*v_print_2dpoint)(struct _3cPoint_3e);
static int32_t f_main(int32_t v_argc, char **v_argv)
{
    {
    struct _3cPoint_3e v_point;
    (v_point.x=42);
    (v_point.y=666);
        {
      int32_t v_sum;
      (v_sum=(v_print_2dpoint)(v_point));
      (v_printf)("Sum is %d\012", v_sum);
    }
;
  }
;
  return 0;
}
static int32_t f_print_2dpoint(struct _3cPoint_3e v_p)
{
  (v_printf)("Point with x = %d and y = %d\012", (v_p.x), (v_p.y));
  return ((int32_t)(((v_p.x))+((v_p.y))));
}
int main(int argc, char **argv)
{
  ;
  (v_print_2dpoint=f_print_2dpoint);
  (v_printf=dlsym(RTLD_DEFAULT, "printf"));
  f_main(argc, argv);
  return 0;
}
