#ifndef __OPTIMIZED_TILEDGPU_HPP__
#define __OPTIMIZED_TILEDGPU_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include "constant_memory.hpp"
#include "utils/chronoGPU.hpp"
#include <iostream>
#include <vector>
#include <fstream> 

__global__ void kernelOptimized_tiledGPU(const uint8_t *dev_hmPtr, uint8_t *dev_resultPtr);

float optimized_tiledGPU(los::Heightmap &hm, los::Heightmap &result, const uint32_t tile_size, const uint32_t width, const uint32_t height, 
    const uint32_t tiled_width, const uint32_t tiled_height);

#endif
