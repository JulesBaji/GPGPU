#include "mdbr/cuda/common.cuh"
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <iostream>

namespace mdbr
{
    void checkCudaErrors(cudaError_t err)
    {
        if (err != cudaSuccess)                                        
            throw std::runtime_error(cudaGetErrorString(err));         
    }
}