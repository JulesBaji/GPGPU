#ifndef __STUDENT_HPP
#define __STUDENT_HPP

#include "utils/commonCUDA.hpp"

void allocateArraysCUDA(const int n,			  // vectors size
						int **dev_a, int **dev_b, // 2 vectors on Device
						int **dev_res);			  // result on Device

void copyFromHostToDevice(const int n,				  // vectors size
						  int *const a, int *const b, // 2 vectors on Host
						  int **dev_a, int **dev_b);  // 2 vectors on Device

void launchKernel(const int n,									  // vectors size
				  const int *const dev_a, const int *const dev_b, // vectors to sum
				  int *const dev_res);							  // result

void copyFromDeviceToHost(const int n,				 // vectors size
						  int *const res,			 // result on Host
						  const int *const dev_res); // result on Device

void freeArraysCUDA(int *const dev_a, int *const dev_b, int *const dev_res); // 3 vectors to free

// kernel
__global__ void sumArraysCUDA(const int n,									   // vectors size
				   const int *const dev_a, const int *const dev_b, // vectors to sum
				   int *const dev_res);							   // result

#endif
