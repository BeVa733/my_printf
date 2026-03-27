#include <stdio.h>

extern "C" void my_printf(const char* format_str, ...);

int main()
{
    printf("===== Тесты my_printf =====\n\n");
    printf("--- %%c ---\n");
    my_printf("%c", 'A'); printf("\n");
    printf("%c", 'A'); printf("\n");
    my_printf("%c%c%c", '1', '2', '3'); printf("\n");
    printf("%c%c%c", '1', '2', '3'); printf("\n");
    printf("\n");

    printf("--- %%d ---\n");
    my_printf("%d", 123); printf("\n");
    printf("%d", 123); printf("\n");
    my_printf("%d", -456); printf("\n");
    printf("%d", -456); printf("\n");
    my_printf("%d %d %d", 0, 100, -100); printf("\n");
    printf("%d %d %d", 0, 100, -100); printf("\n");
    printf("\n");

    printf("--- %%u ---\n");
    my_printf("%u", 4294967295U); printf("\n");
    printf("%u", 4294967295U); printf("\n");
    my_printf("%u %u", 0, 123456); printf("\n");
    printf("%u %u", 0, 123456); printf("\n");
    printf("\n");

    printf("--- %%s ---\n");
    my_printf("%s", "Hello, world!"); printf("\n");
    printf("%s", "Hello, world!"); printf("\n");
    my_printf("%s %s", "foo", "bar"); printf("\n");
    printf("%s %s", "foo", "bar"); printf("\n");
    printf("\n");

    printf("--- %%o ---\n");
    my_printf("%o", 255); printf("\n");
    printf("%o", 255); printf("\n");
    my_printf("%o %o", 0, 1); printf("\n");
    printf("%o %o", 0, 1); printf("\n");
    printf("\n");

    printf("--- %%x / %%p ---\n");
    my_printf("%x", 0xdeadbeef); printf("\n");
    printf("%x", 0xdeadbeef); printf("\n");
    void* ptr = (void*)0x7fff1234;
    my_printf("%p", ptr); printf("\n");
    printf("%p", ptr); printf("\n");
    printf("\n");

    printf("--- %%b ---\n");
    my_printf("%b", 10); printf("\n");
    printf("1010"); printf("\n");
    my_printf("%b %b", 0, 1); printf("\n");
    printf("0 1"); printf("\n");
    printf("\n");

    printf("--- %%f ---\n");
    my_printf("%f", 3.14159); printf("\n");
    printf("%f", 3.14159); printf("\n");
    my_printf("%f", -2.5); printf("\n");
    printf("%f", -2.5); printf("\n");
    my_printf("%f", 0.0); printf("\n");
    printf("%f", 0.0); printf("\n");
    my_printf("%f", 1e-6); printf("\n");
    printf("%f", 1e-6); printf("\n\n");
    my_printf("%f", 1e308); printf("\n");   
    printf("%f", 1e308); printf("\n\n");
    my_printf("%f", 1.0/0.0); printf("\n"); 
    printf("%f", 1.0/0.0); printf("\n");
    my_printf("%f", -1.0/0.0); printf("\n");
    printf("%f", -1.0/0.0); printf("\n");
    my_printf("%f", 0.0/0.0); printf("\n");
    printf("%f", 0.0/0.0); printf("\n");
    printf("\n");

    printf("--- %%n ---\n");
    int n1, n2;
    my_printf("Hello%n", &n1); printf("\n");
    printf(" -> %d\n", n1);
    printf("Hello%n", &n2); printf("\n");
    printf(" -> %d\n", n2);
    printf("\n");

    printf("--- Mixed ---\n");
    my_printf("%c %d %s %f", 'X', 42, "test", 1.234); printf("\n");
    printf("%c %d %s %f", 'X', 42, "test", 1.234); printf("\n");
    printf("\n");

    printf("--- Many agruments ---\n");
    my_printf("%d %d %d %d %d %d %d %d", 1,2,3,4,5,6,7,8); printf("\n");
    printf("%d %d %d %d %d %d %d %d", 1,2,3,4,5,6,7,8); printf("\n");
    my_printf("%d %d %d %d %d %d %f %d", 1,2,3,4,5,6,7.0,8); printf("\n");
    printf("%d %d %d %d %d %d %f %d", 1,2,3,4,5,6,7.0,8); printf("\n");
    printf("\n");

    printf("--- Пустой формат ---\n");
    my_printf(""); printf("\n");
    printf(""); printf("\n");
    printf("\n");

    printf("===== Конец тестов =====\n");
    return 0;
}