# CMake 3.9 is required due to cpprestsdk-config.cmake using find_dependency with COMPONENTS
cmake_minimum_required(VERSION 3.9 FATAL_ERROR)

# project name
project(nmos-cpp)

# set BOOST_SYSTEM_USE_UTF8
if (DEFINED NMOS_CPP_BOOST_SYSTEM_USE_UTF8)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /DBOOST_SYSTEM_USE_UTF8")
endif()

# The nmos-cpp root directory
set(NMOS_CPP_DIR ${PROJECT_SOURCE_DIR}/Development)

# add the original CmakeLists.txt
add_subdirectory(Development)
