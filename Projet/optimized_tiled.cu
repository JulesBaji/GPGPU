#include "optimized_tiled.hpp"
#include <fstream>
#define TILE_SIZE 16


__global__ void kernelOptimized_tiled(const uint8_t *const dev_hmPtr, uint8_t *const dev_resultPtr, const int width, const int height, const int tile_size) {
    
    // Mémoire partagée
	__shared__ uint8_t cache[TILE_SIZE]; 

	// Initialisation de la mémoire partagée
	for (int i = threadIdx.x; i < TILE_SIZE; i += blockDim.x) {
        cache[i] = 0;
    }

    __syncthreads();
    
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < width && y < height) {
        int tile_x = (x / tile_size) * tile_size;
        int tile_y = (y / tile_size) * tile_size;

        // Calcul de la hauteur maximale dans la tuile
        uint8_t max_height = 0;
        for (int i = 0; i < tile_size; ++i) {
            for (int j = 0; j < tile_size; ++j) {
                int cur_x = tile_x + j;
                int cur_y = tile_y + i;
                if (cur_x < width && cur_y < height) {
                    uint8_t height_val = dev_hmPtr[cur_x + cur_y * width];
                    max_height = max(max_height, height_val);
                }
            }
        }

        // Mise à jour des pixels dans la tuile
        for (int i = 0; i < tile_size; ++i) {
            for (int j = 0; j < tile_size; ++j) {
                int cur_x = tile_x + j;
                int cur_y = tile_y + i;
                if (cur_x < width && cur_y < height) {
                    dev_resultPtr[cur_x + cur_y * width] = max_height;
                }
            }
        }
    }

    __syncthreads();

    for(int x = threadIdx.x + blockDim.x * blockIdx.x; x < TILE_SIZE; x+= blockDim.x * gridDim.x)
	{	
		dev_resultPtr[x] = cache[threadIdx.x];
    }
}

void save_ppm_image_OPTIMIZED( los::Heightmap &result, const std::string &filename) {
    std::ofstream ppm_file(filename, std::ios::out | std::ios::binary);

    if (!ppm_file.is_open()) {
        std::cerr << "Error: Could not open file " << filename << " for writing." << std::endl;
        return;
    }

    const uint32_t width = result.getWidth();
    const uint32_t height = result.getHeight();
    uint8_t *resultPtr = result.getPtr();

    ppm_file << "P6\n";
    ppm_file << width << " " << height << "\n";
    ppm_file << "255\n";

    for (uint32_t y = 0; y < height; ++y) {
        for (uint32_t x = 0; x < width; ++x) {
            uint8_t pixel_value = resultPtr[x + y * width];
            ppm_file.write(reinterpret_cast<const char*>(&pixel_value), sizeof(uint8_t));
            ppm_file.write(reinterpret_cast<const char*>(&pixel_value), sizeof(uint8_t));
            ppm_file.write(reinterpret_cast<const char*>(&pixel_value), sizeof(uint8_t));
        }
    }

    ppm_file.close();
}


float optimized_tiled( los::Heightmap &hm, los::Heightmap &result) {
    const uint32_t tile_size = 16; // Taille de tuile arbitraire, à ajuster
    const uint32_t width = hm.getWidth();
    const uint32_t height = hm.getHeight();

    uint8_t *dev_hmPtr;
    uint8_t *dev_resultPtr;

    HANDLE_ERROR(cudaMalloc(&dev_hmPtr, hm.getSize() * sizeof(uint8_t)));
    HANDLE_ERROR(cudaMalloc(&dev_resultPtr, result.getSize() * sizeof(uint8_t)));

    HANDLE_ERROR(cudaMemcpy(dev_hmPtr, hm.getPtr(), hm.getSize() * sizeof(uint8_t), cudaMemcpyHostToDevice));

    dim3 blockSize(tile_size, tile_size);
    dim3 gridSize((width + blockSize.x - 1) / blockSize.x, (height + blockSize.y - 1) / blockSize.y);

    kernelOptimized_tiled<<<gridSize, blockSize>>>(dev_hmPtr, dev_resultPtr, width, height, tile_size);

    HANDLE_ERROR(cudaMemcpy(result.getPtr(), dev_resultPtr, result.getSize() * sizeof(uint8_t), cudaMemcpyDeviceToHost));

    save_ppm_image_OPTIMIZED(result, "result_optim.ppm");

    cudaFree(dev_hmPtr);
    cudaFree(dev_resultPtr);

    return 0.0f;  // Return a meaningful value here
}
