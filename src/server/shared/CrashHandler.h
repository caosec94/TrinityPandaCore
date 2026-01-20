#ifndef CAOS_CRASH_HANDLER_H
#define CAOS_CRASH_HANDLER_H

#ifdef _WIN32
#include <windows.h>
LONG WINAPI CaosCrashHandler(EXCEPTION_POINTERS* ExceptionInfo);
void InitCrashHandler();
#endif

#endif