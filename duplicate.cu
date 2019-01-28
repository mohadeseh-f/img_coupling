
/* this is project of GPU course in shiraz university  project obout finding duplicated pictuers 
*/
#include"duplicate.h"


 // this function used for kernel in GPU

__global__ void duplication_kernel(int *output, int *data, int size){
	
	int tid = threadIdx.x + blockIdx.x * blockDim.x;
	int j=tid%size;
	int i=(tid-j)/size;		
			int num_of_one=0;
			for ( int k = 0; k < size; k++){
				int diff = abs (data[i*size +k] - data[j*size +k]);
				if (diff == 0)
					num_of_one++;
				
			}
			output[i * size + j]= (num_of_one*100)/(RANDOM_NUMBER_MAX*size *size);
	
}


// this function used sequential implimentation of duplicaded pictures and calcuate time
void sequential_duplicate(int *percent,int *img_in, int img_size){
	
	for(int i = 0; i < img_num; i++){
		for(int j = 0  ; j < img_num ; j++){
			int num_of_one=0;
			
			for ( int k = 0; k < img_size; k++){
				int diff = abs (img_in[i*img_size +k] - img_in[j*img_size +k]);
				if (diff == 0)
					num_of_one++;
				
			}
			percent[i * img_size + j]= (num_of_one*100)/(RANDOM_NUMBER_MAX*img_size *img_size);
			printf("darsad tashabohe axe %d ba axe %d hast %d \n", i , j ,num_of_one);
		}

	}
	return;
}

int main(int argc, char *argv[]){

	double elapsed_time;
	int block_size_x, grid_size_x;
	int input_size;
	int output_size;
	int *input_h, *output_h, *output_device_h;
	int *input_d,*origin_input_d, *output_d;
	int stream_count = img_num*(img_num+1)/2;

	
	input_size = IMAGE_SIZE_X * IMAGE_SIZE_Y;
	output_size = img_num * img_num;
	block_size_x = 2*input_size;
	

	int count;
	initialize_data_random_cudaMallocHost(&input_h, input_size*img_num);
	
	// Initialize data on Host
	
	//initialize_data_zero(&output_h, output_size);
	initialize_data_zero_cudaMallocHost(&output_h, output_size);
	//initialize_data_zero_cudaMallocHost(&device_output_h, output_size);
	initialize_data_zero_cudaMallocHost(&output_device_h, output_size);
	// Initialize data on Device
	CUDA_CHECK_RETURN(cudaMalloc((void **)&input_d, sizeof(int)*input_size*img_num));
	CUDA_CHECK_RETURN(cudaMalloc((void **)&origin_input_d, sizeof(int)*output_size));

	CUDA_CHECK_RETURN(cudaMalloc((void **)&output_d, sizeof(int)*output_size));
	

	// Sequential opration
	// 
	set_clock();

	sequential_duplicate(output_h,input_h, input_size);


    elapsed_time = get_elapsed_time();

	printf("->sequential duplication time: %.4fms\n", elapsed_time / 1000);

	// CUDA Parallel duplication


	set_clock();


	// this part calculate gride size and block size for GPU
	grid_size_x =  img_num*(img_num);
	dim3 grid_dime(1, 1, 1);
	dim3 block_dime(grid_size_x, 1, 1);
	

	
	cudaMemcpy(&input_d, &input_h, input_size*img_num, cudaMemcpyHostToDevice);
			
	duplication_kernel<<< grid_dime, block_dime>>>(output_d, input_h, input_size);

	cudaMemcpy(&output_device_h, &output_d, output_size, cudaMemcpyDeviceToHost);
		

	CUDA_CHECK_RETURN(cudaDeviceSynchronize()); // Wait for the GPU launched work to complete
	CUDA_CHECK_RETURN(cudaGetLastError());
	
    elapsed_time = get_elapsed_time();

    printf("-> CUDA duplication time: %.4fms\n", elapsed_time / 1000);

     validate(output_h, output_device_h, img_num*img_num);
 
 	 // fre allocated memories 
	free(input_d);
	free(output_d);
	
	CUDA_CHECK_RETURN(cudaFreeHost(output_device_h));

	CUDA_CHECK_RETURN(cudaFree(output_h));
	CUDA_CHECK_RETURN(cudaFree(input_h));

	return 0;
}
