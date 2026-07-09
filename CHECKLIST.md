# MPPNP Docker build & compile — CHECKLIST

Live checklist for building the mppnp NuDocker images and compiling both nuppn
branches. See `CLAUDE.md` for the durable "how/why". Updated as work proceeds.

Legend: `[x]` done/verified · `[~]` in progress · `[ ]` pending · `[!]` needs fix

---
## ⏩ RESUME HERE (state as of 2026-07-09, mid-session)
- **master: DONE & VERIFIED.** Image `nugrid/nudome:mppnp` built; nuppn branch
  `mppnp_hif_PPM-CONSOLIDATION` compiles → `mppnp.exe` (ldd-clean).
- **modular2: image build was RUNNING in the background** (`make numppnp_modular2`,
  gcc-12.4.0 from source). To check when you return:
  - `docker images nugrid/nudome:mppnp-modular2`  (exists → build finished)
  - build log: `scratchpad/build_modular2.log` (may be gone if scratchpad cleared;
    the image persists regardless). Re-run with `cd build_docker_images && make numppnp_modular2` if needed.
- **modular2 compile is fully staged** on host clone
  `/hpod2/home/fherwig/Docker/nuppn_builds/nuppn_modular2`: submodules NuSE+SuperLU
  initialized, `source/Make.local` PPN set to `/home/user/nuppn`.
  Once the image exists, run the compile (mirrors the verified master recipe):
  ```bash
  docker run --rm --user $(id -u):$(id -g) -e HOME=/tmp \
    -v /hpod2/home/fherwig/Docker/nuppn_builds/nuppn_modular2:/home/user/nuppn \
    nugrid/nudome:mppnp-modular2 bash -c \
    'cd /home/user/nuppn/frames/mppnp/run_template && make'
  ```
  (image sets gcc-12.4.0/openmpi-4.1.6 via per-stage ENV; build is self-contained:
  wgets hdf5-1.8.3, builds NuSE + SuperLU via cmake, then mppnp. Expect ~10-15 min.)
- Host nuppn clones (throwaway, persist on disk): `../nuppn_builds/nuppn_{master,modular2}`.
- Remaining after modular2 verifies: section 5 (makefile already has both targets)
  and section 6 (README + push `morhc/nudome:{master,modular2}` — confirm before push).
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
- [!] Add `cmake` to `apt_packages_nudome.txt` (needed by modular2 SuperLU).
- [!] Fix `dot.bash_aliases` toolchain paths for modular2 (gcc-12.4.0 / openmpi-4.1.6),
      or set env at compile time.
- [ ] `sed -e s/mm.nn/18.04/ Dockerfile_template_mppnp > Dockerfile`
- [ ] `docker build --build-arg VARIANT=modular2 -t nugrid/nudome:mppnp-modular2 .`
- [ ] Verify `/opt/{gcc-12.4.0,hdf5-1.8.3,openmpi-4.1.6}` present.

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
- [ ] Compile (image has correct gcc-12.4.0 / openmpi-4.1.6 via per-stage ENV now).
      Use `--user $(id -u):$(id -g) -e HOME=/tmp` for the mount, as with master.
- [ ] `cd frames/mppnp/run_template && make` → downloads+builds hdf5-1.8.3, builds
      NuSE + SuperLU (cmake) into `external/*/build`, then physics/solver/utils, mppnp.
- [ ] Produces `mppnp.exe`; verify ldd.

## 5. Capture
- [x] `CLAUDE.md` (durable learnings) written.
- [~] `CHECKLIST.md` (this file) — keep updating with results.
- [ ] Once both compile, add makefile `numppnp_master` / `numppnp_modular2` targets
      and fold fixes (cmake, aliases, MPIHOME) back into the repo.

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
- Keep Ubuntu 18.04 base for modular2, or move to a newer base?
- Should the image ship the fixes (cmake, variant-aware aliases) or do you want
  them staged for review first?
