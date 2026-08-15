cmake_minimum_required(VERSION 3.17 FATAL_ERROR)

# project name
project(nmos-cpp)

# enable or disable the example applications
set(NMOS_CPP_BUILD_EXAMPLES ON CACHE BOOL "Build example applications")

# enable or disable the unit test suite
set(NMOS_CPP_BUILD_TESTS ON CACHE BOOL "Build test suite application")

# enable or disable the LLDP support library (lldp)
# and its additional dependencies
set(NMOS_CPP_BUILD_LLDP OFF CACHE BOOL "Build LLDP support library")
mark_as_advanced(FORCE NMOS_CPP_BUILD_LLDP)

# common config
include(cmake/NmosCppCommon.cmake)

# nmos-cpp dependencies
include(cmake/NmosCppDependencies.cmake)

# nmos-cpp libraries
include(cmake/NmosCppLibraries.cmake)

if(NMOS_CPP_BUILD_EXAMPLES)
    # nmos-cpp-node executable
    include(cmake/NmosCppNode.cmake)

    # nmos-cpp-registry executable
    include(cmake/NmosCppRegistry.cmake)
endif()

if(NMOS_CPP_BUILD_TESTS)
    # nmos-cpp-test executable
    include(cmake/NmosCppTest.cmake)
endif()

# export the config-file package
include(cmake/NmosCppExports.cmake)

function(get_openssl_lib_dirs_right)
  if(WIN32 AND NMOS_CPP_USE_WINDOWS_STATIC_RUNTIME)
    set(OpenSslLibs
        LIB_EAY_DEBUG
        LIB_EAY_RELEASE
        SSL_EAY_DEBUG
        SSL_EAY_RELEASE
    )
    foreach(OpenSslVar IN LISTS OpenSslLibs)
      # Read from cache explicitly
      if(DEFINED CACHE{${OpenSslVar}} AND NOT "$CACHE{${OpenSslVar}}" STREQUAL "")
        set(_oldVar "$CACHE{${OpenSslVar}}")
      else()
        set(_oldVar "${${OpenSslVar}}") # fallback, in case it's not in cache
      endif()
      if(NOT _oldVar STREQUAL "")
        string(REPLACE "/MD" "/MT" _newVar "${_oldVar}")
        if(NOT ${_newVar} STREQUAL ${_oldVar})
          # Force-update the cache entry (this is what CMake GUI displays)
          set(${OpenSslVar} "${_newVar}" CACHE FILEPATH "" FORCE)
          message(STATUS "setting variable ${OpenSslVar} to ${${OpenSslVar}} (old=${_oldVar})")
        endif()
      elseif()
        message(WARNING "${OpenSslVar} is empty!")
      endif()
    endforeach()
  endif()
endfunction(get_openssl_lib_dirs_right)

# This has to be done when everything else already did run just before generating
cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} CALL get_openssl_lib_dirs_right())
