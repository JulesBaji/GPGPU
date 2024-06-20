#ifndef __NAIVE_TILEDCPU_HPP__
#define __NAIVE_TILEDCPU_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include "save_ppm_image.hpp"
#include "utils/chronoGPU.hpp"
#include <iostream>
#include <vector>
#include <fstream> 

void naive_tiledCPU(const los::Heightmap &hm, los::Heightmap &result, const uint32_t ppm_tiled_size, const uint32_t width, const uint32_t height, 
    const uint32_t tile_size_width, const uint32_t tile_size_height);

#endif
