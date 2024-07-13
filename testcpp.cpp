#include <stdio.h>
#include <wctype.h>

void printWcType()
{
    printf("wint_t.sizeof %zu\n", sizeof(wint_t));
    printf("wctype_t.sizeof %zu\n", sizeof(wctype_t));
    printf("wctrans_t.sizeof %zu\n", sizeof(wctrans_t));
    printf("%d\n", iswalpha('A'));
    printf("%d\n", iswalpha('0'));
    printf("%lld\n", (long long)wctype("alpha"));
    printf("%lld\n", (long long)wctrans("tolower"));
    printf("%d\n", iswctype('A', wctype("alpha")));
    printf("%d\n", iswctype('0', wctype("alpha")));
    printf("%c\n", (char)towctrans('A', wctrans("tolower")));
    printf("%c\n", (char)towctrans('0', wctrans("tolower")));
}
