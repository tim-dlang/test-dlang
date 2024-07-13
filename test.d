import core.stdc.wctype;
import std.stdio;

extern(C++) void printWcType();

void main()
{
    writeln("C++:");
    printWcType();

    writeln("D:");
    writeln("wint_t.sizeof ", wint_t.sizeof);
    writeln("wctype_t.sizeof ", wctype_t.sizeof);
    writeln("wctrans_t.sizeof ", wctrans_t.sizeof);
    writeln(iswalpha('A'));
    writeln(iswalpha('0'));
    writeln(wctype("alpha"));
    writeln(wctrans("tolower"));
    writeln(iswctype('A', wctype("alpha")));
    writeln(iswctype('0', wctype("alpha")));
    writeln(towctrans('A', wctrans("tolower")));
    writeln(towctrans('0', wctrans("tolower")));

    assert(iswalpha('A'));
    assert(!iswalpha('0'));
    wctype_t alpha = wctype("alpha");
    assert(alpha);
    wctrans_t tolower = wctrans("tolower");
    assert(tolower);
    assert(iswctype('A', alpha));
    assert(!iswctype('0', alpha));
    assert(towctrans('A', tolower) == 'a');
    assert(towctrans('0', tolower) == '0');
}
