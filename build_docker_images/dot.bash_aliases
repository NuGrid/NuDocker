# mesa (mesasdk is not installed in the mppnp image; guard the source so an
# interactive login shell doesn't error. Harmless for images that do ship it.)
export MESA_DIR=~/mesa
export MESASDK_ROOT=~/mesasdk
[ -f "$MESASDK_ROOT/bin/mesasdk_init.sh" ] && source "$MESASDK_ROOT/bin/mesasdk_init.sh"
export OMP_NUM_THREADS=4

# mppnp: the toolchain PATH / LD_LIBRARY_PATH are set per-variant via Docker ENV
# in Dockerfile_template_mppnp (master vs modular2). Setting them there (not here)
# means they are correct for BOTH variants and are also available to
# non-interactive shells/scripts. Do not hardcode a single variant's paths here.

# user
alias ed='emacs -nw'
alias python='python3'
