#include "student.hpp"

void allocateArraysCUDA(const int n, int **dev_a, int **dev_b, int **dev_res)
{
	/* allocation de la memoire sur le GPU */

	HANDLE_ERROR (cudaMalloc( &dev_a, n * sizeof(int) )) ;
	HANDLE_ERROR (cudaMalloc( (void**)&dev_b, n * sizeof(int) )) ;
	HANDLE_ERROR (cudaMalloc( (void**)&dev_res, n * sizeof(int) )) ;
}

void copyFromHostToDevice(const int n, int *const a, int *const b,
						  int **dev_a, int **dev_b)
{
	/* fill the arrays 'a' and 'b' on the CPU */

	for (int i=0; i<n; i++)
	{
		a[i] = -i;
		b[i] = i * i;
	}

	/* copie des tableaux a et b sur le GPU */

	HANDLE_ERROR (cudaMemcpy( dev_a, a, n * sizeof(int), cudaMemcpyHostToDevice ));
	HANDLE_ERROR (cudaMemcpy( dev_b, b, n * sizeof(int), cudaMemcpyHostToDevice ));
}

void launchKernel(const int n, const int *const dev_a,
				  const int *dev_b, int *const dev_res)
{
	sumArraysCUDA<<<n,1>>>(n, dev_a, dev_b, dev_res );
}

void copyFromDeviceToHost(const int n, int *res, const int *const dev_res)
{
	/* copie du tableau dev_res depuis le GPU sur le CPU */

	HANDLE_ERROR (cudaMemcpy( res, dev_res, n * sizeof(int), cudaMemcpyDeviceToHost ));
}

void freeArraysCUDA(int *const dev_a, int *const dev_b, int *const dev_res)
{
	/* liberer la memoire allouee sur le GPU */

	HANDLE_ERROR (cudaFree( dev_a ));
	HANDLE_ERROR (cudaFree( dev_b ));
	HANDLE_ERROR (cudaFree( dev_res ));
}

__global__ void sumArraysCUDA(const int n,	const int *const dev_a,
				   const int *dev_b, int *const dev_res)
{

	int tid = blockIdx.x; /* handle the data at this index */
	if (tid < n)
		dev_res[tid] = dev_a[tid] + dev_b[tid];
}
