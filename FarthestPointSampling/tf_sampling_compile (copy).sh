#/bin/bash
/usr/local/cuda-10.1/bin/nvcc tf_sampling_g.cu -o tf_sampling_g.cu.o -c -O2 -DGOOGLE_CUDA=1 -x cu -Xcompiler -fPIC
g++ -std=c++11 tf_sampling.cpp tf_sampling_g.cu.o -o tf_sampling_so.so -shared -fPIC -I /usr/local/lib/python3.6/dist-packages/tensorflow/include -I /usr/local/cuda-10.1/include -lcudart -L /usr/local/cuda-10.1/lib64/ -O2
# do not use the parameter: -D_GLIBCXX_USE_CXX11_ABI=0, for bug:tf_sampling_so.so: undefined symbol: _ZTIN10tensorflow8OpKernelE
