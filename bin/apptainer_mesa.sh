#!/bin/bash

# Host-side variables
SIF_IMAGE="/project/f/fherwig/fherwig/Apptainers/nudome:14.0.sif"
MESA_SRC="/scratch/f/fherwig/fherwig/MESA/mesa-r7624"
SCRATCH_DIR="/scratch/f/fherwig/fherwig"
OMP_NUM_THREADS=8

# Container-side variables
CONTAINER_MESA_DIR="/home/user/mesa"
CONTAINER_MESASDK_ROOT="/home/user/mesasdk"

# Add echo statement explaining to user what is going to happen:
echo "Launching MESA in Apptainer:"
echo "  - MESA source directory: ${MESA_SRC}"
echo "  - MESA source directory in container: ${CONTAINER_MESA_DIR}"
echo "  - MESASDK root directory in container: ${CONTAINER_MESASDK_ROOT}"
echo "  - Apptainer image: ${SIF_IMAGE}"
echo ""
echo "Inside the container, the MESASDK will be sourced and the working directory"
echo "will be set to the MESA source directory in container."
echo "" 
echo "The scratch directory ${SCRATCH_DIR} will be mounted to the"
echo "same path inside the container."

# Launch container: bind MESA_SRC to CONTAINER_MESA_DIR,
# set container environment variables, source MESASDK, and cd to CONTAINER_MESA_DIR.
apptainer exec --no-home \
  --env MESA_DIR="${CONTAINER_MESA_DIR}",MESASDK_ROOT="${CONTAINER_MESASDK_ROOT}",LC_ALL=C,OMP_NUM_THREADS="${OMP_NUM_THREADS}" \
  -B "${MESA_SRC}:${CONTAINER_MESA_DIR}",${SCRATCH_DIR} \
  "${SIF_IMAGE}" \
  bash -c "source \$MESASDK_ROOT/bin/mesasdk_init.sh; cd \$MESA_DIR; exec bash"

