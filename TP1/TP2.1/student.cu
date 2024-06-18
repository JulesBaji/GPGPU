#include "student.hpp"
#include "math.h"

__global__ void kernelComputeConv( const uchar *const dev_inPtr, uchar *const dev_outPtr, const int width, 
	const int height, const int tailleMatrice ) 
{		
	// Process image rows
	for ( int y = threadIdx.y + blockDim.y * blockIdx.y; y < height; y+= (blockDim.y * gridDim.y) ){
		for ( int x = threadIdx.x + blockDim.x * blockIdx.x; x < width; x+= (blockDim.x * gridDim.x) ) {
			float3 sum = {0.f} ;
			for ( int j = 0; j < tailleMatrice; ++j ) {
				for ( int i = 0; i < tailleMatrice; ++i ) {
					int dX = x + i - tailleMatrice / 2;
					int dY = y + j - tailleMatrice /2;

					if ( dX < 0 ) 
						dX = 0;

					if ( dX >= width ) 
						dX = width - 1;

					if ( dY < 0 ) 
						dY = 0;

					if ( dY >= height ) 
						dY = height - 1;

					const int idMat		= j * tailleMatrice + i;
					const int idPixel	= (dY * width + dX) * 3;
					sum.x += (float)dev_inPtr[idPixel] * convMat[idMat];
					sum.y += (float)dev_inPtr[idPixel + 1] * convMat[idMat];
					sum.z += (float)dev_inPtr[idPixel + 2] * convMat[idMat];
        		}
			}
			const int idOut = (y * width + x) * 3;
			dev_outPtr[idOut] = (unsigned char)(sum.x < 0.0f ? 0.0f : ((sum.x > 255.0f ? 255.0f : sum.x)));
            dev_outPtr[idOut + 1] = (unsigned char)(sum.y < 0.0f ? 0.0f : ((sum.y > 255.0f ? 255.0f : sum.y)));
            dev_outPtr[idOut + 2] = (unsigned char)(sum.z < 0.0f ? 0.0f : ((sum.z > 255.0f ? 255.0f : sum.z)));
		}
	}
}

float convGPU( const PPMBitmap &in, PPMBitmap &out, const float *const matrice,
	const int tailleMatrice) 
{
	// Pixel table on Host
	uchar *inPtr	= in.getPtr();
	uchar *outPtr	= out.getPtr();

	// Pixel table on Device
	uchar *dev_inPtr;
	uchar *dev_outPtr;

	const size_t sizeImg = in.getSize();

	const int width		= in.getWidth();
	const int height	= in.getHeight();

	/// TODO - Allocate memory on Device
	HANDLE_ERROR (cudaMalloc( &dev_inPtr, sizeImg * sizeof(uchar) )) ;
	HANDLE_ERROR (cudaMalloc( &dev_outPtr, sizeImg * sizeof(uchar) )) ;

	/// TODO - Copy from Host to Device
	HANDLE_ERROR (cudaMemcpy( dev_inPtr, inPtr, sizeImg * sizeof(uchar), cudaMemcpyHostToDevice ));
	// MATRICE
	HANDLE_ERROR (cudaMemcpyToSymbol(convMat, matrice, tailleMatrice * tailleMatrice * sizeof(float)));

	/// TODO - Configure kernel
	dim3 blockSize(32, 32); 
    dim3 gridSize((width + 32 - 1) / 32, (height + 32 - 1) / 32);

	ChronoGPU chr;
	chr.start();

	/// TODO - Launch kernel
	kernelComputeConv<<<gridSize, blockSize>>>(dev_inPtr, dev_outPtr, width, height, tailleMatrice);

	HANDLE_ERROR (cudaMemcpy( outPtr, dev_outPtr, sizeImg * sizeof(uchar), cudaMemcpyDeviceToHost ));

	chr.stop();

	/// TODO - Free memory on Device
	HANDLE_ERROR (cudaFree( dev_inPtr ));
	HANDLE_ERROR (cudaFree( dev_outPtr ));

	return chr.elapsedTime();
}