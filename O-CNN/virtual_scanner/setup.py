from skbuild import setup

setup(
    name="ocnn.virtualscanner",
    version="18.09.05",
    description="Virtual scanner utilities",
    author='Microsoft',
    author_email="dapisani@microsoft.com",
    packages=['ocnn', 'ocnn.virtualscanner'],
    zip_safe=False,
    install_requires=['Cython', 'pyyaml'],
    extra_compile_args=["-Wno-cpp", "-Wno-unused-function", "-O2", "-march=native", "-stdlib=libc++", "-std=c++11"],
    extra_link_args=["-O2", "-march=native", "-stdlib=libc++"],
    language="c++",
    package_dir={'': 'python'},
    package_data={'ocnn.virtualscanner': ['*.pxd']}
)
