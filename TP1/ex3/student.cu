#include "student.hpp"

#include "utils/chronoGPU.hpp"

__global__ void kernelComputeSepia( const uchar *const dev_inPtr, uchar *const dev_outPtr, const int width, const int height ) 
{		
	/// TODO
	int x = blockIdx.x * blockDim.x +threadIdx.x;
	int y = blockIdx.y * blockDim.y +threadIdx.y;

	if (x < width && y < height) {

		int idx = x + y * width;

		float inRed = dev_inPtr[idx * 3];
		float inGreen = dev_inPtr[idx * 3 + 1];
		float inBlue = dev_inPtr[idx * 3 + 2];

		float outRed = min ( 255.0f , ( inRed * .393f + inGreen * .769f + inBlue * .189f ) ) ;
		float outGreen = min ( 255.0f , ( inRed * .349f + inGreen * .686f + inBlue * .168f ) ) ;
		float outBlue = min ( 255.0f , ( inRed * .272f + inGreen * .534f + inBlue * .131f ) ) ;

		dev_outPtr[idx * 3] = outRed;
		dev_outPtr[idx * 3 + 1] = outGreen;
		dev_outPtr[idx * 3 + 2] = outBlue;
	}
}

float sepiaGPU( const PPMBitmap &in, PPMBitmap &out ) 
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
	HANDLE_ERROR (cudaMemcpy( dev_outPtr, outPtr, sizeImg * sizeof(uchar), cudaMemcpyHostToDevice ));

	/// TODO - Configure kernel
	dim3 blockSize(32, 32); 
    dim3 gridSize((width + blockSize.x - 1) / blockSize.x, (height + blockSize.y - 1) / blockSize.y);

	ChronoGPU chr;
	chr.start();

	/// TODO - Launch kernel
	kernelComputeSepia<<<gridSize, blockSize>>>(dev_inPtr, dev_outPtr, width, height);

	HANDLE_ERROR (cudaMemcpy( outPtr, dev_outPtr, sizeImg * sizeof(uchar), cudaMemcpyDeviceToHost ));

	chr.stop();

	/// TODO - Free memory on Device
	HANDLE_ERROR (cudaFree( dev_inPtr ));
	HANDLE_ERROR (cudaFree( dev_outPtr ));

	return chr.elapsedTime();
}

