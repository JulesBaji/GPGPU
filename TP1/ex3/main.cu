#include <iostream>
#include <string>
#include <iomanip>

#include "utils/ppm.hpp"

#include "reference.hpp"
#include "student.hpp"

void printUsage() 
{
	std::cerr	<< "Usage: " << std::endl
			<< " \t -f <F>: <F> image file name" 			
		    << std::endl << std::endl;
	exit( EXIT_FAILURE );
}

int main( int argc, char **argv ) 
{	
	char fileName[2048];

	// Parse program arguments
	if ( argc == 1 ) 
	{
		std::cerr << "Please give a file..." << std::endl;
		printUsage();
	}

	for ( int i = 1; i < argc; ++i ) 
	{
		if ( !strcmp( argv[i], "-f" ) ) 
		{
			if ( sscanf( argv[++i], "%s", &fileName ) != 1 )
				printUsage();
		}
		else
			printUsage();
	}

	// ================================================================================================================
	// Get input image
	std::cout << "Loading image: " << fileName << std::endl;
	const PPMBitmap input( fileName );
	const int width		= input.getWidth();
	const int height	= input.getHeight();

	std::cout << "Image has " << width << " x " << height << " pixels" << std::endl;

	std::string baseSaveName = fileName;
	baseSaveName.erase( baseSaveName.end() - 4, baseSaveName.end() ); // erase .ppm

	// Create 3 output images
	PPMBitmap outCPU( width, height );
	PPMBitmap outGPU( width, height );

	// ================================================================================================================
	
	
	// ================================================================================================================
	// CPU sequential
	std::cout << "============================================"	<< std::endl;
	std::cout << "         Sequential version on CPU          "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	const float timeCPU = sepiaCPU( input, outCPU );

	std::string cpuName = baseSaveName;
	cpuName += "_sepia_CPU.ppm";
	outCPU.saveTo( cpuName.c_str() );
	
	std::cout << "-> Done : " << timeCPU << " ms" << std::endl << std::endl;

	// ================================================================================================================


	// ================================================================================================================
	// GPU CUDA
	std::cout << "============================================"	<< std::endl;
	std::cout << "         Parallel version on GPU            "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	const float timeGPU = sepiaGPU( input, outGPU );

	std::string gpuName = baseSaveName;
	gpuName += "_sepia_GPU.ppm";
	outGPU.saveTo( gpuName.c_str() );
	
	std::cout << "-> Done : " << timeGPU << " ms" << std::endl << std::endl;
	
	// ================================================================================================================

	std::cout << "============================================"	<< std::endl;
	std::cout << "         Checking results		             "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	for ( int y = 0; y < outCPU.getHeight(); ++y ) 
	{
		for ( int x = 0; x < outCPU.getWidth(); ++x ) 
		{
			const RGBcol &colCPU = outCPU.getPixel( x, y );
			const RGBcol &colGPU = outGPU.getPixel( x, y );
			// Result may be slightly different between CPU and GPU because of the floating-point calculation
			if ( fabsf(colCPU._r - colGPU._r) > 1
			||   fabsf(colCPU._g - colGPU._g) > 1 
			||   fabsf(colCPU._b - colGPU._b) > 1 )  { 
				std::cerr << "Error for pixel [" << x << ";" << y <<"]: " << std::endl;
				std::cerr << "\t CPU: ["	<< (int)colCPU._r << ";" 
											<< (int)colCPU._g << ";"
											<< (int)colCPU._b << "]" << std::endl;
				std::cerr << "\t GPU: [" 	<< (int)colGPU._r << ";" 
											<< (int)colGPU._g << ";"
											<< (int)colGPU._b << "]" << std::endl;
				std::cerr << "Retry!" << std::endl << std::endl;
				exit( EXIT_FAILURE );
			}
		}
	}
	std::cout << "Congratulations! Job's done!" << std::endl << std::endl;

	std::cout << "============================================" << std::endl;
	std::cout << "     Times recapitulation (only filter)     " << std::endl;
	std::cout << "============================================" << std::endl;
	std::cout << "-> CPU: " << std::fixed << std::setprecision(2) << timeCPU << " ms" << std::endl;
	std::cout << "-> GPU: " << std::fixed << std::setprecision(2) << timeGPU << " ms" << std::endl;

	return EXIT_SUCCESS;
}