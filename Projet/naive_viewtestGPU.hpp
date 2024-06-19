#ifndef __NAIVE_VIEWTESTGPU_HPP__
#define __NAIVE_VIEWTESTGPU_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include "utils/chronoGPU.hpp"

__global__ void kernelNaive_viewtest(const uint8_t *const dev_hmPtr, const uint8_t *const dev_resultatsGPUPtr, const int size, const int width, const int height,
	 int cx,  int cy);

float naive_viewtestGPU(los::Heightmap &hm, const Point &c, los::Heightmap &resultatsCPU);

#endif