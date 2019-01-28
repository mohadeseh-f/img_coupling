#ifndef _DUPLICATE_H
#define _DUPLICATE_H

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>
#include<sys/time.h>
#include<cuda.h>
#include<math_functions.h>
#include<math.h>

#define OPERATION(X) (sinf(X))/1319+(cosf(X))/1317+(cosf(X+13))*(sinf(X-13))

#define OPERATION_I(X) (X)/1319+(X)*((X)-13)

#define STREAM_NUMBERS 2

#define RANDOM_NUMBER_MAX 100

#define IMAGE_SIZE_X  8

#define IMAGE_SIZE_Y 8

//******
#define img_num 20

// #define stream_count  


//Macro for checking cuda errors following a cuda launch or api call
#define CUDA_CHECK_RETURN(value) {											\
	cudaError_t _m_cudaStat = value;										\
	if (_m_cudaStat != cudaSuccess) {										\
		fprintf(stderr, "Error %s at line %d in file %s\n",					\
				cudaGetErrorString(_m_cudaStat), __LINE__, __FILE__);		\
		exit(1);															\
	} }

struct timeval start, end;

void set_clock(){
	gettimeofday(&start, NULL);
}

double get_elapsed_time(){
	gettimeofday(&end, NULL);
	double elapsed = (end.tv_sec - start.tv_sec) * 1000000.0;
	elapsed += end.tv_usec - start.tv_usec;
	return elapsed;
}

void validate(int *a, int *b, int length) {
	for (int i = 0; i < length; ++i) {
		if (a[i] != b[i]) {
			printf("Different value detected at position: %d,"
					" expected %d but get %d\n", i, a[i], b[i]);
			return;
		}
	}
	printf("Tests PASSED successfully! There is no differences \\:D/\n");
}

void initialize_data_random(int **data, int data_size){

	static time_t t;
	srand((unsigned) time(&t));

	*data = (int *)malloc(sizeof(int) * data_size);    
	for(int i = 0; i < data_size; i++){
		(*data)[i] = rand() % RANDOM_NUMBER_MAX;
	}   
}   

void initialize_data_random_cudaMallocHost(int **data, int data_size){

	static time_t t;
	srand((unsigned) time(&t));

	cudaMallocHost((void **)data, sizeof(int) * data_size);
	for(int i = 0; i < data_size; i++){
		(*data)[i] = rand() % RANDOM_NUMBER_MAX;
	}   
}

void initialize_data_zero(int **data, int data_size){
	*data = (int *)malloc(sizeof(int) * data_size);
	memset(*data, 0, data_size*sizeof(int));
}   

void initialize_data_zero_cudaMallocHost(int **data, int data_size){
	cudaMallocHost((void **)data, sizeof(int) * data_size);
	memset(*data, 0, data_size*sizeof(int));
}


#endif
