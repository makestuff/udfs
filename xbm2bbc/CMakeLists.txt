project(xbm2bbc)

# Create an executable
file(GLOB SOURCES *.cpp *.c)
add_executable(${PROJECT_NAME} ${SOURCES})
