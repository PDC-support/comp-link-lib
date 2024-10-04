---
marp: true
style: |
  section h1 {
    text-align: center;
    }
  .column {
    float: left;
    width: 50%;
    outline: 20px solid #FFF;
    border: 20px solid #AAF;
    background-color: #AAF;
    }
  .row:after {
    display: table;
    clear: both;
    }
  .columns {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
  .columns-left {
    background: none;
  }
  .columns-right {
    background: none;
  }
---

<!-- paginate: true -->

# Compilers/Linkers/Libraries

## Johan Hellsvik



---

# Contents

- Concepts: compilers, linkers, libraries
- Building a Fortran library and a Fortran program with
  - static linking
  - dynamic dynamic linking
- Building and running code on large clusters
- Building a C program with dynamical libraries
  - with linking to a CPE provided library
  - to a user/staff installed optional library

---

# Concepts: compilers, linkers, libraries

---

# Hello world in C and in Fortran

---

# The GCC compiler suite

---

# GCC intermediate steps

---

## Building a Fortran program with multiple source code files

---

# Compiling and linking via object files

```
gfortran -c parameters.f90
gfortran parameters.o crossproduct.f90 mathdemo.f90 -o mathdemo.x
```
```
gfortran parameters.f90 crossproduct.f90 mathdemo.f90 -o mathdemo.x
```

---

# Building with static linking to library

Compile the source code files parameters.f90 and crossproduct.f90.
Create a library with the command ar

```
gfortran -c parameters.f90 crossproduct.f90
ar r libcrossproduct.a parameters.o
```

View contents of the library

```
ar t libcrossproduct.a parameters.o
parameters.o
crossproduct.o
```
Build program mathdemo with static linking to the library

```
gfortran mathdemo.f90 libcrossproduct.a -o mathdemo.x
```

---

# Building with dynamic linking to library

Compile the source code files parameters.f90 and crossproduct.f90. Specify position independent code with `-fpic`. Create a library with the flag `-shared`

```
gfortran -fpic -c parameters.f90 crossproduct.f90
gfortran -shared -o libcrossproduct.so parameters.o crossproduct.o
```

Compile mathdemo.f90
```
gfortran -c mathdemo.f90
```

Link mathdemo.o to libcrossproduct.so

```
gfortran mathdemo.o -o mathdemo.x  -L`pwd` -lcrossproduct
```


---

# Building and running code on large clusters

- With a large pool of users comes large number of programs and libraries. This needs to be managed to avoid interference
- A common solution is to use so called module systems to selectively activate/deactive the programs and libraries that are of relevance.
- Programs and libraries are typically built and installed with regular user privilegies. Use root rights only when really needed.
- Updates of libraries need to be made with caution as they potentially can break the functionality of large number of programs

---
# Cray programming environment (CPE)

The CPE is used on the Dardel HPE Cray EX supercomputer

Reference page: [Compilers and libraries](https://www.pdc.kth.se/support/documents/software_development/development.html)

The Cray Programming Environment (CPE) provides consistent interface to multiple compilers and libraries.

* In practice, we recommend
    - ``ml cpeCray/23.12``
    - ``ml cpeGNU/23.12``
    - ``ml cpeAOCC/23.12``

* The ``cpeCray``, ``cpeGNU`` and ``cpeAOCC`` modules are available after ``ml PDC/23.12``

* No need to ``module swap`` or ``module unload``

---

# Compiler wrappers

* Compiler wrappers for different programming languages
    - ``cc``: C compiler wrapper
    - ``CC``: C++ compiler wrapper
    - ``ftn``: Fortran compiler wrapper

* The wrappers choose the required compiler version and target architecture optinons.

* Automatically link to MPI library and math libraries
    - MPI library: ``cray-mpich``
    - Math libraries: ``cray-libsci`` and ``cray-fftw``

---

# Compile a simple MPI code

* ``hello_world_mpi.f90``
  ```
  program hello_world_mpi
  include "mpif.h"
  integer myrank,mysize,ierr
  call MPI_Init(ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD,myrank,ierr)
  call MPI_Comm_size(MPI_COMM_WORLD,mysize,ierr)
  write(*,*) "Processor ",myrank," of ",mysize,": Hello World!"
  call MPI_Finalize(ierr)
  end program
  ```

  ```
  ftn hello_world_mpi.f90 -o hello_world_mpi.x
  ```

---

# What flags does the ``ftn`` wrapper activate?

* Use the flag ``-craype-verbose``

  ```
  ftn -craype-verbose hello_world_mpi.f90 -o hello_world_mpi.x
  ```

---

# Test run the hellow world MPI code

- Run on eight cores in the ``shared`` partition

```
user@uan01:> salloc -n 8 -t 10 -p shared -A <name-of-allocation>
user@uan01:> srun -n 8 ./hello_world_mpi.x
 Processor            4  of            8 : Hello World!
 Processor            6  of            8 : Hello World!
 Processor            7  of            8 : Hello World!
 Processor            0  of            8 : Hello World!
 Processor            1  of            8 : Hello World!
 Processor            2  of            8 : Hello World!
 Processor            3  of            8 : Hello World!
 Processor            5  of            8 : Hello World!
```

---

# Compile a simple linear algebra code

[Link to the code](https://github.com/PDC-support/pdc-intro/blob/master/COMPILE_exercises/dgemm_test.c)

Use cray-libsci

```
ml PDC/23.12 cpeGNU/23.12
```

```
cc dgemm_test.c -o dgemm_test_craylibsci.x
```

---

# Compile a simple linear algebra code

Use openblas

```
ml PDC/23.12 openblas/0.3.28-cpeGNU-23.12
```

```
cc dgemm_test.c -o dgemm_test_openblas.x -I$EBROOTOPENBLAS/include -L$EBROOTOPENBLAS/lib -lopenblas
```
where the environment variable `EBROOTOPENBLAS` had been set when loading the OpenBLAS module. Its module file includes a statement
```
setenv("EBROOTOPENBLAS","/pdc/software/23.12/eb/software/openblas/0.3.28-cpeGNU-23.12")
```
which corresponds to an export statement
```
export EBROOTOPENBLAS=/pdc/software/23.12/eb/software/openblas/0.3.28-cpeGNU-23.12
```

---

# Check the linked libraries

```
ldd dgemm_test_craylibsci.x
```

```
ldd dgemm_test_openblas.x
```

---

# Check the linked libraries

```
ldd dgemm_test_craylibsci.x

...
libsci_cray.so.6 => /opt/cray/pe/lib64/libsci_cray.so.6
...
```

```
ldd dgemm_test_openblas.x

...
libopenblas.so.0 => /pdc/software/23.12/eb/software/openblas/0.3.28-cpeGNU-23.12/lib/libopenblas.so.0
...
```

---

# Test run the dgemm_test code

* Run on a single core in the ``shared`` partition
  ```
  salloc -n 1 -t 10 -p shared -A <name-of-allocation>
  srun -n 1 ./dgemm_test_craylibsci.x
  srun -n 1 ./dgemm_test_openblas.x
  exit
  ```

* Expected output:
  ```
      2.700     4.500     6.300     8.100     9.900    11.700    13.500
      4.500     8.100    11.700    15.300    18.900    22.500    26.100
      6.300    11.700    17.100    22.500    27.900    33.300    38.700
  ```

---

# Exercise: Compile and run ``fftw_test`` code

```
ml cray-fftw/3.3.10.6

wget https://people.math.sc.edu/Burkardt/c_src/fftw/fftw_test.c

cc --version
cc fftw_test.c -o fftw_test.x

ldd fftw_test.x

salloc -n 1 -t 10 -p shared -A <name-of-allocation>
srun -n 1 ./fftw_test.x
```

---

# Compilation of large program

* Examples at https://www.pdc.kth.se/software

---

# Environment variables for manual installation of software

* Environment variables for compilers
  ```
  export CC=cc
  export CXX=CC
  export FC=ftn
  export F77=ftn
  ```

* Environment variables for compiler flags
    - add ``-I``, ``-L``, ``-l``, etc. to Makefile

* Environment variables at runtime
    - prepend to ``PATH``, ``LD_LIBRARY_PATH``, etc.

---

# What happens when loading a module

```
ml show elpa/2023.05.001-cpeGNU-23.12
```

```
whatis("Description: ELPA - Eigenvalue SoLvers for Petaflop-Applications")
prepend_path("CMAKE_PREFIX_PATH","/pdc/software/23.12/eb/software/elpa/2023.05.001-cpeGNU-23.12")
prepend_path("LD_LIBRARY_PATH","/pdc/software/23.12/eb/software/elpa/2023.05.001-cpeGNU-23.12/lib")
prepend_path("LIBRARY_PATH","/pdc/software/23.12/eb/software/elpa/2023.05.001-cpeGNU-23.12/lib")
prepend_path("PATH","/pdc/software/23.12/eb/software/elpa/2023.05.001-cpeGNU-23.12/bin")
prepend_path("PKG_CONFIG_PATH","/pdc/software/23.12/eb/software/elpa/2023.05.001-cpeGNU-23.12/lib/pkgconfig")
...
```

---

# When running your own code

* Load correct programming environment (e.g. ``cpeGNU``)
* Load correct dependencies (e.g. ``openblas`` if your code depends on it)
* Properly prepend to environment variables (e.g. ``PATH``, ``LD_LIBRARY_PATH``)
* Choose correct SLURM settings

---

# References

- [Fortran-lang.org Fortran quickstart tutorial](https://fortran-lang.org/learn/quickstart/)

- https://opensource.com/article/22/5/dynamic-linking-modular-libraries-linux

- https://opensource.com/article/22/6/static-linking-linux

- https://opensource.com/article/20/6/linux-libraries

- [Compiling and running code on CPU nodes](https://pdc-support.github.io/pdc-intro/?f=8#64), in [PDC intro presentation](https://pdc-support.github.io/pdc-intro/)
