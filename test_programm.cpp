#include <stdio.h>

extern "C" void my_printf(const char* format_str, ...);

int main()
{
    printf("privet\n");
    my_printf("privetjhjnlkjio %d n %d po %d pa", 5550, 12, 15);
    printf("\n");

    return 0;
}