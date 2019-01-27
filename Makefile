nvcc_options= -gencode arch=compute_30,code=sm_30 -lm -D TEST --compiler-options -Wall 
sources = duplicate.cu

all: duplicate

duplicate: $(sources) Makefile duplicate.h
	nvcc -o duplicate $(sources) $(nvcc_options)

clean:
	rm duplicate
	