// Copyright (c) 2016-2022 James Cook

// C header file

#pragma once

#ifndef myeun_h__
#define myeun_h__

#include <stdio.h>
#include <windows.h>

#define MAKE_OBJ(x) (((unsigned)(x)) >> 2))
#define OBJ_PTR(x) ((void*)(((unsigned)(x)) << 2))

#define HIGHWORD(T) ((T) >> 16)
#define LOWWORD(T) ((T) & 0xFFFF)

HMODULE libmyeun = 0;

typedef __declspec(dllimport) int __stdcall (*VersionFunc)(void);
VersionFunc EunVersion;

void myeun_init_library()
{
    libmyeun = LoadLibraryA("libmyeun.dll");
    if (libmyeun == NULL)
    {
        // an error occurred.
        return;
    }

    EunVersion = (VersionFunc)GetProcAddress(libmyeun, "GetVersion");
}

void myeun_free_library()
{
    if (!FreeLibrary(libmyeun))
    {
        // an error occurred.

    }
}
// Remember to use "FreeLibrary()" when exitting application.

void myeun_PrintVersion()
{
    printf("[libmyeun.dll] EunVersion is: %d\n", EunVersion());
}

#endif // myeun_h__
