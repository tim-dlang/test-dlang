import std.stdio;

extern(C++) int add(int a, int b);

void main()
{
    int c = add(1, 2);
    writeln("test ", c);
    stdout.flush();
    assert(c == 3);
}
