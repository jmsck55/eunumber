// Copyright (c) 2016-2022 James Cook

// "Stub" test program.

#include <stdio.h>
#include <float.h>

#include "myeun.h"

int main()
{
    int mant = DBL_MANT_DIG;
#if __SIZEOF_POINTER__ == 8
    printf("Using GCC for 64-bit.\n");
#endif

    myeun_init_library();

    myeun_PrintVersion();

    // Add more code...
    printf("(Informational) Double's mant is: %i\n", mant);

    // Remember to free library before exitting.
    myeun_free_library();

    // At the end of a console program, prompt for user input:
    printf("Press Enter to exit.\n");
    getc(stdin);

    return 0;
}
