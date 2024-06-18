// DO NOT MODIFY THIS FILE !!!

#include "reference.hpp"

void sumArraysRef(const int n, const int *const a,
				  const int *const b, int *const res)
{
	for (int i = 0ll; i < n; ++i)
		res[i] = a[i] + b[i];
}
