int main()
{
#ifdef OPTION_A && OPTION_C && !OPTION_B
    return 0;
#else
    return 1;
#endif
};
