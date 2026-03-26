#include <stdio.h>

extern "C" void my_printf(const char* format_str, ...);

int main()
{
    printf("===== Тесты my_printf =====\n\n");
    printf("--- %%c ---\n");
    my_printf("%c\n", 'A'); 
    printf("%c\n", 'A'); 
    my_printf("%c%c%c\n", '1', '2', '3'); 
    printf("%c%c%c\n", '1', '2', '3'); 
    printf("\n");

    printf("--- %%d ---\n");
    my_printf("%d\n", 123); 
    printf("%d\n", 123); 
    my_printf("%d\n", -456); 
    printf("%d\n", -456); 
    my_printf("%d %d %d\n", 0, 100, -100); 
    printf("%d %d %d\n", 0, 100, -100); 
    printf("\n");

    printf("--- %%u ---\n");
    my_printf("%u\n", 4294967295U); 
    printf("%u\n", 4294967295U); 
    my_printf("%u %u\n", 0, 123456); 
    printf("%u %u\n", 0, 123456); 
    printf("\n");

    printf("--- %%s ---\n");
    my_printf("%s", "Hello, world!\n"); 
    printf("%s", "Hello, world!\n"); 
    my_printf("%s %s", "foo", "bar\n"); 
    printf("%s %s", "foo", "bar\n"); 
    printf("\n");

    printf("--- %%o ---\n");
    my_printf("%o\n", 255); 
    printf("%o\n", 255); 
    my_printf("%o %o\n", 0, 1); 
    printf("%o %o\n", 0, 1); 
    printf("\n");

    printf("--- %%x / %%p ---\n");
    my_printf("%x\n", 0xdeadbeef);
    printf("%x\n", 0xdeadbeef);
    void* ptr = (void*)0x7fff1234;
    my_printf("%p\n", ptr);
    printf("%p\n", ptr); 
    printf("\n");

    printf("--- %%b ---\n");
    my_printf("%b\n", 10); 
    printf("1010\n"); 
    my_printf("%b %b\n", 0, 1); 
    printf("0 1\n"); 
    printf("\n");

    printf("--- %%f ---\n");
    my_printf("%f\n", 3.14159); 
    printf("%f\n", 3.14159); 
    my_printf("%f\n", -2.5); 
    printf("%f\n", -2.5); 
    my_printf("%f\n", 0.0); 
    printf("%f\n", 0.0); 
    my_printf("%f\n", 1e-6); 
    printf("%f\n", 1e-6); 
    my_printf("%f\n", 1e308);
    printf("%f\n", 1e308); 
    my_printf("%f\n", 1.0/0.0); 
    printf("%f\n", 1.0/0.0); 
    my_printf("%f\n", -1.0/0.0); 
    printf("%f\n", -1.0/0.0); 
    my_printf("%f\n", 0.0/0.0); 
    printf("%f\n", 0.0/0.0); 
    printf("\n");

    printf("--- %%n ---\n");
    int n1, n2;
    my_printf("Hello%n\n", &n1); 
    printf(" -> %d\n", n1);
    printf("Hello%n\n", &n2); 
    printf(" -> %d\n", n2);
    printf("\n");

    printf("--- Mixed ---\n");
    my_printf("%c %d %s %f\n", 'X', 42, "test", 1.234); 
    printf("%c %d %s %f\n", 'X', 42, "test", 1.234); 
    printf("\n");

    printf("--- Many agruments ---\n");
    my_printf("%d %d %d %d %d %d %d %d\n", 1,2,3,4,5,6,7,8);
    printf("%d %d %d %d %d %d %d %d\n", 1,2,3,4,5,6,7,8); 
    my_printf("%d %d %d %d %d %d %f %d\n", 1,2,3,4,5,6,7.0,8); 
    printf("%d %d %d %d %d %d %f %d\n", 1,2,3,4,5,6,7.0,8); 

    printf("===== End Of Tests =====\n");
    return 0;
}