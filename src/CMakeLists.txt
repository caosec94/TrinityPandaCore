# =====================================================
# TrinityPandaCore - src/CMakeLists.txt (modernizado)
# Compatible con TrinityCore actual, CMake 3.24+, VS2022
# =====================================================

# Archivos específicos de Windows
if(WIN32)
  set(SOURCES_WINDOWS
    ${CMAKE_SOURCE_DIR}/src/common/Debugging/WheatyExceptionReport.cpp
    ${CMAKE_SOURCE_DIR}/src/common/Debugging/WheatyExceptionReport.h
  )
endif()

# Estos subdirectorios son parte estándar de TrinityCore moderno
# Se mantienen tal cual, solo limpiamos sintaxis vieja

# Generación de revisión (git hash, build info, etc.)
add_subdirectory(genrev)

# Código común del core
add_subdirectory(common)

# Servidores (worldserver, authserver, etc.)
if(SERVERS)
  add_subdirectory(server)
endif()

# Herramientas (mapextractor, vmap4assembler, etc.)
if(TOOLS)
  add_subdirectory(tools)
endif()

# Actualizador (si lo usas)
if(UPDATER)
  add_subdirectory(updater)
endif()

# -----------------------------------------------------
# Mensaje de estado
# -----------------------------------------------------
message(STATUS "")
message(STATUS "========== TrinityPandaCore src ==========")
message(STATUS "Windows sources enabled: ${WIN32}")
message(STATUS "SERVERS enabled:  ${SERVERS}")
message(STATUS "TOOLS enabled:    ${TOOLS}")
message(STATUS "UPDATER enabled:  ${UPDATER}")
message(STATUS "=========================================")
message(STATUS "")