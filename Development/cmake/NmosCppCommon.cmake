# otherwise boost will be found in the local file system instead of conan or vcpkg
set(ENV{BOOST_ROOT})

set(NMOS_CPP_USE_WINDOWS_STATIC_RUNTIME OFF CACHE BOOL "Link statically to C/C++ runtime on Windows")
mark_as_advanced(FORCE NMOS_CPP_USE_WINDOWS_STATIC_RUNTIME)

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    if(NMOS_CPP_USE_WINDOWS_STATIC_RUNTIME AND DEFINED VCPKG_TARGET_TRIPLET)
        message(FATAL_ERROR "NMOS_CPP_USE_WINDOWS_STATIC_RUNTIME and VCPKG_TARGET_TRIPLET both set! Either use Conan with NMOS_CPP_USE_WINDOWS_STATIC_RUNTIME or use Vcpkg without NMOS_CPP_USE_WINDOWS_STATIC_RUNTIME.")
    endif()
    if(NMOS_CPP_USE_WINDOWS_STATIC_RUNTIME)
        message(STATUS "Linking statically to C/C++ runtime on Windows")
        # switch option CMP0091
        # if (DEFINED WIN32) # unfortunately CMAKE_SYSTEM_NAME is not yet set here
            if(POLICY CMP0091)
                cmake_policy(SET CMP0091 NEW)
                set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
            else()
                message(FATAL_ERROR "Policy CMP0091 not vailable. You need CMake 3.16 or newer to configure static runtime linkage on Windows!")
            endif()
        # endif()
    endif()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /DBOOST_SYSTEM_USE_UTF8")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /DBOOST_SYSTEM_USE_UTF8")
endif()

set(NMOS_CPP_USE_CONAN ON CACHE BOOL "Use Conan to acquire dependencies")
mark_as_advanced(FORCE NMOS_CPP_USE_CONAN)

set(NMOS_CPP_USE_VCPKG OFF CACHE BOOL "Use Vcpkg to acquire dependencies")
mark_as_advanced(FORCE NMOS_CPP_USE_VCPKG)

if(NMOS_CPP_USE_CONAN AND NMOS_CPP_USE_VCPKG)
    message(FATAL_ERROR "Either choose NMOS_CPP_USE_CONAN for Conan or NMOS_CPP_USE_VCPKG for Vcpkg to acquire libraries")
endif()

if(NMOS_CPP_USE_CONAN)
    message(STATUS "Using Conan to acquire dependencies")
    include(cmake/NmosCppConan.cmake)
endif()

if(NMOS_CPP_USE_VCPKG)
    message(STATUS "Using Vcpkg to acquire dependencies")
    include(cmake/NmosCppVcpkg.cmake)
endif()

set(NMOS_CPP_USE_LIBDIR_SUFFIX ON CACHE BOOL "Use a suffix (Debug or Release) for the library directory")
mark_as_advanced(FORCE NMOS_CPP_USE_LIBDIR_SUFFIX)

set(NMOS_CPP_USE_BINDIR_SUFFIX ON CACHE BOOL "Use a suffix (Debug or Release) for the binary directory")
mark_as_advanced(FORCE NMOS_CPP_USE_BINDIR_SUFFIX)

include(GNUInstallDirs)

# if both variables aren't empty strings, join them
string(JOIN "/" NMOS_CPP_INSTALL_INCLUDEDIR ${CMAKE_INSTALL_INCLUDEDIR} ${NMOS_CPP_INCLUDE_PREFIX})

set(NMOS_CPP_INSTALL_LIBDIR "${CMAKE_INSTALL_LIBDIR}")
set(NMOS_CPP_INSTALL_BINDIR "${CMAKE_INSTALL_BINDIR}")
if(WIN32)
    if(NMOS_CPP_USE_LIBDIR_SUFFIX)
        string(APPEND NMOS_CPP_INSTALL_LIBDIR "/$<IF:$<CONFIG:Debug>,Debug,Release>")
    endif()
    if(NMOS_CPP_USE_BINDIR_SUFFIX)
        string(APPEND NMOS_CPP_INSTALL_BINDIR "/$<IF:$<CONFIG:Debug>,Debug,Release>")
    endif()
endif()

# enable C++14
enable_language(CXX)
set(CMAKE_CXX_STANDARD 14 CACHE STRING "Default value for CXX_STANDARD property of targets")
if(CMAKE_CXX_STANDARD STREQUAL "98" OR CMAKE_CXX_STANDARD STREQUAL "11")
    message(FATAL_ERROR "CMAKE_CXX_STANDARD must be 14 or higher; C++98 is not supported")
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NMOS_CPP_BUILD_TESTS AND CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    # note: to see the output of any failed tests, set CTEST_OUTPUT_ON_FAILURE=1 in the environment
    # and also remember that CMake doesn't add dependencies to the "test" (or "RUN_TESTS") target
    # so after changing code under test, it is important to "make all" (or build "ALL_BUILD")
    enable_testing()
endif()

# location of additional CMake modules
list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake
    )

# guard against in-source builds and bad build-type strings
include(safeguards)

# common compiler flags and warnings
include(cmake/NmosCppCompileSettings.cmake)
