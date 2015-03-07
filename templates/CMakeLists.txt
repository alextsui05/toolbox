cmake_minimum_required( VERSION 2.8 )

project( ProjectName )

# Project-specific settings
set( CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}" )
include_directories( ${CMAKE_CURRENT_BINARY_DIR} )
#add_definitions( -DBUILD_TESTS )
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")

# (UNIX only) Configure build targets to look for libraries relative to their
# install path.
if ( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" ) # This is how to check for Linux
    set( CMAKE_SKIP_BUILD_RPATH FALSE )
    set( CMAKE_BUILD_WITH_INSTALL_RPATH FALSE )
    set( CMAKE_INSTALL_RPATH "\$ORIGIN/../lib" )
    set( CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE )
endif ( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )

# Let the user set some options
option( BUILD_TESTS "Build unit tests" OFF )
option( BUILD_EXAMPLES "Build examples" OFF )
if ( APPLE )
    option( BUILD_OSX_BUNDLE "Build OSX bundle" OFF )
endif( )

# Define necessary packages
#find_package( Qt4 REQUIRED )
#include( ${QT_USE_FILE} )

#find_package( CGAL REQUIRED )
#include( ${CGAL_USE_FILE} )

# define build targets

#add_library( Foo SHARED Foo.cpp )
#add_library( FooStatic STATIC Foo.cpp )
#if (UNIX)
#    set_target_properties( FooStatic PROPERTIES OUTPUT_NAME Foo )
#endif(UNIX)

#qt4_wrap_ui(test_UI MyWindow.ui)
#qt4_wrap_cpp(test_MOC MyWindow.h)

if ( APPLE AND BUILD_OSX_BUNDLE )
    add_executable( test MACOSX_BUNDLE
        test.cpp
#        ${test_UI}
#        ${test_MOC}
    )
else( )
    add_executable( test
        test.cpp 
#        ${test_UI}
#        ${test_MOC}
)
endif( )
#target_link_libraries( test
#   ${QT_LIBRARIES}
#   Foo
#)

install( TARGETS test
    RUNTIME DESTINATION bin 
    LIBRARY DESTINATION lib
)
file( WRITE .includes_list "" )
get_directory_property( includelist DIRECTORY ${PROJECT_SOURCE_DIR} INCLUDE_DIRECTORIES )
foreach(inc ${includelist})
	file( APPEND .includes_list "${inc}\n" )
endforeach()
#set( CMAKE_EXPORT_COMPILE_COMMANDS 1 )
