struct ValueInterface
{
    virtual int value() = 0;
};

int offset = 7;

extern "C" int callValueFromCpp(ValueInterface* value)
{
    return value->value() + offset;
}
