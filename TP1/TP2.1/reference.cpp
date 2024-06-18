#include "reference.hpp"

void convCPU( uchar *const out, const uchar *const in, 
				 const float *const kernelConv, // convolution matrix
				 const int imgWidth, const int imgHeight,
				 const int matWidth, const int matHeight ) {
	// Process image rows
	for ( int y = 0; y < imgHeight; ++y ){
		for ( int x = 0; x < imgWidth; ++x ) {
			float3 sum = {0.f} ;
			for ( int j = 0; j < matHeight; ++j ) {
				for ( int i = 0; i < matWidth; ++i ) {
					int dX = x + i - matWidth / 2;
					int dY = y + j - matHeight /2;

					if ( dX < 0 ) 
						dX = 0;

					if ( dX >= imgWidth ) 
						dX = imgWidth - 1;

					if ( dY < 0 ) 
						dY = 0;

					if ( dY >= imgHeight ) 
						dY = imgHeight - 1;

					const int idMat		= j * matWidth + i;
					const int idPixel	= (dY * imgWidth + dX) * 3;
					sum.x += (float)in[idPixel] * kernelConv[idMat];
					sum.y += (float)in[idPixel + 1] * kernelConv[idMat];
					sum.z += (float)in[idPixel + 2] * kernelConv[idMat];
        		}
			}
			const int idOut = (y * imgWidth + x) * 3;
            out[idOut] = (unsigned char)(sum.x < 0.0f ? 0.0f : ((sum.x > 255.0f ? 255.0f : sum.x)));
            out[idOut + 1] = (unsigned char)(sum.y < 0.0f ? 0.0f : ((sum.y > 255.0f ? 255.0f : sum.y)));
            out[idOut + 2] = (unsigned char)(sum.z < 0.0f ? 0.0f : ((sum.z > 255.0f ? 255.0f : sum.z)));
		}
	}
}

