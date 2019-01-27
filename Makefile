nvcc_options= -gencode arch=compute_30,code=sm_30 -lm -D TEST --compiler-options -Wall 
sources = coupling.cu

all: coupling

coupling.cu: $(sources) Makefile coupling.h
	nvcc -o coupling $(sources) $(nvcc_options)

clean:
	rm coupling
	