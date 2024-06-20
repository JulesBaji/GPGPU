#include "optimized_tiledGPU.hpp"

#define BLOCK_SIZE 16

__device__ void atomicMaxUint8_optimizedGPU(uint8_t* address, uint8_t val)
{
    unsigned int* base_address = (unsigned int*)((size_t)address & ~3);

    unsigned int mask = 0xFF << (((size_t)address & 3) * 8);
    unsigned int shift = ((size_t)address & 3) * 8;

    unsigned int old, assumed, new_;

    old = *base_address;

    do {
        assumed = old;
        uint8_t current_val = (old & mask) >> shift;
        uint8_t new_val = max(current_val, val);
        new_ = (old & ~mask) | (new_val << shift);
        old = atomicCAS(base_address, assumed, new_);

    } while (assumed != old);
}

__global__ void kernelOptimized_tiledGPU(const uint8_t *dev_hmPtr, uint8_t *dev_resultPtr)
{
    extern __shared__ uint8_t shared_mem[];

    int tid_x = threadIdx.x + blockIdx.x * blockDim.x;
    int tid_y = threadIdx.y + blockIdx.y * blockDim.y;

    int tiled_tid_x = tid_x / dev_tile_size_width;
    int tiled_tid_y = tid_y / dev_tile_size_height;

    int tid_tiled = tiled_tid_x + tiled_tid_y * dev_ppm_tiled_size;

    shared_mem[tid_tiled] = 0u;
    __syncthreads();

    uint8_t height_value = dev_hmPtr[tid_x + tid_y * dev_width];

    shared_mem[tid_tiled] = max(shared_mem[tid_tiled], height_value);
    __syncthreads();

    if(threadIdx.x == 0 && threadIdx.y == 0)
        atomicMaxUint8_optimizedGPU(&dev_resultPtr[tid_tiled], shared_mem[tid_tiled]);
}

float optimized_tiledGPU(los::Heightmap &hm, los::Heightmap &result, const uint32_t ppm_tiled_size, const uint32_t width, const uint32_t height, 
    const uint32_t tile_size_width, const uint32_t tile_size_height)
{
	uint8_t *hmPtr = hm.getPtr();
	uint8_t *resultatsGPUPtr = result.getPtr();

	uint8_t *dev_hmPtr;
	uint8_t *dev_resultatsGPUPtr;

	HANDLE_ERROR(cudaMalloc(&dev_hmPtr, hm.getSize() * sizeof(uint8_t)));
	HANDLE_ERROR(cudaMalloc(&dev_resultatsGPUPtr, result.getSize() * sizeof(uint8_t)));

	HANDLE_ERROR (cudaMemcpy( dev_hmPtr, hmPtr, hm.getSize() * sizeof(uint8_t), cudaMemcpyHostToDevice ));
	HANDLE_ERROR (cudaMemcpy( dev_resultatsGPUPtr, resultatsGPUPtr, result.getSize() * sizeof(uint8_t), cudaMemcpyHostToDevice ));

	HANDLE_ERROR(cudaMemcpyToSymbol(dev_ppm_tiled_size, &ppm_tiled_size, sizeof(int)));
	HANDLE_ERROR(cudaMemcpyToSymbol(dev_width, &width, sizeof(int)));
    HANDLE_ERROR(cudaMemcpyToSymbol(dev_tile_size_width, &tile_size_width, sizeof(int)));
    HANDLE_ERROR(cudaMemcpyToSymbol(dev_tile_size_height, &tile_size_height, sizeof(int)));

	dim3 blockSize(BLOCK_SIZE, BLOCK_SIZE); 
    dim3 gridSize((width + blockSize.x - 1) / blockSize.x, (height + blockSize.y - 1) / blockSize.y);

    const int shared_mem_size = ppm_tiled_size * ppm_tiled_size * sizeof(uint8_t);

	ChronoGPU chr;
	chr.start();

	kernelOptimized_tiledGPU<<<gridSize, blockSize, shared_mem_size>>>(dev_hmPtr, dev_resultatsGPUPtr);

	HANDLE_ERROR (cudaMemcpy( resultatsGPUPtr, dev_resultatsGPUPtr, result.getSize() * sizeof(uint8_t), cudaMemcpyDeviceToHost ));

	chr.stop();

	HANDLE_ERROR (cudaFree( dev_hmPtr ));
	HANDLE_ERROR (cudaFree( dev_resultatsGPUPtr ));

	return chr.elapsedTime();
}