import std.stdio;

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
