#include <stdio.h>

extern "C" void my_printf(const char* format_str, ...);

int main()
{
    int n_symbs = 0;
    printf("privet\n");
    my_printf("privetjhjnlkjio %n n %o po %o pa %o", &n_symbs, 8, 15, 10);
    printf("\nN_symbs == %d\n", n_symbs);

    return 0;
}