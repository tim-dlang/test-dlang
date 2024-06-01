struct S
{
    int i;
    S();
    S(int i);
};

S::S() : i(0)
{
}
S::S(int i) : i(i)
{
}

S f()
{
    S r;
    r.i = 5;
    return r;
}
