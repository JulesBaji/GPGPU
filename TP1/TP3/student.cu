#include "student.hpp"
#include "math.h"
#include <vector>
#define BLOCK_SIZE 256
#define N 1024

__global__ void kernelComputeConv( const int *const dev_Data, int *const dev_Histogramme, const int size, 
	const int distributionSize ) 
{		
	for(int x = threadIdx.x + blockDim.x * blockIdx.x; x < size/N + 1; x+= (blockDim.x * gridDim.x)) {
		for(int i = x * N;i < x * N + N;i++){
			if( i < size )
				atomicAdd(&dev_Histogramme[dev_Data[i]],1);
		}		
	}
}

__global__ void kernelComputeConvSharedMemory(const int *const dev_Data, int *const dev_Histogramme, const int size, const int distributionSize) 
{
	// Comment on mets distributionSize a la place de 129
	__shared__ int localHistogramme[129];
    // Initialiser l'histogramme local à zéro
    for (int i = threadIdx.x; i < distributionSize; i += blockDim.x) {
        localHistogramme[i] = 0;
    }
    __syncthreads();  // Synchronisation pour s'assurer que l'initialisation est terminée 

    int startIdx = blockIdx.x * N;
    int endIdx = min((blockIdx.x + 1) * N, size);
    for (int x = startIdx + threadIdx.x; x < endIdx; x += blockDim.x) {
        atomicAdd(&localHistogramme[dev_Data[x]], 1);
    }
    __syncthreads();  // Synchronisation pour s'assurer que toutes les threads ont fini d'incrémenter localHistogramme

    // Report des résultats dans l'histogramme global avec synchronisation atomique
    for (int i = threadIdx.x; i < distributionSize; i += blockDim.x) {
        atomicAdd(&dev_Histogramme[i], localHistogramme[i]);
    }
}

float calcHistogrammeGPU( const int *data, int *histogramme, const int size, const int distributionSize) 
{
	int *dev_Data, *dev_Histogramme;

    HANDLE_ERROR(cudaMalloc(&dev_Data, size * sizeof(int)));
	HANDLE_ERROR(cudaMalloc(&dev_Histogramme, distributionSize * sizeof(int)));

	/// TODO - Copy from Host to Device
	HANDLE_ERROR (cudaMemcpy( dev_Data, data, size * sizeof(int), cudaMemcpyHostToDevice ));

	/// TODO - Configure kernel
	// POURQUOI 256 ????????????????????????
	dim3 blockSize(BLOCK_SIZE); 
    dim3 gridSize((size + blockSize.x - 1) / blockSize.x);

	ChronoGPU chr;
	chr.start();

	/// TODO - Launch kernel
	kernelComputeConvSharedMemory<<<gridSize, blockSize>>>(dev_Data, dev_Histogramme, size, distributionSize);

	cudaDeviceSynchronize();
	cudaError_t error = cudaGetLastError();
	if (error != cudaSuccess)
	{
		fprintf(stderr, "Erreur CUDA : %s\n", cudaGetErrorString(error));
		// Traitez l'erreur en conséquence
	}

	HANDLE_ERROR (cudaMemcpy( histogramme, dev_Histogramme, distributionSize * sizeof(int), 
		cudaMemcpyDeviceToHost ));

	chr.stop();

	/// TODO - Free memory on Device
	HANDLE_ERROR(cudaFree(dev_Data));
	HANDLE_ERROR(cudaFree(dev_Histogramme));

	return chr.elapsedTime();
}





/////////////////////WEIRDDDDDDDDDDDDDDDDDDDDDDD/////////////////