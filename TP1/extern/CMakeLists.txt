# Load SDL2
add_subdirectory(SDL2)

# Load ImGUI
set(IMGUI_PATH "${CMAKE_CURRENT_SOURCE_DIR}/imgui")
set(IMGUI_SOURCES 
    "${IMGUI_PATH}/imconfig.h"
    "${IMGUI_PATH}/imgui.cpp"
    "${IMGUI_PATH}/imgui.h"
    "${IMGUI_PATH}/imgui_demo.cpp"
    "${IMGUI_PATH}/imgui_draw.cpp"
    "${IMGUI_PATH}/imgui_internal.h"
    "${IMGUI_PATH}/imgui_tables.cpp"
    "${IMGUI_PATH}/imgui_widgets.cpp"
    "${IMGUI_PATH}/backends/imgui_impl_sdl.cpp"
    "${IMGUI_PATH}/backends/imgui_impl_sdl.h"
    "${IMGUI_PATH}/backends/imgui_impl_opengl3.cpp"
    "${IMGUI_PATH}/backends/imgui_impl_opengl3.h"
)

# Load GL3W
set(GL3W_PATH "${CMAKE_CURRENT_SOURCE_DIR}/gl3w")
file(GLOB_RECURSE GL3W_SOURCES ${GL3W_PATH}/*.hpp ${GL3W_PATH}/*.h ${GL3W_PATH}/*.inl ${GL3W_PATH}/*.c ${GL3W_PATH}/*.cpp)

# Forward dependencies according to their configuration
set(MDBR_EXTERN_SOURCES  ${MDBR_EXTERN_SOURCES}  ${GL3W_SOURCES} ${IMGUI_SOURCES})
set(MDBR_EXTERN_INCLUDES ${MDBR_EXTERN_INCLUDES} ${GL3W_PATH} ${IMGUI_PATH})
set(MDBR_EXTERN_LIBRARIES SDL2::SDL2 SDL2::SDL2main)

# Let upper CMake level knows about these variables
set(MDBR_EXTERN_INCLUDES  ${MDBR_EXTERN_INCLUDES}  PARENT_SCOPE)
set(MDBR_EXTERN_SOURCES   ${MDBR_EXTERN_SOURCES}   PARENT_SCOPE)
set(MDBR_EXTERN_LIBRARIES ${MDBR_EXTERN_LIBRARIES} PARENT_SCOPE)

