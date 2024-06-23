#include "naive_viewtestGPU.hpp"
#define BLOCK_SIZE 16

__global__ void kernelNaive_viewtest( const uint8_t *const dev_hmPtr, uint8_t *const dev_resultatsGPUPtr) 
{
	const int c = dev_xc + dev_yc * dev_width;
	const int zc = dev_hmPtr[c];

	int tid_x = threadIdx.x + blockIdx.x * blockDim.x;
	int tid_y = threadIdx.y + blockIdx.y * blockDim.y;

	// angle(c,p)
	const int zp = dev_hmPtr[tid_x + tid_y * dev_width];
	const float angle_cp = atan2f(zp - zc, sqrtf((tid_x - dev_xc)*(tid_x - dev_xc) + (tid_y - dev_yc)*(tid_y - dev_yc)));

	// DDA
	float x = dev_xc, y = dev_yc;
	const int dx = tid_x - dev_xc, dy = tid_y - dev_yc;
	const int D = max(abs(dx), abs(dy));
	const float incx = (float)dx / D;
    const float incy = (float)dy / D;

	// Tracé ( On evite le premier et dernier point)
	bool visible = true;
	for(int i = 0; i < D - 1; i++)
	{
		x += incx;
		y += incy;

		// angle(c,p(i,j))
		const int p_ij = int(x) + int(y) * dev_width;
		const int zp_ij = dev_hmPtr[p_ij];
		const float angle_cpij = atan2f(zp_ij - zc, sqrtf((x - dev_xc)*(x - dev_xc) + (y - dev_yc)*(y - dev_yc)));
		
		// Vérification angle(c,p) < angle(c,p(i,j))
		if ( angle_cp < angle_cpij )
		{
			visible = false;
			break;
		}
	}
	if (visible) dev_resultatsGPUPtr[tid_x + tid_y*dev_width] = 255u;
}

float naive_viewtestGPU(los::Heightmap &hm, const Point &c, los::Heightmap &resultatsGPU )
{
	uint8_t *hmPtr = hm.getPtr();
	uint8_t *resultatsGPUPtr = resultatsGPU.getPtr();

	uint8_t *dev_hmPtr;
	uint8_t *dev_resultatsGPUPtr;

	const std::size_t size = hm.getSize();
	const uint32_t width = hm.getWidth();
	const uint32_t height = hm.getHeight();

	HANDLE_ERROR(cudaMalloc(&dev_hmPtr, hm.getSize() * sizeof(uint8_t)));
	HANDLE_ERROR(cudaMalloc(&dev_resultatsGPUPtr, resultatsGPU.getSize() * sizeof(uint8_t)));

	HANDLE_ERROR (cudaMemcpy( dev_hmPtr, hmPtr, hm.getSize() * sizeof(uint8_t), cudaMemcpyHostToDevice ));
	HANDLE_ERROR (cudaMemcpy( dev_resultatsGPUPtr, resultatsGPUPtr, resultatsGPU.getSize() * sizeof(uint8_t), cudaMemcpyHostToDevice ));

	// les HANDLE_ERROR renvoient une erreur sur guacamole ??
	HANDLE_ERROR(cudaMemcpyToSymbol(dev_width, &width, sizeof(int)));
    HANDLE_ERROR(cudaMemcpyToSymbol(dev_xc, &c.x, sizeof(int)));
    HANDLE_ERROR(cudaMemcpyToSymbol(dev_yc, &c.y, sizeof(int)));

	dim3 blockSize(BLOCK_SIZE, BLOCK_SIZE); 
    dim3 gridSize((width + blockSize.x - 1) / blockSize.x, (height + blockSize.y - 1) / blockSize.y);

	ChronoGPU chr;
	chr.start();

	kernelNaive_viewtest<<<gridSize, blockSize>>>(dev_hmPtr, dev_resultatsGPUPtr);

	HANDLE_ERROR (cudaMemcpy( resultatsGPUPtr, dev_resultatsGPUPtr, resultatsGPU.getSize() * sizeof(uint8_t), cudaMemcpyDeviceToHost ));

	chr.stop();

	HANDLE_ERROR (cudaFree( dev_hmPtr ));
	HANDLE_ERROR (cudaFree( dev_resultatsGPUPtr ));

	return chr.elapsedTime();
}