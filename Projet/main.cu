#include "naive_viewtestCPU.hpp"
#include "naive_viewtestGPU.hpp"
#include "optimisedGPU.hpp"
#include "optimisedGPU2.hpp"
#include "utils/chronoCPU.hpp"
#include "naive_tiledCPU.hpp"
#include "naive_tiledGPU.hpp"
#include "optimized_tiled.hpp"

#include <iomanip>

int main( int argc, char **argv ) 
{	
	// ================================================================================================================
	// Creation heightmaps
	const char *fileName = "img/1.input.ppm";
    los::Heightmap hm(fileName);
	const uint32_t height = hm.getHeight();
	const uint32_t width = hm.getWidth();
    Point pixelDonne(245, 497);
    los::Heightmap resultatsCPUNaif(width, height);
    los::Heightmap resultatsGPUNaif(width, height);
	los::Heightmap resultatsGPUOptimise(width, height);
	los::Heightmap resultatsGPUOptimise2(width, height);
	los::Heightmap resultatsTiledCPU(width, height);
	los::Heightmap resultatsTiledGPU(width, height);
	
	// ================================================================================================================
	std::cout << "============================================"	<< std::endl;
	std::cout << "       Naive Sequential version on CPU      "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	ChronoCPU chronoNaif;
	chronoNaif.start();

	// Version CPU naïve
	naive_viewtestCPU(hm, pixelDonne, resultatsCPUNaif);

	chronoNaif.stop();
	const float timeCPUNaif = chronoNaif.elapsedTime();
	
	std::cout << "-> Done : " << timeCPUNaif << " ms" << std::endl << std::endl;

	// ================================================================================================================
	std::cout << "============================================"	<< std::endl;
	std::cout << "       Naive Parallel version on GPU        "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	// Version GPU naïve
	const float timeGPUNaif = naive_viewtestGPU(hm, pixelDonne, resultatsGPUNaif);
	
	std::cout << "-> Done : " << timeGPUNaif << " ms" << std::endl << std::endl;
	
	// ================================================================================================================
	std::cout << "============================================"	<< std::endl;
	std::cout << "     Optimised Parallel version on GPU      "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	// Version GPU optimisée
	const float timeGPUOptimise = optimised_viewtestGPU(hm, pixelDonne, resultatsGPUOptimise );
	
	std::cout << "-> Done : " << timeGPUOptimise << " ms" << std::endl << std::endl;

	// ================================================================================================================
	std::cout << "============================================"	<< std::endl;
	std::cout << "    Optimised Parallel version on GPU 2     "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	// Version GPU optimisée
	const float timeGPUOptimise2 = optimised_viewtestGPU2(hm, pixelDonne, resultatsGPUOptimise2 );
	
	std::cout << "-> Done : " << timeGPUOptimise2 << " ms" << std::endl << std::endl;
	
	// ================================================================================================================
	// CPU sequential
	std::cout << "============================================"	<< std::endl;
	std::cout << " Sequential version on CPU for Tiled Kernel "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	ChronoCPU chronoTiledCPU;
	chronoTiledCPU.start();

	naive_tiledCPU(resultatsCPUNaif, resultatsTiledCPU);

	chronoTiledCPU.stop();
	const float timeCPU_tiled = chronoTiledCPU.elapsedTime();
	
	
	std::cout << "-> Done : " << timeCPU_tiled << " ms" << std::endl << std::endl;

	// ================================================================================================================

	std::cout << "============================================"	<< std::endl;
	std::cout << "  Parallel version on GPU for Tiled Kernel  "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	const float timeGPU_tiled = naive_tiledGPU(resultatsGPUNaif, resultatsTiledGPU);
	
	
	std::cout << "-> Done : " << timeGPU_tiled << " ms" << std::endl << std::endl;

	// ================================================================================================================

	std::cout << "============================================"	<< std::endl;
	std::cout << " Parallel version on GPU 2 for Tiled Kernel "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	// const float time_optimized_GPU_tiled = naive_tiledGPU(resultatsGPUOptimise2, resultatsTiledGPU);
	
	
	// std::cout << "-> Done : " << time_optimized_GPU_tiled << " ms" << std::endl << std::endl;

	// ================================================================================================================

	std::cout << "============================================" << std::endl;
	std::cout << "     Times recapitulation (only filter)     " << std::endl;
	std::cout << "============================================" << std::endl;
	std::cout << "-> CPU Naïf : " << std::fixed << std::setprecision(2) << timeCPUNaif << " ms" << std::endl;
	std::cout << "-> GPU Naïf : " << std::fixed << std::setprecision(2) << timeGPUNaif << " ms" << std::endl;
	std::cout << "-> GPU Optimisé : " << std::fixed << std::setprecision(2) << timeGPUOptimise << " ms" << std::endl;
	std::cout << "-> GPU Optimisé 2 : " << std::fixed << std::setprecision(2) << timeGPUOptimise2 << " ms" << std::endl;

	std::cout << "-> CPU Tiled Naïf : " << std::fixed << std::setprecision(2) << timeCPU_tiled << " ms" << std::endl;
	std::cout << "-> GPU Tiled Naïf : " << std::fixed << std::setprecision(2) << timeGPU_tiled << " ms" << std::endl;
	// std::cout << "-> GPU Tiled Naïf : " << std::fixed << std::setprecision(2) << time_optimized_GPU_tiled << " ms" << std::endl;

	return EXIT_SUCCESS;
}