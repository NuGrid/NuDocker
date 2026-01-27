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

### Specialized Images
- **`numppnp`** - Based on nudome18 + HDF5 1.8.3 + OpenMPI 3.0.0 + NuSE 1.2

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

### MPPNP Image (`numppnp`)
The MPPNP image includes everything from `nudome18` plus:
- **HDF5 1.8.3** - Hierarchical Data Format library
- **OpenMPI 3.0.0** - Message Passing Interface for parallel computing  
- **NuSE 1.2** - NuGrid Stellar Evolution package

All packages are installed in `/opt/` for easy access.

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
