# Mesh 2 Pts

Dependencies:

    Ubuntu 18.04
    anaconda, tf=1.10, python=3.6



O-CNN python packages installed using vcpkg, and modify the setup.py files; Or we can just using pip install . under ./virtual_scanner

Then, import ocnn can succuse only after we change pwd

the Points class is defined in /O-CNN/O-CNN/ocnn/octree/python/ocnn/octree/_octree.pyx


    cdef class Points:
        cdef _octree_extern.Points c_points
    
        def __cinit__(self, filename):
            cdef string stl_string = filename.encode('UTF-8')
            cdef bool points_read
            with nogil:
                points_read = self.c_points.read_points(stl_string)
            if not points_read:
                raise RuntimeError('Could not read points file: {0}'.format(filename))
    
        def write_file(self, filename):
            cdef string stl_string = filename.encode('UTF-8')
            with nogil:
                self.c_points.write_points(stl_string)
    
        def center(self):
            _, center = self.get_points_bounds()
            self.center_about(center)
    
        def center_about(self, np.ndarray center):
            center = _ensure_contiguous(center)
            _check_array(center, (3,))
    
            cdef float[::1] center_view = center.ravel()
    
            with nogil:
                self.c_points.center_about(&center_view[0])
    
        def displace(self, float displacement):
            with nogil:
                self.c_points.displace(displacement)
    
        def rotate(self, float angle, np.ndarray axis):
            axis = _ensure_contiguous(axis)
            _check_array(axis, (3,))
    
            cdef float[::1] axis_view = axis.ravel()
            with nogil:
                self.c_points.rotate(angle, &axis_view[0])
    
        def transform(self, np.ndarray transformation_matrix):
            transformation_matrix = _ensure_contiguous(transformation_matrix)
            _check_array(transformation_matrix, (3,3))
    
            cdef float[::1] mat_view = transformation_matrix.ravel()
    
            with nogil:
                self.c_points.transform(&mat_view[0])
    
        def get_points_bounds(self):
            cdef _octree_extern.PointsBounds points_bounds
            with nogil:
                points_bounds = self.c_points.get_points_bounds()
            cdef float[:] center_view = points_bounds.center
    
            center = np.empty_like (center_view)
            center[:] = center_view
    
            return points_bounds.radius, center
    
        def get_points_data(self):
            cdef _octree_extern.PointsData points_data = self.c_points.get_points_data()
            cdef Py_ssize_t nrows = points_data.npt, ncols=3
            cdef const float[:,::1] points_view = <float[:nrows, :ncols]> points_data.pts
            cdef const float[:,::1] normals_view = <float[:nrows, :ncols]>points_data.normals
    
            points = np.empty_like (points_view)
            points[:] = points_view
            normals = np.empty_like (normals_view)
            normals[:] = normals_view
    
            return points, normals

# Farthest Point Sampling
This part uses the tf_ops in Pointnet2(Pointnet++).

Compile Customized TF Operators
The TF operators are included under tf_ops, you need to compile them (check tf_xxx_compile.sh under each ops subfolder) first. Update nvcc and python path if necessary. The code is tested under TF1.2.0. If you are using earlier version it's possible that you need to remove the -D_GLIBCXX_USE_CXX11_ABI=0 flag in g++ command in order to compile correctly.

To compile the operators in TF version >=1.4, you need to modify the compile scripts slightly.

First, find Tensorflow include and library paths.

    TF_INC=$(python -c 'import tensorflow as tf; print(tf.sysconfig.get_include())')
    TF_LIB=$(python -c 'import tensorflow as tf; print(tf.sysconfig.get_lib())')
Then, add flags of -I$TF_INC/external/nsync/public -L$TF_LIB -ltensorflow_framework to the g++ commands.

# O-CNN

## Introduction <a name="introduction"></a>

This repository contains the implementation of *O-CNN*  and  *Aadptive O-CNN* introduced in our SIGGRAPH 2017 paper and SIGGRAPH Asia 2018 paper.  The code is released under the MIT license.

We have released the TensorFlow-based implementation under the `tf` branch, and our future development will be focused on this implementation.
If you would like to have a try with the beta version, please pull the code and run the following command: `git checkout -b tf`.

* **[O-CNN: Octree-based Convolutional Neural Networks](https://wang-ps.github.io/O-CNN.html)**<br/>
By [Peng-Shuai Wang](https://wang-ps.github.io/), [Yang Liu](https://xueyuhanlang.github.io/), Yu-Xiao Guo, Chun-Yu Sun and [Xin Tong](https://www.microsoft.com/en-us/research/people/xtong/)<br/>
ACM Transactions on Graphics (SIGGRAPH), 36(4), 2017

* **[Adaptive O-CNN: A Patch-based Deep Representation of 3D Shapes](https://wang-ps.github.io/AO-CNN.html)**<br/>
By [Peng-Shuai Wang](https://wang-ps.github.io/), Chun-Yu Sun, [Yang Liu](https://xueyuhanlang.github.io/) and [Xin Tong](https://www.microsoft.com/en-us/research/people/xtong/)<br/>
ACM Transactions on Graphics (SIGGRAPH Asia), 37(6), 2018<br/>


- [`virtualscanner`](https://github.com/wang-ps/O-CNN/tree/master/virtual_scanner) - used to convert obj/off files to points files  
- [`octree`](#octree) - used to convert point files to octree files  <!-- - [`octree2ply`](#octree-2-ply) - used to convert octree files to ply files   -->
- [`convert_octree_data`](#convert-octree-data) - used to convert octree files to lmdb files  
- `caffe` - executable for training / evaluating models  
- `feature_pooling` - pools features and outputs them to an lmdb  

