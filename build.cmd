@echo off
setlocal
set CONFIG=Debug
if not "%1" == "" (
  set CONFIG=%1
)

if not exist build (
  md build
  cd build
  cmake ^
    -DBUILD_TESTING=1 ^
    -DCMAKE_VERBOSE_MAKEFILE=0 ^
    -DCMAKE_INSTALL_PREFIX=../install ^
    -Dgtest_force_shared_crt=ON ^
    -A x64 ^
    ..
  cd ..
)
cmake --build build --config %CONFIG% --target install
endlocal
