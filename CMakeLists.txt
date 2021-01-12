# CMake 3.9 is required due to cpprestsdk-config.cmake using find_dependency with COMPONENTS
cmake_minimum_required(VERSION 3.9 FATAL_ERROR)

# option for using conan as C/C++ library repo
option(USE_CONAN "Use Conan to acquire dependencies" ON)

# option for using vcpkg as C/C++ library repo
option(USE_VCPKG "Use Vcpkg to acquire dependencies (will be switched off if USE_CONAN is switched on)" OFF)

if(USE_CONAN)
    set(USE_VCPKG OFF)
    message(STATUS "Using Conan to acquire dependencies")
endif()

# option for Windows static runtime
option(USE_STATIC_RUNTIME "Link statically to C/C++ runtime (Windows only)" OFF)

if(USE_VCPKG)
    message(STATUS "Using Vcpkg to acquire dependencies")
    if(POLICY CMP0074)
        cmake_policy(SET CMP0074 NEW)
    else()
        message(FATAL_ERROR "Policy CMP0074 not vailable. You need CMake 3.12 or newer to use Vcpkg to acquire dependencies!")
    endif()
    if(DEFINED WIN32) # unfortunately CMAKE_SYSTEM_NAME is not yet set here
        if (NOT DEFINED VCPKG_TARGET_TRIPLET)
            if (${CMAKE_GENERATOR_PLATFORM} STREQUAL "x64")
                if (${USE_STATIC_RUNTIME})
                    set(VCPKG_TARGET_TRIPLET "x64-windows-static")
                else()
                    set(VCPKG_TARGET_TRIPLET "x64-windows")
                endif()
            else()
                if (${USE_STATIC_RUNTIME})
                    set(VCPKG_TARGET_TRIPLET "x86-windows-static")
                else()
                    set(VCPKG_TARGET_TRIPLET "x86-windows")
                endif()
            endif()
        endif()
        message(STATUS "Using Vcpkg triplet ${VCPKG_TARGET_TRIPLET}")
    endif()
    if(DEFINED CMAKE_TOOLCHAIN_FILE)
        if(NOT ${CMAKE_TOOLCHAIN_FILE} STREQUAL "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
            message(FATAL_ERROR "USE_VCPKG switched on but also CMAKE_TOOLCHAIN_FILE set (CMAKE_TOOLCHAIN_FILE = ${CMAKE_TOOLCHAIN_FILE})")
        endif()
    endif()
    if(DEFINED ENV{VCPKG_ROOT})
        set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "")
        message(STATUS "Using CMAKE_TOOLCHAIN_FILE = ${CMAKE_TOOLCHAIN_FILE}")
    else()
        message(FATAL_ERROR "USE_VCPKG switched on but no VCPKG_ROOT environment variable available")
    endif()
endif()

# switch option CMP0091
if (${USE_STATIC_RUNTIME})
    if(POLICY CMP0091)
        cmake_policy(SET CMP0091 NEW)
    else()
        message(FATAL_ERROR "Policy CMP0091 not vailable. You need CMake 3.16 or newer to configure static runtime linkage on Windows!")
    endif()
endif()

# project name
project(nmos-cpp)

# The nmos-cpp include directory
set(NMOS_CPP_INCLUDE_PREFIX "/nmos-cpp")

# add the original CmakeLists.txt
add_subdirectory(Development)
