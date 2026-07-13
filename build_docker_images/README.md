# Build NuDocker Images

This directory contains the build system for creating various NuDocker images with different MESA SDK versions and additional packages.

## Files

| File | Description |
|------|-------------|
| `Dockerfile_template` | Base template for standard nudome images |
| `Dockerfile_template_mppnp` | Template for MPPNP images with HDF5, OpenMPI, and NuSE |
| `Dockerfile_template.20` | Template for nudome 20.x images |
| `makefile` | Build configuration with all available targets |
| `apt_packages_nudome.txt` | List of Ubuntu packages to install |

## Available Build Targets

### Standard NuDome Images
- **`nudome14`** - Ubuntu 12.04 + MESA SDK 20141212 (legacy, may not work)
- **`nudome16`** - Ubuntu 16.04 + MESA SDK 20160129
- **`nudome18`** - Ubuntu 18.04 + MESA SDK 20180822
- **`nudome20.031`** - Ubuntu 20.04 + MESA SDK 20.3.1
- **`nudome20.1`** - Ubuntu 20.04 + MESA SDK 21.4.1

### Specialized Images (MPPNP)
Two mppnp toolchain variants are built from the one multi-stage
`Dockerfile_template_mppnp`, selected by `--build-arg VARIANT=`:

- **`numppnp`** (master variant) → image `nugrid/nudome:mppnp` — Ubuntu 18.04 +
  gcc 7.3.0 + HDF5 1.8.20 + OpenMPI 3.0.1 + OpenBLAS 0.2.20 + NuSE (`/opt/se-1.2`).
  Matches nuppn branch `mppnp_hif_PPM-CONSOLIDATION`.
- **`numppnp_modular2`** (modular2 variant) → image `nugrid/nudome:mppnp-modular2` —
  Ubuntu 18.04 + gcc 12.4.0 + HDF5 1.8.3 + OpenMPI 4.1.6 + CMake 3.28 + apt
  OpenBLAS. Builds its own NuSE + SuperLU at nuppn-compile time. Matches nuppn
  branch `modular2_swj_compilation`.

### Template Target
- **`nudomexx`** - Template for creating new image combinations

## Usage

### Basic Build
```bash
# Build standard nudome image
make nudome18

# Build MPPNP image with additional packages
make numppnp
```

### Build the MPPNP images
```bash
make numppnp            # master variant  -> nugrid/nudome:mppnp
make numppnp_modular2   # modular2 variant -> nugrid/nudome:mppnp-modular2
```

### Force No-Cache Rebuild
```bash
# Force clean rebuild (ignores Docker cache)
make NOCACHE=1 nudome18
make NOCACHE=1 numppnp

# Alternative syntax
NOCACHE=1 make nudome18
```

### Creating New Image Variants
1. Start with the `nudomexx` target as a template
2. Modify the makefile variables for your specific needs
3. Create a new Dockerfile template if required
4. Add a new target to the makefile

## Image Details

### Standard Images
All standard images include:
- Ubuntu base system
- MESA SDK with specified version
- Basic development tools
- User setup with proper permissions

### MPPNP Images (`numppnp`, `numppnp_modular2`)
Both are built on Ubuntu 18.04 with a self-compiled scientific toolchain
installed under `/opt/`, plus Python + NuGridPy. They differ by variant:

| | `numppnp` (master) | `numppnp_modular2` (modular2) |
|---|---|---|
| Image tag        | `nugrid/nudome:mppnp` | `nugrid/nudome:mppnp-modular2` |
| gcc              | 7.3.0   | 12.4.0 |
| HDF5             | 1.8.20  | 1.8.3  |
| OpenMPI          | 3.0.1   | 4.1.6  |
| OpenBLAS         | 0.2.20 (from source) | apt `libopenblas-dev` |
| NuSE / SuperLU   | NuSE at `/opt/se-1.2` | built by nuppn at compile time (CMake 3.28) |
| nuppn branch     | `mppnp_hif_PPM-CONSOLIDATION` | `modular2_swj_compilation` |

See `../CLAUDE.md` for how each nuppn branch compiles and the gotchas
(serial make for master; `-fallow-argument-mismatch` for modular2's gfortran-12).

## Troubleshooting

### Permission Issues
If you encounter permission errors during build or runtime:
- Ensure you're in the docker group: `groups | grep docker`
- Use `NOCACHE=1` to force a clean rebuild

### Build Failures
- Use `NOCACHE=1` to bypass cached layers that might be corrupted
- Check that all required files are present in the build context
- Verify that download URLs in the Dockerfile are still accessible

## Examples

```bash
# Build all main images
make nudome16
make nudome18
make nudome20.031

# Build MPPNP for parallel computing
make numppnp

# Force rebuild after template changes
make NOCACHE=1 numppnp
```
