project(d6502)

# Create an executable
file(GLOB SOURCES *.cpp *.c)
add_executable(${PROJECT_NAME} ${SOURCES})

# Dependencies
set(APP_DEPENDS common buffer)
target_link_libraries(${PROJECT_NAME} PRIVATE ${APP_DEPENDS})

# What to install
install(TARGETS ${PROJECT_NAME} DESTINATION bin)
