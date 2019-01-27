nvcc_options= -gencode arch=compute_30,code=sm_30 -lm -D TEST --compiler-options -Wall 
sources = douplicate.cu

all: douplicate

douplicate.cu: $(sources) Makefile douplicate.h
	nvcc -o douplicate $(sources) $(nvcc_options)

clean:
	rm douplicate
	