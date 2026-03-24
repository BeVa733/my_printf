#include <stdio.h>

extern "C" void my_printf(const char* format_str, ...);

int main()
{
    int n_symbs = 0;
    const char* str = "kek";
    printf("privet\n");
    my_printf("privetjhjnlkjio %p n %u po %s pa %o", &n_symbs, -15, str, 10);
    printf("\nN_symbs == %p, %u\n", &n_symbs, -15);

    return 0;
}