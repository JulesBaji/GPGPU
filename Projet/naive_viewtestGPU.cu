#include "naive_viewtestGPU.hpp"
#define BLOCK_SIZE 256
#define N 1024

__global__ void kernelNaive_viewtest( const uint8_t *const dev_hmPtr, uint8_t *const dev_resultatsGPUPtr, const int size, const int width, const int height, 
	const int positionC) 
{		
	// Coordonnées du point donné
	const int xa = positionC%width;
	const int ya = positionC/width;
	// int et pas uint8_t : la différence de 2 hauteurs (zb - za) peut-être négative
	const int hC = dev_hmPtr[positionC];

	for(int x = threadIdx.x + blockDim.x * blockIdx.x; x < size; x+= blockDim.x * gridDim.x) 
	{
		// Si le point courant est différent du point donné
		if( x != positionC )
		{
			bool visible = true;

			// Coordonnées du point courant
			const int xb = x%width;
			const int yb = x/width;
			
			const int hPCourant = dev_hmPtr[x];
			// angle(c,p)
			const float angleCPCourant = atan2f(hPCourant - hC, sqrtf(float((xb - xa)*(xb - xa) + (yb - ya)*(yb - ya))));

			// DDA
			float xDDA = xa, yDDA = ya;
			const int dx = xb - xa, dy = yb - ya;
			const int D = (abs(dx) > abs(dy)) ? abs(dx) : abs(dy);
			const float incx = static_cast<float>(dx) / static_cast<float>(D);
			const float incy = static_cast<float>(dy) / static_cast<float>(D);

			// Tracage ( On evite le premier et dernier point)
			for(int i = 0; i < D - 1; i++)
			{
				xDDA += incx;
				yDDA += incy;

				// angle(c,p(i,j))
				const int xRast = xDDA;
				const int yRast = yDDA;
				const int hPRast = dev_hmPtr[xRast + yRast * width ];
				const float angleCPRast = atan2f(hPRast - hC, sqrtf(float((xRast - xa)*(xRast - xa) + (yRast - ya)*(yRast - ya))));

				// Vérification angle(c,p) < angle(c,p(i,j))
				if ( angleCPRast >= angleCPCourant )
				{
					visible = false;
					break;
				}
			}
			
			if(visible == true) 
			{
				// Inversion de l'axe des y pour une comparaison plus exacte : l'axe des ordonnées de 1.input.ppm est inversé
				int x2D = x%width;
				int inversionY2D = height - 1 - x/width;
				dev_resultatsGPUPtr[x2D + inversionY2D * width] = 255u;
			}	
		}
	}
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

	const int positionC = c.x + c.y * width;

	HANDLE_ERROR(cudaMalloc(&dev_hmPtr, hm.getSize() * sizeof(uint8_t)));
	HANDLE_ERROR(cudaMalloc(&dev_resultatsGPUPtr, resultatsGPU.getSize() * sizeof(uint8_t)));

	HANDLE_ERROR (cudaMemcpy( dev_hmPtr, hmPtr, hm.getSize() * sizeof(uint8_t), cudaMemcpyHostToDevice ));
	HANDLE_ERROR (cudaMemcpy( dev_resultatsGPUPtr, resultatsGPUPtr, resultatsGPU.getSize() * sizeof(uint8_t), cudaMemcpyHostToDevice ));

	dim3 blockSize(BLOCK_SIZE); 
    dim3 gridSize((size + blockSize.x - 1) / blockSize.x);

	ChronoGPU chr;
	chr.start();

	kernelNaive_viewtest<<<gridSize, blockSize>>>(dev_hmPtr, dev_resultatsGPUPtr, size, width, height, positionC);

	HANDLE_ERROR (cudaMemcpy( resultatsGPUPtr, dev_resultatsGPUPtr, resultatsGPU.getSize() * sizeof(uint8_t), cudaMemcpyDeviceToHost ));

	chr.stop();

	HANDLE_ERROR (cudaFree( dev_hmPtr ));
	HANDLE_ERROR (cudaFree( dev_resultatsGPUPtr ));

	return chr.elapsedTime();
}