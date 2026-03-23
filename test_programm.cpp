#include <stdio.h>

extern "C" void my_printf(const char* format_str, ...);

int main()
{
    printf("privet\n");
    my_printf("privetjhjnlkjio %b u %b h %b j %b n %b l %b kj %b n", 33, 32, 0, 15, 22, 12, 2);
    printf("\n");

    return 0;
}