cmake_minimum_required(VERSION 2.8)

# Local CMake modules
set(CMAKE_MODULE_PATH
  "${CMAKE_MODULE_PATH}"
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules"
  )

### External projects are here
add_subdirectory(lib/)

### C++ Version
set(CMAKE_CXX_STANDARD 14)

# Build
include_directories(lib/jdksmidi/include/)
add_subdirectory(src/)
