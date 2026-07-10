# MPPNP Docker build & compile — CHECKLIST

Live checklist for building the mppnp NuDocker images and compiling both nuppn
branches. See `CLAUDE.md` for the durable "how/why". Updated as work proceeds.

Legend: `[x]` done/verified · `[~]` in progress · `[ ]` pending · `[!]` needs fix

---
## ⏩ RESUME HERE (state as of 2026-07-10)
- **master: DONE & VERIFIED.** Image `nugrid/nudome:mppnp` built; nuppn branch
  `mppnp_hif_PPM-CONSOLIDATION` compiles → `mppnp.exe` (ldd-clean, all libgfortran.so.4).
- **modular2: DONE & VERIFIED.** Image `nugrid/nudome:mppnp-modular2` rebuilt with
  two fixes (openmpi ENV placement, cmake 3.28); nuppn branch
  `modular2_swj_compilation` compiles → `mppnp.exe` after adding
  `FFLAGS := -fallow-argument-mismatch -fallow-invalid-boz` to `source/Make.local`.
  ldd resolves; one caveat = dual libgfortran (.so.5 + apt-openblas's .so.4) — see §4.
  Recipe (verified):
  ```bash
  docker run --rm --user $(id -u):$(id -g) -e HOME=/tmp \
    -v /hpod2/home/fherwig/Docker/nuppn_builds/nuppn_modular2:/home/user/nuppn \
    nugrid/nudome:mppnp-modular2 bash -c \
    'cd /home/user/nuppn/frames/mppnp/run_template && make'
  ```
- Host nuppn clones (throwaway, persist on disk): `../nuppn_builds/nuppn_{master,modular2}`.
- **REMAINING: section 6 (Release)** — update local README.md for both variants and
  push `morhc/nudome:{master,modular2}` (confirm with Falk before pushing).
  Also commit the latest template/doc fixes to `nuppn-dev`.
---

## 0. Prep
- [x] Confirm Docker works, disk headroom (`/mnt/docker`, 269 GB free), 8 cores.
- [x] Confirm gitlab SSH access on host (`ssh -T git@gitlab.ppmstar.org` → `@Morhc`).
- [x] git pull — `mppnp-master` is a **local-only** branch (remote has only
      `master`, `template_14`); nothing to pull, local work intact.
- [x] Broad permission allowlist added to `.claude/settings.local.json`.

## 1. Build image: master variant  (nugrid/nudome:mppnp)
- [~] `cd build_docker_images && make numppnp`  (gcc 7.3.0 build in progress)
- [ ] Image builds clean through all stages (gcc/openblas/hdf5/openmpi/NuSE/py/NuGridPy).
- [ ] Verify `/opt/{gcc-7.3.0,hdf5-1.8.20,openmpi-3.0.1,openblas-0.2.20,se-1.2}` present.

## 2. Build image: modular2 variant  (nugrid/nudome:mppnp-modular2)
- [x] Add `cmake` to `apt_packages_nudome.txt` (needed by modular2 SuperLU).
- [x] Fix `dot.bash_aliases` toolchain paths for modular2 (gcc-12.4.0 / openmpi-4.1.6):
      done via per-stage Docker ENV, aliases made variant-neutral.
- [!] **BUG FOUND & FIXED (2026-07-09): first modular2 image had NO /opt/openmpi-4.1.6.**
      OpenMPI `./configure` failed its Fortran test ("Could not run a simple Fortran
      program") because gcc-12.4.0's `libgfortran.so.5` is not on the system linker
      path and the `ENV LD_LIBRARY_PATH` was set only AFTER the openmpi step. The RUN
      chain ended in `rm -rf openmpi*` (exit 0), so the failure was silently masked and
      the image built "successfully" with apt's openmpi-2.1.1 as the only MPI.
      (master dodged it: gcc-7.3.0 `libgfortran.so.4` matches the system apt gfortran-7.)
      FIX in `Dockerfile_template_mppnp`: moved the toolchain `ENV PATH`/`LD_LIBRARY_PATH`
      to right AFTER the gcc install (before hdf5/openmpi) in BOTH stages, joined the
      openmpi configure+make with `&&`, and added `RUN test -x .../bin/mpif90` to fail
      loudly if openmpi is ever missing again.
- [x] Rebuilt `make numppnp_modular2`; verified `/opt/openmpi-4.1.6` + mpif90 → Open MPI 4.1.6.
- [!] **BUG #2 (2026-07-09): apt cmake 3.10.2 too old for SuperLU (needs >= 3.12).**
      modular2 compile got all the way through hdf5/NuSE/physics, then SuperLU's
      cmake configure died: "CMake 3.12 or higher is required. You are running 3.10.2"
      (Ubuntu 18.04 apt cmake). FIX in `Dockerfile_template_mppnp`: install Kitware
      CMake ${CMAKE_VERSION:=3.28.3} binary to `/opt/cmake` at the END of the modular2
      stage (keeps hdf5/openmpi cache) and prepend `/opt/cmake/bin` to PATH. Rebuild
      only added the cheap cmake layers (hdf5/openmpi cached).
- [ ] Re-verify image, then re-run the modular2 compile.

## 3. Compile mppnp — master branch (mppnp_hif_PPM-CONSOLIDATION)  ✅ VERIFIED
- [x] Clone (host): `nuppn_builds/nuppn_master` (shallow, single branch).
- [x] Confirm layout: `frames/mppnp/CODE/`, run dir `frames/mppnp/RUN_TEMPLATE/`.
- [x] Confirm Make.local auto-selects `MAKE_LOCAL/Make.local.nudome_mppnp`.
- [x] Fixed `Make.local.nudome_mppnp` `MPIHOME` 3.0.0→3.0.1 (dead value for gfortran ARCH, but corrected).
- [x] Run container with nuppn mounted. **uid caveat:** host uid 33043 ≠ container
      uid 1000, so mount is unwritable → run with `--user $(id -u):$(id -g) -e HOME=/tmp`.
- [x] `cd frames/mppnp/CODE && make` (**SERIAL — no -j**; Makefile races on
      `array_sizes.mod` under -j) → builds physics/phys08, solver/NFR, SuperLU_5.0, mppnp.
- [x] Produces **`mppnp.exe`** (NOT `mppnp`); ELF verified, ldd resolves to
      /opt/{se-1.2,openblas-0.2.20,openmpi-3.0.1,hdf5-1.8.20}, no missing libs.
- Compile env (explicit, since non-interactive shells don't source .bash_aliases):
  `PATH=/opt/gcc-7.3.0/bin:/opt/openmpi-3.0.1/bin:$PATH` and matching LD_LIBRARY_PATH.

## 4. Compile mppnp — modular2 branch (modular2_swj_compilation)
- [x] Clone (host): `nuppn_builds/nuppn_modular2` (shallow, single branch).
- [x] Confirm layout: `frames/mppnp/source/`, run dir `frames/mppnp/run_template/`.
- [x] **Init submodules** (I cloned without --recurse-submodules): `external/NuSE`
      (github NuGrid/NuSE, https) and `external/SuperLU` (github swjones/superlu, ssh).
      These are `cd`-ed into by the SE/SuperLU build rules; empty = build fails.
      `git submodule update --init external/NuSE external/SuperLU`. (NuGridPy submodule
      not needed for the compile.)
- [x] Edit `source/Make.local`: `PPN=/vast/home/swj/nuppn_2025` → `/home/user/nuppn`.
- [x] Compile (image has correct gcc-12.4.0 / openmpi-4.1.6 via per-stage ENV, and
      /opt/cmake 3.28). Use `--user $(id -u):$(id -g) -e HOME=/tmp` for the mount.
- [x] Edit `source/Make.local`: add `FFLAGS := -fallow-argument-mismatch -fallow-invalid-boz`.
      gfortran-12 promotes MPI arg rank/type mismatches (mpi_send/mpi_pack in
      mppnp.F90) to hard errors; this flag makes them warnings so the legacy MPI
      Fortran compiles. (Make.local is -include'd at the top of source/Makefile and
      FFLAGS is only appended to, so seeding it there flows through the whole build.)
- [x] `cd frames/mppnp/run_template && make` → downloads+builds hdf5-1.8.3, builds
      NuSE + SuperLU (cmake 3.28) into `external/*/build`, then physics/solver/utils, mppnp.
- [x] Produces **`mppnp.exe`** (ELF, exit 0), copied into run_template/. ldd fully
      resolves: /opt/{openmpi-4.1.6,hdf5-1.8.3,gcc-12.4.0/libgfortran.so.5},
      NuSE+SuperLU from the nuppn tree.
- [!] **CAVEAT — dual libgfortran.** mppnp.exe loads BOTH `libgfortran.so.5`
      (our gcc-12.4.0 code) and `libgfortran.so.4` (pulled transitively by apt
      `libopenblas.so.0` / `libblas.so.3`, which were built with Ubuntu-18.04's
      gfortran-7). It links & resolves, but two libgfortran runtimes in one process
      is a latent hazard. CLEAN FIX if it ever misbehaves at runtime: build OpenBLAS
      from source with gcc-12.4.0 in the modular2 stage (as the master stage already
      does), or move modular2 to a newer Ubuntu base whose apt BLAS uses gfortran-12.
      Left as-is for now since the compile succeeds — see Open questions.

## 5. Capture
- [x] `CLAUDE.md` (durable learnings) written + updated with modular2 openmpi/cmake/fflags findings.
- [x] `CHECKLIST.md` (this file) — updated through both compiles.
- [x] makefile has `numppnp` (master) + `numppnp_modular2` targets; fixes folded into
      the template on `nuppn-dev` (cmake apt+/opt, per-stage ENV, variant-neutral aliases).
- [ ] Commit the latest round of fixes (openmpi ENV move, /opt/cmake, fail-loud guards)
      to `nuppn-dev`.

## 6. Release (only once both variants build AND compile cleanly)
- [ ] Update local `README.md`: document that BOTH `master` and `modular2` mppnp
      images are available (build commands, toolchain versions, which nuppn branch
      each matches).
- [ ] Push two images to `morhc/nudome` on Docker Hub:
      - `morhc/nudome:master`   (master variant, image built by `make numppnp`)
      - `morhc/nudome:modular2` (modular2 variant, `make numppnp_modular2`)
      i.e. `docker tag ... morhc/nudome:master` / `:modular2` then `docker push`.
      (Outward-facing publish — confirm with Falk before pushing.)

## Open questions for Falk
- Was removing the `mesasdk` install from the mppnp template intentional? (mppnp
  doesn't need it; just confirming.)
- **modular2 dual-libgfortran:** keep Ubuntu 18.04 + apt libopenblas (→ libgfortran.so.4
  alongside our gcc-12 libgfortran.so.5), or build OpenBLAS from source in the
  modular2 stage / move to a newer base to get a single, matching libgfortran?
  (Compile & link succeed today; this is about runtime cleanliness.)
- The `FFLAGS := -fallow-argument-mismatch -fallow-invalid-boz` for modular2 lives in
  the host clone's `source/Make.local` (not committed to nuppn). Should this go
  upstream into the `modular2_swj_compilation` branch's Make.local sample so anyone
  on gfortran>=10 gets it, or stay a local edit?
- Should the image ship the fixes (cmake, variant-aware aliases) or do you want
  them staged for review first?
