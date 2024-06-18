#include "reference.hpp"

void calcHistogrammeCPU(const int *randomArray,  int *histogramme, const int size) {
	for(int i = 0; i < size;i++) {
		histogramme[randomArray[i]]++;
	}
}

