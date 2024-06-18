#ifndef MDBR_CUDAMACRO_CUH
#define MDBR_CUDAMACRO_CUH

#include <cuda.h>

namespace mdbr
{
    void checkCudaErrors(cudaError_t err);
}

#endif // MDBR_CUDAMACRO_CUH