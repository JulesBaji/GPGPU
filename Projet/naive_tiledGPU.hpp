#ifndef __NAIVE_TILEDGPU_HPP__
#define __NAIVE_TILEDGPU_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include "save_ppm_image.hpp"
#include "constant_memory.hpp"
#include "utils/chronoGPU.hpp"
#include <iostream>
#include <vector>
#include <fstream> 

__global__ void kernelNaive_tiledGPU(const uint8_t *dev_hmPtr, uint8_t *dev_resultPtr, const uint32_t ppm_tiled_size, const uint32_t width, const uint32_t tile_size_width, const uint32_t tile_size_height);

float naive_tiledGPU(los::Heightmap &hm, los::Heightmap &result, const uint32_t tile_size, const uint32_t width, const uint32_t height, 
    const uint32_t tiled_width, const uint32_t tiled_height);

#endif
