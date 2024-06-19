#ifndef __OPTIMISEDGPU2_HPP__
#define __OPTIMISEDGPU2_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include "utils/chronoGPU.hpp"
#include "constantMemory.hpp"

__global__ void kernelOptimised_viewtest2( const uint8_t *const dev_hmPtr, const uint8_t *const dev_resultatsGPUPtr);

float optimised_viewtestGPU2(los::Heightmap &hm, const Point &c, los::Heightmap &resultatsCPU);

#endif