#ifndef __NAIVE_TILEDCPU_HPP__
#define __NAIVE_TILEDCPU_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"

void naive_tiledCPU(const los::Heightmap &hm, los::Heightmap &result);
void save_ppm_image(const los::Heightmap &result, const std::string &filename);

#endif
