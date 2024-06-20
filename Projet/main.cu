#include "utils/chronoCPU.hpp"
#include "naive_viewtestCPU.hpp"
#include "naive_viewtestGPU.hpp"
#include "optimized_tiledGPU.hpp"
#include "optimised_viewtestGPU.hpp"
#include "optimised_viewtestGPU2.hpp"
#include "naive_tiledCPU.hpp"
#include "naive_tiledGPU.hpp"
#include <iomanip>
#include "save_ppm_image.hpp"

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

	const uint32_t ppm_tiled_size = 10; // nombre de pixels de l'image
	const uint32_t tile_size_width = (width + ppm_tiled_size - 1) / ppm_tiled_size; // taille des tuiles en largeur
	const uint32_t tile_size_height = (height + ppm_tiled_size - 1) / ppm_tiled_size; // taille des tuiles en hauteur
	los::Heightmap resultatsTiledCPU(ppm_tiled_size, ppm_tiled_size);
	los::Heightmap resultatsTiledGPU(ppm_tiled_size, ppm_tiled_size);
	los::Heightmap resultatsTiledGPUOptimise(ppm_tiled_size, ppm_tiled_size);
	
	// ================================================================================================================
	std::cout << "============================================"	<< std::endl;
	std::cout << "       Naive Sequential version on CPU      "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	ChronoCPU chronoNaif;
	chronoNaif.start();

	naive_viewtestCPU(hm, pixelDonne, resultatsCPUNaif);

	chronoNaif.stop();
	const float timeCPUNaif = chronoNaif.elapsedTime();

	save_ppm_image(resultatsCPUNaif, "results_naive_viewtest_CPU.ppm");

	std::cout << "-> Done : " << timeCPUNaif << " ms" << std::endl << std::endl;

	// ================================================================================================================
	std::cout << "============================================"	<< std::endl;
	std::cout << "       Naive Parallel version on GPU        "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	const float timeGPUNaif = naive_viewtestGPU(hm, pixelDonne, resultatsGPUNaif);

	save_ppm_image(resultatsGPUNaif, "results_naive_viewtest_GPU.ppm");
	
	std::cout << "-> Done : " << timeGPUNaif << " ms" << std::endl << std::endl;
	
	// ================================================================================================================
	std::cout << "============================================"	<< std::endl;
	std::cout << "     Optimised Parallel version on GPU      "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	const float timeGPUOptimise = optimised_viewtestGPU(hm, pixelDonne, resultatsGPUOptimise );

	save_ppm_image(resultatsGPUOptimise, "results_optimized_viewtest_GPU.ppm");
	
	std::cout << "-> Done : " << timeGPUOptimise << " ms" << std::endl << std::endl;

	// ================================================================================================================
	std::cout << "============================================"	<< std::endl;
	std::cout << "    Optimised Parallel version on GPU 2     "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	const float timeGPUOptimise2 = optimised_viewtestGPU2(hm, pixelDonne, resultatsGPUOptimise2 );

	save_ppm_image(resultatsGPUOptimise2, "results_optimized_viewtest_GPU2.ppm");
	
	std::cout << "-> Done : " << timeGPUOptimise2 << " ms" << std::endl << std::endl;
	
	// ================================================================================================================
	// CPU sequential
	std::cout << "============================================"	<< std::endl;
	std::cout << " Sequential version on CPU for Tiled Kernel "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	ChronoCPU chronoTiledCPU;
	chronoTiledCPU.start();

	naive_tiledCPU(hm, resultatsTiledCPU, ppm_tiled_size, width, height, tile_size_width, tile_size_height);

	chronoTiledCPU.stop();
	const float timeCPU_tiled = chronoTiledCPU.elapsedTime();
	
	save_ppm_image(resultatsTiledCPU, "results_naive_tiled_CPU.ppm");
	
	std::cout << "-> Done : " << timeCPU_tiled << " ms" << std::endl << std::endl;

	// ================================================================================================================

	std::cout << "============================================"	<< std::endl;
	std::cout << "Naive Parallel version on GPU for Tiled Kernel"	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	const float time_naive_tiled_GPU =  naive_tiledGPU(hm, resultatsTiledGPU, ppm_tiled_size, width, height, tile_size_width, tile_size_height);

	save_ppm_image(resultatsTiledGPU, "results_naive_tiled_GPU.ppm");
	
	std::cout << "-> Done : " << time_naive_tiled_GPU << " ms" << std::endl << std::endl;

	// ================================================================================================================

	std::cout << "============================================"	<< std::endl;
	std::cout << "Optimized Parallel version on GPU for Tiled Kernel"	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	const float time_optimized_tiled_GPU =  optimized_tiledGPU(hm, resultatsTiledGPUOptimise, ppm_tiled_size, width, height, tile_size_width, tile_size_height);

	save_ppm_image(resultatsTiledGPUOptimise, "results_optimized_tiled_GPU.ppm");
	
	std::cout << "-> Done : " << time_optimized_tiled_GPU << " ms" << std::endl << std::endl;

	// ================================================================================================================

	std::cout << "============================================" << std::endl;
	std::cout << "     Times recapitulation (only filter)     " << std::endl;
	std::cout << "============================================" << std::endl;
	std::cout << "-> CPU Viewtest Naïf : " << std::fixed << std::setprecision(2) << timeCPUNaif << " ms" << std::endl;
	std::cout << "-> GPU Viewtest Naïf : " << std::fixed << std::setprecision(2) << timeGPUNaif << " ms" << std::endl;
	std::cout << "-> GPU Viewtest Optimisé : " << std::fixed << std::setprecision(2) << timeGPUOptimise << " ms" << std::endl;
	std::cout << "-> GPU Viewtest Optimisé 2 : " << std::fixed << std::setprecision(2) << timeGPUOptimise2 << " ms" << std::endl;

	std::cout << "-> CPU Tiled Naïf : " << std::fixed << std::setprecision(2) << timeCPU_tiled << " ms" << std::endl;
	std::cout << "-> GPU Tiled Naïf : " << std::fixed << std::setprecision(2) << time_naive_tiled_GPU << " ms" << std::endl;
	std::cout << "-> GPU Tiled Optimisé : " << std::fixed << std::setprecision(2) << time_optimized_tiled_GPU << " ms" << std::endl;

	return EXIT_SUCCESS;
}