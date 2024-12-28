int main()
{
#if defined(OPTION_A) && defined(OPTION_C) && !defined(OPTION_B)
    return 0;
#else
    return 1;
#endif
};
