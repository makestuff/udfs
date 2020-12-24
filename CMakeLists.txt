cmake_minimum_required(VERSION 3.10)
project(udfs)

# Use a single output directory for everything
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Turn warning level up, use C++17 and C99
if(MSVC)
  add_compile_options(/W4 /WX /DBYTE_ORDER=1234 /D_CRT_SECURE_NO_WARNINGS)
else()
  add_compile_options(-Wall -Wextra -pedantic -Werror -DBYTE_ORDER=1234)
endif()
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS 0)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_EXTENSIONS 0)

# Maybe build GoogleTest
if(BUILD_TESTING)
  include(CTest)
  set(GOOGLETEST_VERSION 1.10.0)
  add_subdirectory("googletest/googlemock")
endif()

# Build components
add_subdirectory("common")
add_subdirectory("libargtable2")
add_subdirectory("liberror")
add_subdirectory("libbuffer")
add_subdirectory("libusbwrap")
add_subdirectory("server")
add_subdirectory("xbm2bbc")
add_subdirectory("d6502")
