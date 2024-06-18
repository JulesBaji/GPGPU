#include <iostream>
#include <string>
#include <iomanip>

#include "utils/ppm.hpp"

#include "reference.hpp"
#include "student.hpp"
#include "convMatrices.hpp"
#include "utils/chronoCPU.hpp"
#include "generator.hpp"

int main( int argc, char **argv ) 
{	
	// ================================================================================================================
	// Generate histogram
	const uint32_t sampleNb = 100000000;
    const uint32_t distributionSize = 129;
	std::vector<int> randomArray(sampleNb, 0);
	hst::Generator hstGenerator;
	hstGenerator.sample(sampleNb, distributionSize, randomArray.data());

    // ================================================================================================================
	
	// ================================================================================================================
	// CPU sequential
	std::cout << "============================================"	<< std::endl;
	std::cout << "         Sequential version on CPU          "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	ChronoCPU chrono;
	chrono.start();

	std::vector<int> histogrammeCPU (sampleNb, 0);
	calcHistogrammeCPU(randomArray.data(), histogrammeCPU.data(), sampleNb);

	chrono.stop();
	const float timeCPU = chrono.elapsedTime();
	
	std::cout << "-> Done : " << timeCPU << " ms" << std::endl << std::endl;

	// ================================================================================================================


	// ================================================================================================================
	// GPU CUDA
	std::cout << "============================================"	<< std::endl;
	std::cout << "         Parallel version on GPU            "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	std::vector<int> histogrammeGPU (sampleNb, 0);
	const float timeGPU = calcHistogrammeGPU(randomArray.data(), histogrammeGPU.data(), sampleNb, distributionSize);
	
	std::cout << "-> Done : " << timeGPU << " ms" << std::endl << std::endl;
	
	// ================================================================================================================

	std::cout << "============================================"	<< std::endl;
	std::cout << "         Checking results		             "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	for(int i=0; i<distributionSize; i++) {
		if (histogrammeCPU[i]!= histogrammeGPU[i]) {
            std::cout << "ERROR : " << i << " : " << histogrammeCPU[i] << "!= " << histogrammeGPU[i] << std::endl;
			return 1;
        }
	}

	std::cout << "c bon" << std::endl << std::endl;

	std::cout << "Congratulations! Job's done!" << std::endl << std::endl;

	std::cout << "============================================" << std::endl;
	std::cout << "     Times recapitulation (only filter)     " << std::endl;
	std::cout << "============================================" << std::endl;
	std::cout << "-> CPU: " << std::fixed << std::setprecision(2) << timeCPU << " ms" << std::endl;
	std::cout << "-> GPU: " << std::fixed << std::setprecision(2) << timeGPU << " ms" << std::endl;

	return EXIT_SUCCESS;
}