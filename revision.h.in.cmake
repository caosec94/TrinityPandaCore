#ifndef __REVISION_H__
#define __REVISION_H__

/*
 * TrinityPandaCore – Revision information
 * Adaptado al sistema moderno de TrinityCore
 * Compatible con CMake 3.24+, Git, OpenSSL 3, MySQL 8
 */

#define _HASH              "@rev_hash@"
#define _DATE              "@rev_date@"
#define _BRANCH            "@rev_branch@"
#define _YEAR              "@rev_year@"

#define _CMAKE_COMMAND     R"(@CMAKE_COMMAND@)"
#define _CMAKE_VERSION     R"(@CMAKE_VERSION@)"
#define _CMAKE_HOST_SYSTEM R"(@CMAKE_HOST_SYSTEM_NAME@ @CMAKE_HOST_SYSTEM_VERSION@)"

#define _SOURCE_DIRECTORY  R"(@CMAKE_SOURCE_DIR@)"
#define _BUILD_DIRECTORY   R"(@BUILDDIR@)"

#define _MYSQL_EXECUTABLE  R"(@MYSQL_EXECUTABLE@)"

/*
 * TrinityCore actual ya no “hardcodea” versiones de DB,
 * se recomienda manejar esto dinámicamente, pero si quieres
 * mantenerlo fijo puedes dejarlo así:
 */
#define _FULL_DATABASE     "DB_FULL_TRINITYCORE"

/*
 * Información de versión para Windows (propiedades del .exe)
 */
#define VER_COMPANYNAME_STR    "TrinityPandaCore"
#define VER_LEGALCOPYRIGHT_STR "(c) 2008-@rev_year@ TrinityPandaCore"

#define VER_FILEVERSION        0,0,0,0
#define VER_FILEVERSION_STR    "@rev_hash@ @rev_date@ (@rev_branch@)"

#define VER_PRODUCTVERSION     VER_FILEVERSION
#define VER_PRODUCTVERSION_STR VER_FILEVERSION_STR

/*
 * Información adicional usada por TrinityCore moderno
 */
#define VER_FILEDESCRIPTION_STR "TrinityPandaCore Server"
#define VER_INTERNALNAME_STR    "TrinityPandaCore"
#define VER_ORIGINALFILENAME_STR "TrinityPandaCore.exe"
#define VER_PRODUCTNAME_STR     "TrinityPandaCore"

#endif // __REVISION_H__