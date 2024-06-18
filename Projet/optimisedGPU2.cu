#include "optimisedGPU2.hpp"
#define BLOCK_SIZE 256
#define N 1024

__global__ void kernelOptimised_viewtest2( const uint8_t *const dev_hmPtr, uint8_t *const dev_resultatsGPUPtr, const int size, const int width, const int height, 
	const int xc, const int yc) 
{
	// refaire grille ? Régler pb grille avec longueur != largeur et pixel en trop
	int tid = threadIdx.x + blockDim.x*blockIdx.x;
	// A B C D
	int val = tid % 4;
	// 0 1 1 0
	int alpha = 1 - ((val % 3) == 0);
	// 0 0 1 1
	int beta = (val - 1) <= 0 ? 0 : 1;
	// 0 1 0 1
	int gamma = tid % 2;

	// D C B A (pas besoin de A vu que c'est l'opposé de C)
	int tid_x = (alpha*(1-beta)*(width-1) + alpha*beta*(width-1) + alpha*(1-beta)*(width-1))
		+ (1-gamma)*(1-beta)*threadIdx.x/4 + (1-gamma)*beta*(width-1 - threadIdx.x/4);
	int tid_y = ((1-alpha)*beta*(height-1) + alpha*beta*(height-1) + (1-alpha)*beta*(height-1))
		+ gamma*(1-beta)*threadIdx.x/4 + gamma*beta*(height-1 - threadIdx.x/4);

	dev_resultatsGPUPtr[tid_x + tid_y*width] = 255u;

	const int c = xc + yc * width;
	const int zc = dev_hmPtr[c];

	// DDA
	float x = xc, y = yc;
	const int dx = tid_x - xc, dy = tid_y - yc;
	const int D = (abs(dx) > abs(dy)) ? abs(dx) : abs(dy);
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
	int minDim = width < height ? width : height;
    dim3 gridSize((4*minDim + blockSize.x - 1) / blockSize.x);

	ChronoGPU chr;
	chr.start();

	kernelOptimised_viewtest2<<<gridSize, blockSize>>>(dev_hmPtr, dev_resultatsGPUPtr, size, width, height, c.x, c.y);

	HANDLE_ERROR (cudaMemcpy( resultatsGPUPtr, dev_resultatsGPUPtr, resultatsGPU.getSize() * sizeof(uint8_t), cudaMemcpyDeviceToHost ));

	chr.stop();

	HANDLE_ERROR (cudaFree( dev_hmPtr ));
	HANDLE_ERROR (cudaFree( dev_resultatsGPUPtr ));

	return chr.elapsedTime();
}