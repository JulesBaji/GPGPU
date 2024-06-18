#ifndef __OPTIMISEDGPU_HPP__
#define __OPTIMISEDGPU_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include "utils/chronoGPU.hpp"
#include "math.h"
#include <vector>

__global__ void kernelOptimised_viewtest( const uint8_t *const dev_hmPtr, const uint8_t *const dev_resultatsGPUPtr, const int size, const int width, const int height,
	 int cx,  int cy);

float optimised_viewtestGPU(los::Heightmap &hm, const Point &c, los::Heightmap &resultatsCPU);

#endif