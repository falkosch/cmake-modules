if(RealGLEW_DIRECTORY)
    return()
endif()
set(RealGLEW_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

if(NOT TARGET RealGLEW::RealGLEW)
    add_library(RealGLEW::RealGLEW INTERFACE IMPORTED)
endif()

if(VCPKG_TOOLCHAIN)
    find_package(GLEW)
    target_link_libraries(RealGLEW::RealGLEW INTERFACE GLEW::GLEW)

else()
    find_package(glew)

    get_property(RealGLEW_LINK_LIBRARIES TARGET glew::glew PROPERTY INTERFACE_LINK_LIBRARIES)
    list(REMOVE_ITEM RealGLEW_LINK_LIBRARIES OpenGL32.lib)
    set_property(TARGET glew::glew PROPERTY INTERFACE_LINK_LIBRARIES ${RealGLEW_LINK_LIBRARIES})
    message(STATUS "Patched out OpenGL32.lib from glew::glew")

    target_link_libraries(RealGLEW::RealGLEW INTERFACE glew::glew)

endif()
