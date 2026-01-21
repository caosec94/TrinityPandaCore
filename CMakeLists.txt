# Copyright (C) TrinityCore / SkyFire
# Modernized CMakeLists.txt for TrinityPandaCore
# Windows + Visual Studio 2022
# Boost 1.83 / OpenSSL 3 / MySQL 8
# CMake >= 3.24

cmake_minimum_required(VERSION 3.24)

# -------------------------------------------------
# Project
# -------------------------------------------------
project(TrinityPandaCore VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Prevent in-source builds
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

# Default build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()

# -------------------------------------------------
# CMake Policies
# -------------------------------------------------
if(POLICY CMP0144)
    cmake_policy(SET CMP0144 NEW) # find_package uses <PACKAGENAME>_ROOT
endif()

if(POLICY CMP0153)
    cmake_policy(SET CMP0153 NEW) # exec_program is deprecated
endif()

# -------------------------------------------------
# RPATH (mainly for Linux, harmless in Windows)
# -------------------------------------------------
set(CMAKE_SKIP_BUILD_RPATH 0)
set(CMAKE_BUILD_WITH_INSTALL_RPATH 0)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH 1)

# -------------------------------------------------
# CMake modules
# -------------------------------------------------
list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_SOURCE_DIR}/cmake"
    "${CMAKE_SOURCE_DIR}/cmake/macros"
)

# -------------------------------------------------
# TrinityCore base includes
# -------------------------------------------------
include(CheckCXXSourceRuns)
include(CheckIncludeFiles)

include(cmake/options.cmake)

# Disable PCH if requested
if(NOPCH)
    set(USE_COREPCH 0)
    set(USE_SCRIPTPCH 0)
endif()

include(ConfigureBaseTargets)
include(CheckPlatform)
include(GroupSources)
include(AutoCollect)
include(Macros)

find_package(PCHSupport)

# Git (optional)
if(NOT WITHOUT_GIT)
    find_package(Git 1.7)
endif()

# MySQL client binary (for genrev)
find_package(MySQL OPTIONAL_COMPONENTS binary)

# Revision info
include(cmake/genrev.cmake)

# Show selected options
include(cmake/showoptions.cmake)

# -------------------------------------------------
# Modern Dependencies
# -------------------------------------------------

# -------- Boost 1.83 --------
# Adjust this path to your Boost installation
set(BOOST_ROOT "C:/local/boost_1_83_0")
set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)

find_package(Boost 1.83 REQUIRED COMPONENTS
    system
    filesystem
    thread
    regex
    program_options
)

if(NOT Boost_FOUND)
    message(FATAL_ERROR "Boost not found. Check BOOST_ROOT.")
endif()

# -------- OpenSSL 3 --------
# Adjust to your OpenSSL 3 installation
set(OPENSSL_ROOT_DIR "C:/OpenSSL-Win64")

find_package(OpenSSL 3 REQUIRED)

if(NOT OpenSSL_FOUND)
    message(FATAL_ERROR "OpenSSL not found. Check OPENSSL_ROOT_DIR.")
endif()

# -------- MySQL 8 --------
# MySQL Connector/C or Connector/C++
set(MYSQL_ROOT_DIR "C:/Program Files/MySQL/MySQL Connector C++ 8.0")

find_package(MySQL REQUIRED COMPONENTS client)

if(NOT MySQL_FOUND)
    message(FATAL_ERROR "MySQL not found. Check MYSQL_ROOT_DIR.")
endif()

# -------------------------------------------------
# Global includes (legacy TrinityCore style)
# -------------------------------------------------
include_directories(
    ${Boost_INCLUDE_DIRS}
    ${OPENSSL_INCLUDE_DIR}
    ${MYSQL_INCLUDE_DIR}
)

# -------------------------------------------------
# Subdirectories
# -------------------------------------------------
# Internal dependencies
add_subdirectory(dep)

# Core sources
add_subdirectory(src)

# -------------------------------------------------
# Optional: Standalone build target (if src doesn't already create one)
# Only enable if your src/ does NOT already define the main executable
# -------------------------------------------------
option(BUILD_STANDALONE_CORE "Build standalone TrinityPandaCore executable" OFF)

if(BUILD_STANDALONE_CORE)
    file(GLOB_RECURSE CORE_SOURCES
        "src/*.cpp"
        "src/*.h"
    )

    add_executable(TrinityPandaCore ${CORE_SOURCES})

    target_include_directories(TrinityPandaCore PRIVATE
        ${Boost_INCLUDE_DIRS}
        ${OPENSSL_INCLUDE_DIR}
        ${MYSQL_INCLUDE_DIR}
    )

    target_link_libraries(TrinityPandaCore PRIVATE
        ${Boost_LIBRARIES}
        OpenSSL::SSL
        OpenSSL::Crypto
        ${MYSQL_LIBRARY}
    )

    set_target_properties(TrinityPandaCore PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    )
endif()

# -------------------------------------------------
# Status output
# -------------------------------------------------
message(STATUS "")
message(STATUS "========== TrinityPandaCore Configuration ==========")
message(STATUS "Build type:        ${CMAKE_BUILD_TYPE}")
message(STATUS "Compiler:          ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "Boost version:     ${Boost_VERSION}")
message(STATUS "Boost include:     ${Boost_INCLUDE_DIRS}")
message(STATUS "OpenSSL version:   ${OPENSSL_VERSION}")
message(STATUS "OpenSSL include:   ${OPENSSL_INCLUDE_DIR}")
message(STATUS "MySQL include:     ${MYSQL_INCLUDE_DIR}")
message(STATUS "===================================================")
message(STATUS "")