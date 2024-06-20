#ifndef __OPTIMISED_VIEWTEST_GPU_HPP__
#define __OPTIMISED_VIEWTEST_GPU_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include "utils/chronoGPU.hpp"
#include "constant_memory.hpp"

__global__ void kernelOptimised_viewtest(const uint8_t *const dev_hmPtr, const uint8_t *const dev_resultatsGPUPtr);

float optimised_viewtestGPU(los::Heightmap &hm, const Point &c, los::Heightmap &resultatsCPU);

#endif // __OPTIMISED_VIEWTEST_GPU_HPP__