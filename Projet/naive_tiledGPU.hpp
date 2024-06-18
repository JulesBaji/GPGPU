#ifndef __NAIVE_TILEDGPU_HPP__
#define __NAIVE_TILEDGPU_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include <iostream>
#include <vector>

__global__ void kernelNaive_tiled(const uint8_t *const dev_hmPtr, uint8_t *const dev_resultPtr, const int width,
const int height, const int tile_size);

float naive_tiledGPU(los::Heightmap &hm, los::Heightmap &result);

void save_ppm_image_GPU( los::Heightmap &result, const std::string &filename);

#endif
