#ifndef __NAIVE_VIEWTESTGPU_HPP__
#define __NAIVE_VIEWTESTGPU_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include "utils/chronoGPU.hpp"
#include "constant_memory.hpp"

__global__ void kernelNaive_viewtest(const uint8_t *const dev_hmPtr, const uint8_t *const dev_resultatsGPUPtr);

float naive_viewtestGPU(los::Heightmap &hm, const Point &c, los::Heightmap &resultatsCPU);

#endif