import core.stdc.config;
import core.stdc.wctype;
import std.stdio;

extern(C++) void printWcType();

extern(C)
{

version (CRuntime_Glibc)
{
    ///
    alias wctype_t = c_ulong;
    ///
    alias wctrans_t = const(int)*;
}
else version (CRuntime_Musl)
{
    ///
    alias wctype_t = c_ulong;
    ///
    alias wctrans_t = const(int)*;
}
else version (FreeBSD)
{
    ///
    alias wctype_t = c_ulong;
    ///
    alias wctrans_t = c_int;
}
else version (CRuntime_Bionic)
{
    ///
    alias wctype_t = c_long;
    ///
    alias wctrans_t = const(void)*;
}
else
{
    ///
    alias wchar_t wctrans_t;
    ///
    alias wchar_t wctype_t;
}

///
pure int iswalnum(wint_t wc);
///
pure int iswalpha(wint_t wc);
///
pure int iswblank(wint_t wc);
///
pure int iswcntrl(wint_t wc);
///
pure int iswdigit(wint_t wc);
///
pure int iswgraph(wint_t wc);
///
pure int iswlower(wint_t wc);
///
pure int iswprint(wint_t wc);
///
pure int iswpunct(wint_t wc);
///
pure int iswspace(wint_t wc);
///
pure int iswupper(wint_t wc);
///
pure int iswxdigit(wint_t wc);

///
int       iswctype(wint_t wc, wctype_t desc);
///
@system wctype_t  wctype(const scope char* property);
///
pure wint_t    towlower(wint_t wc);
///
pure wint_t    towupper(wint_t wc);
///
wint_t    towctrans(wint_t wc, wctrans_t desc);
///
@system wctrans_t wctrans(const scope char* property);

}


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
