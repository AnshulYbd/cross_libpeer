project(sample)

file(GLOB SRCS "*.c")

include_directories(${CMAKE_SOURCE_DIR}/src)

add_executable(sample ${SRCS})

target_link_libraries(sample peer pthread)

install(TARGETS sample
  LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_PREFIX}/include/
)