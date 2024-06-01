import std.stdio;

// See https://issues.dlang.org/show_bug.cgi?id=24577

extern(C++) struct S
{
    int i;
    this(int i);
}

extern(C++) S f();

void main()
{
    S s = f();
    writeln("test ", s);
    stdout.flush();
    assert(s.i == 5);
}
