# CMake 3.9 is required due to cpprestsdk-config.cmake using find_dependency with COMPONENTS
cmake_minimum_required(VERSION 3.9 FATAL_ERROR)

# option for using conan as C/C++ library repo
option(USE_CONAN "Use Conan to acquire dependencies" OFF)

# option for using vcpkg as C/C++ library repo
option(USE_VCPKG "Use Vcpkg to acquire dependencies (will be switched off if USE_CONAN is switched on)" OFF)

if(USE_CONAN)
    if (USE_VCPKG)
        message(WARNING "Both USE_CONAN and USE_VCPKG set to ON. Setting USE_VCPKG to OFF!")
    endif()
    set(USE_VCPKG OFF)
    message(STATUS "Using Conan to acquire dependencies")
endif()

# option for Windows static runtime
option(USE_STATIC_RUNTIME "Link statically to C/C++ runtime (Windows only)" OFF)

if(USE_VCPKG)
    message(STATUS "Using Vcpkg to acquire dependencies")
    include (${CMAKE_CURRENT_SOURCE_DIR}/cmake/NmosCppVcpkg.cmake NO_POLICY_SCOPE)
endif()

# switch option CMP0091
if (${USE_STATIC_RUNTIME} AND DEFINED WIN32) # unfortunately CMAKE_SYSTEM_NAME is not yet set here
    if(POLICY CMP0091)
        cmake_policy(SET CMP0091 NEW)
    else()
        message(FATAL_ERROR "Policy CMP0091 not vailable. You need CMake 3.16 or newer to configure static runtime linkage on Windows!")
    endif()
endif()

# project name
project(nmos-cpp)

# The default nmos-cpp root directory
if (NOT DEFINED NMOS_CPP_DIR)
    set(NMOS_CPP_DIR ${PROJECT_SOURCE_DIR})
endif()

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    if (${USE_STATIC_RUNTIME})
        set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    endif()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /DBOOST_SYSTEM_USE_UTF8")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /DBOOST_SYSTEM_USE_UTF8")
endif()

if (${USE_CONAN})
    include (${NMOS_CPP_DIR}/cmake/NmosCppConan.cmake)
endif()

# Common setup and dependency checking
include (${NMOS_CPP_DIR}/cmake/NmosCppCommon.cmake)

# Setup for the libraries
include (${NMOS_CPP_DIR}/cmake/NmosCppLibraries.cmake)

# nmos-cpp-node executable

set(NMOS_CPP_NODE_SOURCES
    ${NMOS_CPP_DIR}/nmos-cpp-node/main.cpp
    ${NMOS_CPP_DIR}/nmos-cpp-node/node_implementation.cpp
    )
set(NMOS_CPP_NODE_HEADERS
    ${NMOS_CPP_DIR}/nmos-cpp-node/node_implementation.h
    )

add_executable(
    nmos-cpp-node
    ${NMOS_CPP_NODE_SOURCES}
    ${NMOS_CPP_NODE_HEADERS}
    ${NMOS_CPP_DIR}/nmos-cpp-node/config.json
    )

source_group("Source Files" FILES ${NMOS_CPP_NODE_SOURCES})
source_group("Header Files" FILES ${NMOS_CPP_NODE_HEADERS})

target_link_libraries(
    nmos-cpp-node
    nmos-cpp_static
    ${CPPRESTSDK_TARGET}
    ${PLATFORM_LIBS}
    ${Boost_LIBRARIES}
    )

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    # Conan packages usually don't include PDB files so suppress the resulting warning
    set_target_properties(
        nmos-cpp-node
        PROPERTIES
        LINK_FLAGS "/ignore:4099"
        )
endif()

# nmos-cpp-registry executable

set(NMOS_CPP_REGISTRY_SOURCES
    ${NMOS_CPP_DIR}/nmos-cpp-registry/main.cpp
    )
set(NMOS_CPP_REGISTRY_HEADERS
    )

add_executable(
    nmos-cpp-registry
    ${NMOS_CPP_REGISTRY_SOURCES}
    ${NMOS_CPP_REGISTRY_HEADERS}
    ${NMOS_CPP_DIR}/nmos-cpp-registry/config.json
    )

source_group("Source Files" FILES ${NMOS_CPP_REGISTRY_SOURCES})
source_group("Header Files" FILES ${NMOS_CPP_REGISTRY_HEADERS})

target_link_libraries(
    nmos-cpp-registry
    nmos-cpp_static
    ${CPPRESTSDK_TARGET}
    ${PLATFORM_LIBS}
    ${Boost_LIBRARIES}
    )

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    # Conan packages usually don't include PDB files so suppress the resulting warning
    set_target_properties(
        nmos-cpp-registry
        PROPERTIES
        LINK_FLAGS "/ignore:4099"
        )
endif()

# nmos-cpp-test executable
include (${NMOS_CPP_DIR}/cmake/NmosCppTest.cmake)
