cmake_minimum_required(VERSION 3.16)
project(MandelbrotRenderer)

# Force libraries binaries to be with executable
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

enable_language(CUDA)

add_subdirectory(extern)

if(CMAKE_COMPILER_IS_GNUCC)
	set(
		MDBR_COMPILATION_FLAGS
		-Wall
		-Wextra
	)
elseif(MSVC)
	set(MDBR_COMPILATION_FLAGS
		/permissive
		/fp:fast
	)

	SET(
		MDBR_COMPILATION_DEFINITION
		-D_CRT_SECURE_NO_WARNINGS
		-DNOMINMAX
	)
endif()


set(MDBR_HEADERS
    "include/mdbr/renderer.hpp"
    "include/mdbr/window.hpp"

    "include/mdbr/cuda/buffer.cuh"
    "include/mdbr/cuda/color.cuh"
    "include/mdbr/cuda/common.cuh"

    "include/mdbr/mandelbrot/reference.hpp"
    "include/mdbr/mandelbrot/student.hpp"
)

set(MDBR_SOURCES
    "src/renderer.cpp"
    "src/window.cpp"
    
    "src/cuda/buffer.cu"
    "src/cuda/common.cu"

    "src/mandelbrot/reference.cpp"
    "src/mandelbrot/student.cu"

    "src/main.cpp"
)

# Force every file to by compiled with nvcc
set_source_files_properties(${MDBR_SOURCES} PROPERTIES LANGUAGE CUDA)

add_executable(${PROJECT_NAME} ${MDBR_SOURCES} ${MDBR_HEADERS} ${MDBR_EXTERN_SOURCES})
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_11)
set_property(TARGET ${PROJECT_NAME} PROPERTY CUDA_STANDARD 11)
set_target_properties(${PROJECT_NAME} PROPERTIES CUDA_ARCHITECTURES "70")
set_target_properties(${PROJECT_NAME} PROPERTIES
       CUDA_SEPARABLE_COMPILATION ON
       CUDA_RESOLVE_DEVICE_SYMBOLS ON
)
target_compile_options(${PROJECT_NAME} PRIVATE ${BCS_COMPILATION_FLAGS})
target_compile_definitions(${PROJECT_NAME} PRIVATE ${BCS_COMPILATION_DEFINITION})

target_link_libraries(${PROJECT_NAME} PRIVATE ${MDBR_EXTERN_LIBRARIES})
target_include_directories(${PROJECT_NAME} PRIVATE SYSTEM "include/" ${MDBR_EXTERN_INCLUDES})
