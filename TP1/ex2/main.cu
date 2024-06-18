#include <iostream>
#include <cstdlib>
#include <iomanip>

#include "utils/chronoCPU.hpp"
#include "utils/chronoGPU.hpp"

#include "reference.hpp"
#include "student.hpp"

int vecSize = 10000000;

void printUsage(const char *prg)
{
	std::cerr << "Usage: " << prg << std::endl
			  << " \t -n <N>: <N> is the size of the vectors (default is " << vecSize << ")"
			  << std::endl
			  << std::endl;
	exit(EXIT_FAILURE);
}

int main(int argc, char **argv)
{
	// Parse program arguments
	for (int i = 1; i < argc; ++i)
	{
		if (!strcmp(argv[i], "-n"))
		{
			if (sscanf(argv[++i], "%d", &vecSize) != 1)
				printUsage(argv[0]);
		}
		else
		{
			printUsage(argv[0]);
		}
	}

	std::cout << "Summing vectors of size " << vecSize << std::endl
			  << std::endl;

	// ================================================================================================================
	// Allocation and initialization
	std::cout << "Allocating " << ((vecSize * 3 * sizeof(int)) >> 20) << " MB on Host" << std::endl;

	int *a = new int[vecSize];
	int *b = new int[vecSize];
	int *resCPU = new int[vecSize];

	std::cout << "(Initializing vectors)" << std::endl
			  << std::endl;
	for (int i = 0; i < vecSize; ++i)
	{
		a[i] = i;
		b[i] = -2 * i;
	}

	// ================================================================================================================

	// ================================================================================================================
	// CPU sequential
	std::cout << "============================================" << std::endl;
	std::cout << "         Sequential version on CPU          " << std::endl;
	std::cout << "============================================" << std::endl;

	std::cout << "Summming vectors" << std::endl;
	ChronoCPU chrCPU;
	chrCPU.start();
	sumArraysRef(vecSize, a, b, resCPU);
	chrCPU.stop();

	const float timeComputeCPU = chrCPU.elapsedTime();
	std::cout << "-> Done : " << std::fixed << std::setprecision(2) << timeComputeCPU << " ms" << std::endl
			  << std::endl;

	// ================================================================================================================

	// ================================================================================================================
	// GPU CUDA
	std::cout << "============================================" << std::endl;
	std::cout << "          Parallel version on GPU           " << std::endl;
	std::cout << "============================================" << std::endl;

	int *dev_a, *dev_b, *dev_res;

	// GPU allocation
	std::cout << "Allocating " << ((vecSize * 3 * sizeof(int)) >> 20) << " MB on Device" << std::endl;
	ChronoGPU chrGPU;
	chrCPU.start();
	allocateArraysCUDA(vecSize, &dev_a, &dev_b, &dev_res);
	chrCPU.stop();
	// ======================

	const float timeAllocGPU = chrCPU.elapsedTime();
	std::cout << "-> Done : " << std::fixed << std::setprecision(2) << timeAllocGPU << " ms" << std::endl
			  << std::endl;

	// Copy from host to device
	std::cout << "Copying data from Host to Device" << std::endl;
	chrGPU.start();
	copyFromHostToDevice(vecSize, a, b, &dev_a, &dev_b);
	chrGPU.stop();

	const float timeHtoDGPU = chrGPU.elapsedTime();
	std::cout << "-> Done : " << timeHtoDGPU << " ms" << std::endl
			  << std::endl;

	// Free useless memory on CPU
	delete[] a;
	delete[] b;

	// Launch kernel
	std::cout << "Summming vectors" << std::endl;
	chrGPU.start();
	launchKernel(vecSize, dev_a, dev_b, dev_res);
	chrGPU.stop();

	const float timeComputeGPU = chrGPU.elapsedTime();
	std::cout << "-> Done : " << std::fixed << std::setprecision(2) << timeComputeGPU << " ms" << std::endl
			  << std::endl;

	// copy from device to host
	std::cout << "Copying data from Device to Host" << std::endl;

	int *resGPU = new int[vecSize];

	chrGPU.start();

	copyFromDeviceToHost(vecSize, resGPU, dev_res);

	chrGPU.stop();
	const float timeDtoHGPU = chrGPU.elapsedTime();
	std::cout << "-> Done : " << std::fixed << std::setprecision(2) << timeDtoHGPU << " ms" << std::endl
			  << std::endl;

	// Free GPU memory
	freeArraysCUDA(dev_a, dev_b, dev_res);

	// ================================================================================================================

	std::cout << "============================================" << std::endl;
	std::cout << "              Checking results              " << std::endl;
	std::cout << "============================================" << std::endl;

	for (int i = 0; i < vecSize; ++i)
	{
		if (resCPU[i] != resGPU[i])
		{
			std::cerr << "Error at index " << i << " CPU:  " << resCPU[i] << " - GPU: " << resGPU[i] << " !!!" << std::endl;
			std::cerr << "Retry!" << std::endl
					  << std::endl;
			delete resCPU;
			delete resGPU;
			exit(EXIT_FAILURE);
		}
	}

	// Free memory on CPU
	delete resCPU;
	delete resGPU;

	std::cout << "Congratulations! Job's done!" << std::endl
			  << std::endl;

	std::cout << "============================================" << std::endl;
	std::cout << "            Times recapitulation            " << std::endl;
	std::cout << "============================================" << std::endl;
	std::cout << "-> CPU	Sequential" << std::endl;
	std::cout << "   - Computation:    " << std::fixed << std::setprecision(2)
			  << timeComputeCPU << " ms" << std::endl;
	std::cout << "-> GPU	" << std::endl;
	std::cout << "   - Allocation:     " << std::fixed << std::setprecision(2)
			  << timeAllocGPU << " ms " << std::endl;
	std::cout << "   - Host to Device: " << std::fixed << std::setprecision(2)
			  << timeHtoDGPU << " ms" << std::endl;
	std::cout << "   - Computation:    " << std::fixed << std::setprecision(2)
			  << timeComputeGPU << " ms" << std::endl;
	std::cout << "   - Device to Host: " << std::fixed << std::setprecision(2)
			  << timeDtoHGPU << " ms " << std::endl
			  << std::endl;

	return EXIT_SUCCESS;
}