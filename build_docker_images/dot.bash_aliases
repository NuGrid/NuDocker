# mesa
export MESA_DIR=~/mesa
export MESASDK_ROOT=~/mesasdk
source $MESASDK_ROOT/bin/mesasdk_init.sh
export OMP_NUM_THREADS=4

# mppnp
#export PATH=$PATH:/opt/openmpi-3.0.0/bin
export PATH=/opt/gcc-7.3.0/bin:/opt/openmpi-3.0.1/bin:$PATH
export LD_LIBRARY_PATH=/opt/gcc-7.3.0/lib64:/opt/openblas-0.2.20/lib:/opt/hdf5-1.8.20/lib:/opt/openmpi-3.0.1/lib:$LD_LIBRARY_PATH

# user
alias ed='emacs -nw'
alias python='python3'
