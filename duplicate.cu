#include"duplicate.h"

__global__ void duplication_kernel(int *output,int*origin_data, int *data, int size){
	
	int tid = threadIdx.x + blockIdx.x * blockDim.x;
	int j=tid%size;
	int i=(tid-j)/size;		
			for ( int k = 0; k < img_size; k++){
				// printf("img_in[i]: %d\n",  img_in[i]);
				// printf("img_in[j]:%d\n",  img_in[j]);
				int diff = abs (img_in[i*img_size +k] - img_in[j*img_size +k]);
				if (diff == 0)
					num_of_one++;
				
			}
			percent[i * img_size + j]= (num_of_one);
			// int darsad = (num_of_one*100)/img_size;
			// printf("darsad tashabohe axe %d ba axe %d hast %d \n", counter , counter+repeat+1 ,darsad);
			//printf("darsad tashabohe axe %d ba axe %d hast %d \n", i , j ,num_of_one);
		

	
}
void sequential_duplicate(int *percent,int *img_in, int img_size){
// for(int p = 0 ; p< img_size*img_num; p++){
// 	printf("%d\t", img_in[p] );
// }	

	for(int i = 0; i < img_num; i++){
		for(int j = 0  ; j < img_num ; j++){
			int num_of_one=0;
			
			for ( int k = 0; k < img_size; k++){
				// printf("img_in[i]: %d\n",  img_in[i]);
				// printf("img_in[j]:%d\n",  img_in[j]);
				int diff = abs (img_in[i*img_size +k] - img_in[j*img_size +k]);
				if (diff == 0)
					num_of_one++;
				
			}
			percent[i * img_size + j]= (num_of_one);
			// int darsad = (num_of_one*100)/img_size;
			// printf("darsad tashabohe axe %d ba axe %d hast %d \n", counter , counter+repeat+1 ,darsad);
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
	int *input_h, *output_h, *device_output_h;
	int *input_d,*origin_input_d, *output_d;
	int stream_count = img_num*(img_num+1)/2;
	// int work_per_thread;

	// if(argc != 2){
	// 	printf("Correct way to execute this program is:\n");
	// 	printf("./blur block_size_x block_size_y stream_count\n");
	// 	printf("For example:\n./blur 16 16 \n");
	// 	return 1;
	// }

	
	input_size = IMAGE_SIZE_X * IMAGE_SIZE_Y;
	output_size = img_num * img_num;

	// har 2 ta ax dar yek block bashand 
	block_size_x = 2*input_size;
	

//	cudaStream_t* streams = (cudaStream_t *)malloc(sizeof(cudaStream_t) * STREAM_NUMBERS);

	// for(int i = 0; i < STREAM_NUMBERS; i++){
	// 	cudaStreamCreate(&streams[i]);
	// }

	// Initialize data on Host
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
	
	// Perform GPU Warm-up
	// CUDA_CHECK_RETURN(cudaMemcpyAsync(input_d, input_h, sizeof(int), cudaMemcpyHostToDevice, streams[0]));

	// Sequential blur operation
	// 
	set_clock();

	sequential_duplicate(output_h,input_h, input_size);


    elapsed_time = get_elapsed_time();

	printf("->sequential duplication time: %.4fms\n", elapsed_time / 1000);

	// CUDA Parallel duplication


	set_clock();


	// int stream_size = 2*input_size;
	// int stream_bytes = stream_size * sizeof(input_d[0]);

	grid_size_x =  img_num*(img_num);
	dim3 grid_dime(1, 1, 1);
	dim3 block_dime(grid_size_x, 1, 1);
	

	//stream count = tedade dafAti k in 2 halghe tekrar mishavand yani dar vaghe ma ruye stream count darim loop mizanim vali chon b offset 
	// niyaz darim majburim an ra b 2 hakgheye mojaza taghsim konim
	// for(int counter  = 0; counter < img_num; counter ++){
	// 	int origin_offset = counter*img_size;
		
	// 	for (int repeat=0 ; repeat< img_num - counter; repeat++){
			
			//int offset = img_size*(repeat+counter+1);
			cudaMemcpy(&input_d, &input_h, input_size*img_num, cudaMemcpyHostToDevice);
			//cudaMemcpy(&input_d[offset], &input_h[offset], stream_bytes/2, cudaMemcpyHostToDevice, streams[ repeat% STREAM_NUMBERS]);
		
			duplication_kernel<<< grid_dime, block_dime>>>(&output_d, &input_h,input_size);

			 cudaMemcpyAsync(&output_device_h, &output_d, output_size, cudaMemcpyDeviceToHost);
			// offset += stream_size;
	// 	}
	// }

	CUDA_CHECK_RETURN(cudaDeviceSynchronize()); // Wait for the GPU launched work to complete
	CUDA_CHECK_RETURN(cudaGetLastError());
	
    elapsed_time = get_elapsed_time();

    printf("-> CUDA duplication time: %.4fms\n", elapsed_time / 1000);

 //    #ifdef  TEST
     validate(output_h, device_output_h, img_num*img_num);
 //    #endif

	// for (int i = 0; i < STREAM_NUMBERS; i++){
 //        cudaStreamDestroy(streams[i]);
 //    }
	// //free(data_h);
	// CUDA_CHECK_RETURN(cudaFreeHost(data_h));
	// free(output_h);
	// free(streams);
	// //free(device_output_h);
	// CUDA_CHECK_RETURN(cudaFreeHost(device_output_h));

	// CUDA_CHECK_RETURN(cudaFree(output_d));
	// CUDA_CHECK_RETURN(cudaFree(data_d));

	return 0;
}
