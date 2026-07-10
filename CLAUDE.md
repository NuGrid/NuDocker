# CLAUDE.md — Building the MPPNP NuDocker image(s)

Guidance for building Docker images that can compile **mppnp** (from
`git@gitlab.ppmstar.org:NuGrid/nuppn.git`). Captures hard-won learnings so the
next person (or Claude session) does not rediscover them.

## Big picture

`build_docker_images/` builds NuGrid/NuDome images. The mppnp image adds a
self-compiled scientific toolchain (gcc, HDF5, OpenMPI, and for `master` also
OpenBLAS + NuSE) on top of an Ubuntu base, plus Python + NuGridPy.

The build is driven by `makefile`, which `sed`-substitutes a
`Dockerfile_template*` into `Dockerfile` and runs `docker build`.

## Two toolchain variants (one template, multi-stage)

`Dockerfile_template_mppnp` is a **multi-stage** build selected by
`--build-arg VARIANT=`:

| Stage / variant | gcc     | HDF5   | OpenMPI | OpenBLAS | NuSE | Matches nuppn branch                |
|-----------------|---------|--------|---------|----------|------|-------------------------------------|
| `master`  (def) | 7.3.0   | 1.8.20 | 3.0.1   | 0.2.20 (from src) | /opt/se-1.2 | `mppnp_hif_PPM-CONSOLIDATION` |
| `modular2`      | 12.4.0  | 1.8.3  | 4.1.6   | 0.3.27 (from src, gcc-12) | — (built by nuppn) | `modular2_swj_compilation`  |

Structure: `base` (apt + user) → `master` **or** `modular2` (toolchain) →
`FROM ${VARIANT} AS toolchain` (shared Python/NuGridPy/aliases finish). With
BuildKit (Docker ≥ 23, default here) only the selected variant stage is built.

### Build commands
```bash
cd build_docker_images

# master variant  → image nugrid/nudome:mppnp
make numppnp

# modular2 variant → image nugrid/nudome:mppnp-modular2
make numppnp_modular2

# force clean rebuild of any make target
make NOCACHE=1 numppnp
```
`numppnp` IS the master variant (VARIANT defaults to `master` in the template);
`numppnp_modular2` passes `--build-arg VARIANT=modular2`. The `nudome` recipe
forwards `VARIANT` only when a target sets it.
NOTE: building gcc from source is slow (tens of minutes each). Run in the
background and tail the log.

## The two nuppn branches compile VERY differently

The naming conventions changed between branches — do not assume symmetry.

### master branch `mppnp_hif_PPM-CONSOLIDATION`
- Code layout: `frames/mppnp/CODE/` (UPPERCASE), run dir `frames/mppnp/RUN_TEMPLATE/`.
- `Make.local` is **auto-provisioned**: `CODE/Makefile` (+ `MAKE_LOCAL_AUTO.mk`)
  copies `CODE/MAKE_LOCAL/Make.local.nudome_mppnp` → `CODE/Make.local` on first
  build (md5-marker tracked). Override with `MAKE_LOCAL_TEMPLATE=<name>`.
- Links the **image's** deps: `SEHOME=/opt/se-1.2`, `-lopenblas`, hdf5-1.8.20,
  and `MPIHOME`. Uses bundled `SuperLU_5.0` under `solver/NFR/CODE/`.
- Build (VERIFIED): inside container, `cd frames/mppnp/CODE && make` — **SERIAL,
  do NOT use -j**: the Makefile races on the Fortran module `array_sizes.mod`
  (`mppnp.o` compiled before its .mod dependency). Output binary is **`mppnp.exe`**.
  Confirmed ldd-clean against /opt/{se-1.2,openblas-0.2.20,openmpi-3.0.1,hdf5-1.8.20}.
- `Make.local.nudome_mppnp` had `MPIHOME = /opt/openmpi-3.0.0` vs the image's
  **3.0.1**. Corrected to 3.0.1, BUT note `MPIHOME` is only consumed by the
  ifort/Darwin ARCH files — the `Linux_x86_64_gfortran` ARCH used here takes
  `FC := mpif90` from `PATH`, so this value is informational and the mismatch was
  never actually blocking. SEHOME=/opt/se-1.2 and `-lopenblas` (via apt
  libopenblas-dev on the default link path) are the paths that matter.

### modular2 branch `modular2_swj_compilation`
- Code layout: `frames/mppnp/source/` (lowercase), run dir
  `frames/mppnp/run_template/` (lowercase).
