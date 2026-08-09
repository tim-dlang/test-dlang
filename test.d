extern(C++) interface ValueInterface
{
    int value();
}

extern(C++) class PrimaryBase
{
    void anchor()
    {
    }

    int unused;
}

extern(C++) class ValueObject : PrimaryBase, ValueInterface
{
    final int value()
    {
        return 35;
    }
}

extern(C) int callValueFromCpp(ValueInterface value);

void main()
{
    ValueInterface value = new ValueObject;
    assert(callValueFromCpp(value) == 42);
}
