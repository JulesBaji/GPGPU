#include "naive_tiledGPU.hpp"
#include "utils/commonCUDA.hpp" // Assurez-vous que HANDLE_ERROR et les autres macros nécessaires sont définies ici

#define BLOCK_SIZE 16

__global__ void kernelNaive_tiledGPU(const uint8_t *dev_hmPtr, uint8_t *dev_resultPtr, uint32_t width, uint32_t height, uint32_t tile_size)
{
    int tile_x = blockIdx.x * tile_size;
    int tile_y = blockIdx.y * tile_size;

    // Compute the maximum height for the current tile
    uint8_t max_height = 0;

    for (int y = tile_y; y < min(tile_y + tile_size, height); ++y) {
        for (int x = tile_x; x < min(tile_x + tile_size, width); ++x) {
            uint8_t height_val = dev_hmPtr[y * width + x];
            max_height = max(max_height, height_val);
        }
    }

    // Set all pixels in the current tile to the maximum height
    for (int y = tile_y; y < min(tile_y + tile_size, height); ++y) {
        for (int x = tile_x; x < min(tile_x + tile_size, width); ++x) {
            dev_resultPtr[y * width + x] = max_height;
        }
    }
}

void save_ppm_image_GPU(const los::Heightmap &result, const std::string &filename) {
    std::ofstream ppm_file(filename, std::ios::out | std::ios::binary);

    if (!ppm_file.is_open()) {
        std::cerr << "Error: Could not open file " << filename << " for writing." << std::endl;
        return;
    }

    const uint32_t width = result.getWidth();
    const uint32_t height = result.getHeight();

    ppm_file << "P6\n";
    ppm_file << width << " " << height << "\n";
    ppm_file << "255\n";

    for (int y = height - 1; y >= 0; --y) {
        for (uint32_t x = 0; x < width; ++x) {
            uint8_t pixel_value = result.getPixel(x, y);
            ppm_file.write(reinterpret_cast<const char*>(&pixel_value), sizeof(uint8_t));
            ppm_file.write(reinterpret_cast<const char*>(&pixel_value), sizeof(uint8_t));
            ppm_file.write(reinterpret_cast<const char*>(&pixel_value), sizeof(uint8_t));
        }
    }

    ppm_file.close();
}

void naive_tiledGPU(los::Heightmap &hm, los::Heightmap &result) {
    const uint32_t tile_size = 16; // Taille de tuile arbitraire, à ajuster
    const uint32_t width = hm.getWidth();
    const uint32_t height = hm.getHeight();

    uint8_t *dev_hmPtr;
    uint8_t *dev_resultPtr;

    // Allouer de la mémoire sur le GPU
    HANDLE_ERROR(cudaMalloc(&dev_hmPtr, hm.getSize() * sizeof(uint8_t)));
    HANDLE_ERROR(cudaMalloc(&dev_resultPtr, result.getSize() * sizeof(uint8_t)));

    // Copier les données de la carte de hauteur sur le GPU
    HANDLE_ERROR(cudaMemcpy(dev_hmPtr, hm.getPtr(), hm.getSize() * sizeof(uint8_t), cudaMemcpyHostToDevice));

    // Définir la taille des blocs et de la grille pour le kernel
    dim3 blockSize(BLOCK_SIZE, BLOCK_SIZE);
    dim3 gridSize((width + BLOCK_SIZE - 1) / BLOCK_SIZE, (height + BLOCK_SIZE - 1) / BLOCK_SIZE);

    // Appeler le kernel
    kernelNaive_tiledGPU<<<gridSize, blockSize>>>(dev_hmPtr, dev_resultPtr, width, height, tile_size);

    // Attendre que tous les threads CUDA aient terminé
    cudaDeviceSynchronize();

    // Copier les résultats du GPU vers l'hôte
    HANDLE_ERROR(cudaMemcpy(result.getPtr(), dev_resultPtr, result.getSize() * sizeof(uint8_t), cudaMemcpyDeviceToHost));

    // Libérer la mémoire allouée sur le GPU
    HANDLE_ERROR(cudaFree(dev_hmPtr));
    HANDLE_ERROR(cudaFree(dev_resultPtr));

    // Sauvegarder l'image résultante
    save_ppm_image_GPU(result, "result_gpu_naive.ppm");
}