- `Make.local` is **committed as a placeholder** at `source/Make.local` with only
  `PPN = /vast/home/swj/nuppn_2025`. **Must edit `PPN`** to the nuppn repo root
  inside the container. No ARCH file needed (compiler flags are inline in
  `source/Makefile`; the `ARCH/$(ARCH)/Makefile` include is optional `-include`).
- **gfortran>=10 needs `-fallow-argument-mismatch`.** The modular2 image uses
  gcc-12.4.0; gfortran-12 promotes MPI argument rank/type mismatches (the many
  `mpi_send`/`mpi_pack` calls in `mppnp.F90` that pass different-typed buffers
  through one interface) from warnings to **hard errors** → `mppnp.o` fails to
  compile. FIX (branch `modular2_swj_compilation-JOSH-INTEGRATING-MASTER`): the
  flag now lives in **`source/Makefile`**, version-guarded — it detects
  `$(FC) -dumpversion` and appends `-fallow-argument-mismatch -fallow-invalid-boz`
  to `OPT` only when gfortran major >= 10 (the flag does NOT exist on gfortran
  < 10, where it would be a hard "unrecognized option" error). So every gcc-12
  build of the branch gets it, older compilers are untouched, and the
  nudome_mppnp template no longer needs to seed FFLAGS.
- **Self-contained deps:** `source/Makefile` downloads + builds its OWN
  HDF5 1.8.3, NuSE/SE, and SuperLU into `$(PPN)/external/` at compile time. It
  does NOT use the image's `/opt/hdf5` or `/opt/se`. For BLAS it links `-lblas`,
  which the nudome_mppnp Make.local now points at the image's source-built
  `/opt/openblas-0.3.27` (gcc-12) instead of apt's (see dual-libgfortran fix
  below). So the modular2 image mainly needs the right compiler + MPI + a
  **new-enough cmake** + a **gcc-12 BLAS** + `wget`.
- **SuperLU needs cmake >= 3.12** but Ubuntu 18.04's apt cmake is 3.10.2 → the
  SuperLU cmake configure aborts ("CMake 3.12 or higher is required"). The
  modular2 stage installs a Kitware CMake 3.28 binary to `/opt/cmake` (first on
  PATH). apt `cmake` is now redundant for modular2 but harmless.
- **Submodules required:** `external/NuSE` (github NuGrid/NuSE) and
  `external/SuperLU` (github swjones/superlu) are git submodules the SE/SuperLU
  build rules `cd` into — an un-recursed clone leaves them empty and the build
  fails. `git submodule update --init external/NuSE external/SuperLU` (NuGridPy
  submodule not needed to compile). hdf5-1.8.3 is wget'd by the Makefile, not a
  submodule.
- Build: inside container, `cd frames/mppnp/run_template && make`. Output binary is
  **`mppnp.exe`**, copied into `run_template/`.
- **Dual libgfortran — FIXED (was a latent runtime hazard).** Originally
  `mppnp.exe` loaded `libgfortran.so.5` (our gcc-12.4.0 code) AND `libgfortran.so.4`
  (pulled transitively by apt `libopenblas.so.0`/`libblas.so.3`, built with 18.04's
  gfortran-7). FIX: the modular2 stage now **builds OpenBLAS 0.3.27 from source
  with gcc-12.4.0** (`DYNAMIC_ARCH=1` for CPU portability) into
  `/opt/openblas-0.3.27`, with `libblas.so*`/`liblapack.so*` symlinks so nuppn's
  hardcoded `-lblas` resolves there, and puts it first on `LD_LIBRARY_PATH`. The
  nudome_mppnp Make.local adds `LDFLAGS += -L/opt/openblas-0.3.27/lib
  -Wl,-rpath=…` so the link picks ours over apt's. Result: `mppnp.exe` loads a
  SINGLE libgfortran (`.so.5`), verified by ldd. NOTE: apt `libopenblas-dev` is
  still in `apt_packages_nudome.txt` (shared with master, which links it) but is
  now unused by modular2. master needs no such fix — its whole toolchain is
  gcc-7.3.0 → one `.so.4` already.
- **The two mppnp images are fully separate.** `FROM ${VARIANT} AS toolchain`
  means each published image contains ONLY its variant's `/opt` toolchain
  (`docker run … ls /opt`): master has gcc-7.3.0/hdf5-1.8.20/openmpi-3.0.1/
  openblas-0.2.20/se-1.2; modular2 has gcc-12.4.0/hdf5-1.8.3/openmpi-4.1.6/cmake/
  openblas-0.3.27. No cross-contamination — a user pulls one tag and gets only
  that toolchain.

