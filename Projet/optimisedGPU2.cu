#include "optimisedGPU2.hpp"
// compatible CUDA
#include <algorithm>
#define BLOCK_SIZE 1
#define N 1024

__global__ void kernelOptimised_viewtest2( const uint8_t *const dev_hmPtr, uint8_t *const dev_resultatsGPUPtr, const int size, const int width, const int height, 
	const int xc, const int yc) 
{
	// refaire grille ?
	int tid = threadIdx.x + blockDim.x*blockIdx.x;
	// A B C D
	int val = tid % 4;
	// 0 1 0 1
	int alpha = tid % 2;
	// 0 0 1 1
	int beta = max(0, min(1, val - 1));

	// faut pas dépasser la dim (dimMax peut être > dim) + on vesqui le dernier pixel
	int iterateur_x = min(blockIdx.x/4, width - 2);
	int iterateur_y = min(blockIdx.x/4, height - 2);

	// B + C (simplifications A + B + C + D car A et D = 0 pour width)
	// alpha = itérations sur les colonnes
	// beta = itérations de droite à gauche
	int tid_x = (alpha*(1-beta)*(width-1) + (1-alpha)*beta*(width-1)) + (1-alpha)*(-2*beta+1)*iterateur_x;
	// C + D
	int tid_y = ((1-alpha)*beta*(height-1) + alpha*beta*(height-1)) + alpha*(-2*beta+1)*iterateur_y;

	// DDA
	const int c = xc + yc * width;
	const int zc = dev_hmPtr[c];

	float x = xc, y = yc;
	const int dx = tid_x - xc, dy = tid_y - yc;
	const int D = max(abs(dx), abs(dy));
	const float inxc = static_cast<float>(dx) / static_cast<float>(D);
	const float incy = static_cast<float>(dy) / static_cast<float>(D);

	// Initialisation de l'angle précédent à -PI pour que le premier angle soit forcément plus grand (car compris entre -PI/2 et PI/2)
	float angle_cp_ij_pred = -M_PI;

	// Tracage ( On evite le premier point)
	for(int i = 0; i < D; i++)
	{
		x += inxc;
		y += incy;

		// angle(c,p(i,j))
		const int p_ij = int(x) + int(y) * width;
		const int zp_ij = dev_hmPtr[p_ij];
		const float angle_cpij = atan2f(zp_ij - zc, sqrtf(float((x - xc)*(x - xc) + (y - yc)*(y - yc))));
		
		// Vérification angle(c,p) < angle(c,p(i,j))
		if ( angle_cpij >= angle_cp_ij_pred )
		{
			dev_resultatsGPUPtr[p_ij] = 255u;
			angle_cp_ij_pred = angle_cpij;
		}
	}
}

float optimised_viewtestGPU2(los::Heightmap &hm, const Point &c, los::Heightmap &resultatsGPU )
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

	dim3 blockSize(BLOCK_SIZE); 
	int maxDim = max(width, height);
    dim3 gridSize((4*maxDim + blockSize.x - 1) / blockSize.x);

	ChronoGPU chr;
	chr.start();

	kernelOptimised_viewtest2<<<gridSize, blockSize>>>(dev_hmPtr, dev_resultatsGPUPtr, size, width, height, c.x, c.y);

	HANDLE_ERROR (cudaMemcpy( resultatsGPUPtr, dev_resultatsGPUPtr, resultatsGPU.getSize() * sizeof(uint8_t), cudaMemcpyDeviceToHost ));

	chr.stop();

	HANDLE_ERROR (cudaFree( dev_hmPtr ));
	HANDLE_ERROR (cudaFree( dev_resultatsGPUPtr ));

	return chr.elapsedTime();
}