# =====================================================
# TrinityPandaCore – genrev.cmake (modernizado 2026)
# Compatible con TrinityCore actual, CMake 3.24+, Git
# =====================================================

# Este bloque solo se ejecuta una vez durante la configuración
if(NOT BUILDDIR)
  # Workaround para MSVC (como en TrinityCore actual)
  set(NO_GIT ${WITHOUT_GIT})
  set(GIT_EXEC ${GIT_EXECUTABLE})
  set(BUILDDIR ${CMAKE_BINARY_DIR})
endif()

# -----------------------------------------------------
# Valores por defecto si NO hay Git
# -----------------------------------------------------
if(NO_GIT)
  set(rev_date   "1970-01-01 00:00:00 +0000")
  set(rev_hash   "Archived")
  set(rev_branch "Archived")
  string(TIMESTAMP rev_year "%Y" UTC)
else()
  if(GIT_EXEC)
    # Hash + tag + dirty (como TrinityCore master)
    execute_process(
      COMMAND "${GIT_EXEC}" describe --tags --dirty --long --abbrev=12
      WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
      OUTPUT_VARIABLE rev_info
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    # Fecha del commit
    execute_process(
      COMMAND "${GIT_EXEC}" show -s --format=%ci
      WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
      OUTPUT_VARIABLE rev_date
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    # Rama actual
    execute_process(
      COMMAND "${GIT_EXEC}" rev-parse --abbrev-ref HEAD
      WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
      OUTPUT_VARIABLE rev_branch
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    # Año actual (para copyright)
    string(TIMESTAMP rev_year "%Y" UTC)
  endif()

  # Si no se pudo obtener información de Git
  if(NOT rev_info)
    message(STATUS
      "Could not find a proper repository signature (hash).\n"
      "You may need to run: git fetch --tags\n"
      "Falling back to archived mode."
    )
    set(rev_date   "1970-01-01 00:00:00 +0000")
    set(rev_hash   "Archived")
    set(rev_branch "Archived")
    string(TIMESTAMP rev_year "%Y" UTC)
  else()
    # Extraer el hash limpio del describe
    # Ejemplo: v3.3.5a-123-gabcdef123456
    # Resultado: abcdef123456
    string(REGEX REPLACE "^.*-g" "" rev_hash "${rev_info}")
  endif()
endif()

# -----------------------------------------------------
# Información adicional usada por revision.h
# -----------------------------------------------------
set(CMAKE_COMMAND     "${CMAKE_COMMAND}")
set(CMAKE_VERSION     "${CMAKE_VERSION}")
set(CMAKE_HOST_SYSTEM "${CMAKE_HOST_SYSTEM_NAME} ${CMAKE_HOST_SYSTEM_VERSION}")
set(BUILDDIR          "${BUILDDIR}")

# -----------------------------------------------------
# Generación del archivo revision.h
# Solo se regenera si cambia el hash
# -----------------------------------------------------
if(NOT "${rev_hash_cached}" STREQUAL "${rev_hash}")
  configure_file(
    "${CMAKE_SOURCE_DIR}/revision.h.in.cmake"
    "${BUILDDIR}/revision.h"
    @ONLY
  )
  set(rev_hash_cached "${rev_hash}" CACHE INTERNAL "Cached commit-hash")
endif()

# -----------------------------------------------------
# Mensaje informativo (como TrinityCore moderno)
# -----------------------------------------------------
message(STATUS "")
message(STATUS "========== TrinityPandaCore Revision ==========")
message(STATUS "Hash:     ${rev_hash}")
message(STATUS "Date:     ${rev_date}")
message(STATUS "Branch:   ${rev_branch}")
message(STATUS "Year:     ${rev_year}")
message(STATUS "BuildDir: ${BUILDDIR}")
message(STATUS "==============================================")
message(STATUS "")