## Known image gaps / gotchas (fix these)

1. **`cmake` missing from `apt_packages_nudome.txt`.** modular2's SuperLU is a
   cmake build → it will fail without cmake. FIXED: added `cmake` (harmless for
   master) on branch `nuppn-dev`.
2. **`dot.bash_aliases` hardcodes the master toolchain** (`/opt/gcc-7.3.0`,
   `/opt/openmpi-3.0.1` in PATH/LD_LIBRARY_PATH). It is shared by BOTH variants
   via the `toolchain` stage, so a **modular2** container would get nonexistent
   paths and silently fall back to apt's gcc-7 / mpif90 — NOT gcc-12.4.0. FIX
   (on `nuppn-dev`): each variant stage now sets its own `ENV PATH` /
   `ENV LD_LIBRARY_PATH` (which the shared `toolchain` stage inherits), and
   `dot.bash_aliases` is being made variant-neutral so it no longer overrides
   them. It also blindly `source`d the (now-removed) mesasdk init — guard that.
   **Placement matters:** these ENV lines must come RIGHT AFTER the gcc install
   (before hdf5/openmpi), see gotcha #5.
3. **`mesasdk` install was removed** from `Dockerfile_template_mppnp` (still
   present in the older single-stage `Dockerfile`/`.bak`). Fine for mppnp (it
   uses the self-built gcc toolchain, not mesasdk) but note the makefile still
   substitutes `yyyymmdd`/`zzzzzzz` placeholders that no longer exist in the
   template (harmless no-op seds).
4. **Two OpenMPI installs coexist**: apt `openmpi-bin` (`/usr/bin/mpif90`) and the
   source-built `/opt/openmpi-*`. Whichever is first on `PATH` wins — keep the
   /opt one first for master; ensure the correct one for modular2.
5. **modular2 OpenMPI built empty — `ENV LD_LIBRARY_PATH` was set too late.**
   OpenMPI's `./configure` runs a Fortran test *executable*; gcc-12.4.0 links it
   against `libgfortran.so.5`, which is NOT on the system linker path (the base
   only has apt gfortran-7's `.so.4`). When the `ENV LD_LIBRARY_PATH` (with
   `/opt/gcc-*/lib64`) was placed AFTER the openmpi step, configure failed with
   "Could not run a simple Fortran program", and because the RUN chain ended in
   `rm -rf openmpi*` (exit 0) the failure was **silently masked** — the image
   built fine but had no `/opt/openmpi-4.1.6`, leaving apt's openmpi-2.1.1 as the
   only MPI. master escaped this only because gcc-7.3.0's `libgfortran.so.4`
   matches the system's. FIX (on `nuppn-dev`): moved the toolchain ENV to right
   after the gcc install in BOTH stages, joined openmpi `./configure && make all
   install`, and added `RUN test -x /opt/openmpi-*/bin/mpif90` as a fail-loud
   guard. Lesson: when a self-built gcc's runtime libs aren't on the default
   path, set `LD_LIBRARY_PATH` before anything that *runs* compiled test programs,
   and never end a build RUN with a command (like `rm`) that can't fail.

## Running a container to compile (pattern)

`bin/start_and_login.sh` mounts a host dir at `/home/user/mesa` and optionally
`-m <dir>` at `/home/user/mnt`. To compile nuppn, mount the nuppn clone into the
container, ensure the env, edit `Make.local`, and `make`. Clone on the host (it
has the gitlab SSH key) and mount it in, avoiding SSH keys in the image.

Gotchas learned while compiling (apply to both variants):
- **uid mismatch:** container `user` is uid 1000; the host user here is 33043.
  A bind-mounted clone owned by 33043 is unwritable by uid 1000, so the build
  (and Make.local auto-provision) fails with "Permission denied". Run the
  container as the host uid: `docker run --user $(id -u):$(id -g) -e HOME=/tmp …`
  (that uid has no /home entry in the image, hence `HOME=/tmp`). Interactive
  human use via `start_and_login.sh` doesn't hit this (real user in the image).
- **non-interactive shells don't source `.bash_aliases`**, and (for images built
  before the ENV fix) that's the only place PATH is set. With the per-stage `ENV`
  fix this is moot, but when in doubt export PATH/LD_LIBRARY_PATH explicitly.
- **build serially** for the master branch (`array_sizes.mod` -j race).

## Status / verification log

See `CHECKLIST.md` for the live task checklist and what has been verified vs.
still pending.
