#include "CrashHandler.h"
#ifdef _WIN32
#include <dbghelp.h>
#include <fstream>
#include <ctime>
#include <sstream>
#include <direct.h>
#pragma comment(lib, "dbghelp.lib")

static std::string GetTimeStamp()
{
    time_t now = time(nullptr);
    tm t;
    localtime_s(&t, &now);

    char buf[64];
    strftime(buf, sizeof(buf), "%Y-%m-%d_%H-%M-%S", &t);
    return std::string(buf);
}

static void CreateCrashFolders()
{
    _mkdir("logs");
    _mkdir("logs\\crash");
}

LONG WINAPI CaosCrashHandler(EXCEPTION_POINTERS* ExceptionInfo)
{
    CreateCrashFolders();

    std::string filename = "logs\\crash\\crash_" + GetTimeStamp() + ".log";
    std::ofstream file(filename.c_str(), std::ios::out);

    file << "=============================================\n";
    file << "            CAOSCORE CRASH REPORT\n";
    file << "=============================================\n";
    file << "Timestamp: " << GetTimeStamp() << "\n\n";

    file << "Exception Code: 0x" 
         << std::hex << ExceptionInfo->ExceptionRecord->ExceptionCode << "\n";
    file << "Exception Address: 0x" 
         << std::hex << (DWORD64)ExceptionInfo->ExceptionRecord->ExceptionAddress << "\n\n";

    HANDLE process = GetCurrentProcess();
    SymInitialize(process, nullptr, TRUE);

    CONTEXT* ctx = ExceptionInfo->ContextRecord;
    STACKFRAME64 frame;
    memset(&frame, 0, sizeof(STACKFRAME64));

#ifdef _M_X64
    DWORD imageType = IMAGE_FILE_MACHINE_AMD64;
    frame.AddrPC.Offset = ctx->Rip;
    frame.AddrFrame.Offset = ctx->Rbp;
    frame.AddrStack.Offset = ctx->Rsp;
#else
    DWORD imageType = IMAGE_FILE_MACHINE_I386;
    frame.AddrPC.Offset = ctx->Eip;
    frame.AddrFrame.Offset = ctx->Ebp;
    frame.AddrStack.Offset = ctx->Esp;
#endif

    frame.AddrPC.Mode = AddrModeFlat;
    frame.AddrFrame.Mode = AddrModeFlat;
    frame.AddrStack.Mode = AddrModeFlat;

    file << "-------------- STACK TRACE ------------------\n";

    for (int i = 0; i < 40; ++i)
    {
        if (!StackWalk64(imageType, process, GetCurrentThread(),
            &frame, ctx, nullptr,
            SymFunctionTableAccess64, SymGetModuleBase64, nullptr))
            break;

        if (frame.AddrPC.Offset == 0)
            break;

        char buffer[sizeof(SYMBOL_INFO) + MAX_SYM_NAME];
        PSYMBOL_INFO symbol = (PSYMBOL_INFO)buffer;
        symbol->SizeOfStruct = sizeof(SYMBOL_INFO);
        symbol->MaxNameLen = MAX_SYM_NAME;

        DWORD64 displacement = 0;

        if (SymFromAddr(process, frame.AddrPC.Offset, &displacement, symbol))
        {
            file << i << ": " << symbol->Name 
                 << " + 0x" << std::hex << displacement << "\n";
        }
        else
        {
            file << i << ": 0x" << std::hex << frame.AddrPC.Offset << "\n";
        }
    }

    file << "---------------------------------------------\n";
    file << "Server stopped because of a critical error.\n";
    file << "=============================================\n";
    file.close();

    return EXCEPTION_EXECUTE_HANDLER;
}

void InitCrashHandler()
{
    SetUnhandledExceptionFilter(CaosCrashHandler);
}
#endif