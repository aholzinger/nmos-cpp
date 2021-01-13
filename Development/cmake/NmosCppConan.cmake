if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
    message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
    file(DOWNLOAD "https://github.com/conan-io/cmake-conan/raw/v0.15/conan.cmake"
                  "${CMAKE_BINARY_DIR}/conan.cmake")
    message(STATUS "Patching conan.cmake to support detecting correct runtime linkage")
    set(patch_file ${CMAKE_CURRENT_SOURCE_DIR}/../conan/conan.cmake.patch)
    execute_process(
      COMMAND patch -p1 --forward --ignore-whitespace
      WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
      INPUT_FILE "${patch_file}"
      OUTPUT_VARIABLE output
      RESULT_VARIABLE result)
    if (result EQUAL 0)
        message(STATUS "Patch applied: ${patch_file}")
    else()
        message(STATUS "Applying ${patch_file} failed with result \"${result}\"!")
    endif()
endif()

include(${CMAKE_BINARY_DIR}/conan.cmake)

set (NMOS_CPP_CONAN_BUILD_LIBS "missing" CACHE STRING "Semicolon separated list of libraries to build rather than download")

if(CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
    # e.g. Visual Studio
    conan_cmake_run(CONANFILE conanfile.txt
                    BASIC_SETUP
                    GENERATORS cmake_find_package_multi
                    KEEP_RPATHS
                    BUILD ${NMOS_CPP_CONAN_BUILD_LIBS})
else()
    conan_cmake_run(CONANFILE conanfile.txt
                    BASIC_SETUP
                    NO_OUTPUT_DIRS
                    GENERATORS cmake_find_package
                    KEEP_RPATHS
                    BUILD ${NMOS_CPP_CONAN_BUILD_LIBS})
endif()
