# Headwind Build System

This document describes the comprehensive build system for Headwind, including cross-compilation, release optimizations, and distribution builds.

## Quick Start

```bash
# Development build (current platform, debug mode)
zig build

# Run the CLI
zig build run -- build -i input.html -o output.css

# Run tests
zig build test

# Release build (optimized for speed)
zig build release

# Release build (optimized for size)
zig build release-small
```

## Build Targets

### Development Builds

- **`zig build`** - Default debug build for current platform
- **`zig build run`** - Build and run the CLI with arguments
- **`zig build test`** - Run all unit tests
- **`zig build bench`** - Run benchmarks
- **`zig build fmt`** - Check code formatting

### Release Builds

- **`zig build release`** - Optimized release build for current platform (ReleaseFast)
  - Strips debug symbols
  - Optimized for maximum performance
  - ~643KB binary size on macOS ARM64

- **`zig build release-small`** - Size-optimized release build (ReleaseSmall)
  - Strips debug symbols
  - Optimized for minimal binary size
  - ~400KB binary size on macOS ARM64
  - Good for constrained environments

### Cross-Compilation

Build for specific platforms:

```bash
# Linux builds (statically linked)
zig build build-linux-x86_64      # Linux x86_64 (Intel/AMD 64-bit)
zig build build-linux-aarch64     # Linux ARM64 (e.g., Raspberry Pi, AWS Graviton)

# macOS builds (dynamically linked)
zig build build-macos-x86_64      # macOS Intel (older Macs)
zig build build-macos-arm64       # macOS Apple Silicon (M1/M2/M3)

# Windows builds
zig build build-windows-x86_64    # Windows 64-bit (fully working!)
```

All cross-compiled binaries are placed in `zig-out/dist/<platform-name>/`.

### Build All Platforms

```bash
# Build for all supported platforms at once
zig build build-all

# Alias for build-all
zig build cross
```

This creates release binaries for:
- Linux x86_64 (statically linked)
- Linux aarch64 (statically linked)
- macOS x86_64 (dynamically linked)
- macOS ARM64 (dynamically linked)
- Windows x86_64 (statically linked)

## Build Configuration

### Optimization Levels

The build system supports all Zig optimization modes:

- **Debug** (default) - No optimizations, full debug info
- **ReleaseSafe** - Optimized with safety checks
- **ReleaseFast** - Maximum performance, used for release builds
- **ReleaseSmall** - Minimum binary size

### Static vs Dynamic Linking

- **Linux**: Always statically linked for maximum portability
- **macOS**: Dynamically linked (static libc not supported on macOS)
- **Windows**: Statically linked (when working)

### Debug Symbol Stripping

All release and cross-compilation builds automatically strip debug symbols to reduce binary size.

## Build Artifacts

### Directory Structure

```
zig-out/
├── bin/                    # Default build output
│   └── headwind           # Main executable
└── dist/                  # Cross-compilation output
    ├── linux-x86_64/
    │   └── headwind       # Linux x86_64 binary (static)
    ├── linux-aarch64/
    │   └── headwind       # Linux ARM64 binary (static)
    ├── macos-x86_64/
    │   └── headwind       # macOS Intel binary
    ├── macos-arm64/
    │   └── headwind       # macOS Apple Silicon binary
    └── windows-x86_64/
        └── headwind.exe   # Windows binary (static)
```

### Binary Sizes

Approximate sizes for optimized builds (may vary):

| Platform | ReleaseFast | ReleaseSmall |
|----------|-------------|--------------|
| macOS ARM64 | ~643KB | ~400KB |
| macOS x86_64 | ~648KB | ~405KB |
| Linux x86_64 | ~620KB | ~390KB |
| Linux ARM64 | ~542KB | ~388KB |
| Windows x86_64 | ~835KB | ~410KB |

## Advanced Usage

### Custom Target

Build for a specific target:

```bash
zig build -Dtarget=x86_64-linux -Doptimize=ReleaseFast
```

### Custom Optimization

```bash
# Safe optimized build
zig build -Doptimize=ReleaseSafe

# Size optimized build
zig build -Doptimize=ReleaseSmall
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Build All Platforms

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Zig
        uses: goto-bus-stop/setup-zig@v2
        with:
          version: 0.15.1

      - name: Build All Platforms
        run: zig build build-all

      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: headwind-binaries
          path: zig-out/dist/
```

## Troubleshooting

### Windows Build Issues

**RESOLVED**: Windows builds are now fully working! The zig-config dependency has been updated to use cross-platform environment variable handling.

### macOS Static Linking

macOS does not support static linking with libc. All macOS builds are dynamically linked. This is a platform limitation, not a build system issue.

### Memory Issues on Large Projects

If you encounter out-of-memory errors during builds:

```bash
# Increase Zig's memory limit
zig build -Doptimize=ReleaseFast --global-cache-dir=/tmp/zig-cache
```

## Performance Tips

1. **Use ReleaseFast for production** - Best runtime performance
2. **Use ReleaseSmall for containers** - Smaller Docker images
3. **Static linking for Linux** - No dependency issues in production
4. **Strip symbols** - Already done automatically for release builds

## Build System Internals

The build system is defined in `build.zig` and provides:

- Automatic platform detection
- Conditional static linking (Linux/Windows only)
- Debug symbol stripping for release builds
- Platform-specific output directories
- Parallel compilation support
- Incremental builds

## Future Improvements

- [ ] Universal binary for macOS (combining x86_64 + arm64)
- [ ] Fix Windows builds (zig-config dependency issue)
- [ ] Add ARM32 Linux target
- [ ] Add BSD targets (FreeBSD, OpenBSD)
- [ ] Automated binary signing for macOS
- [ ] Notarization for macOS distribution
- [ ] Cross-compilation from Windows host

## See Also

- [README.md](README.md) - Project overview and usage
- [TODO.md](TODO.md) - Development roadmap
- [NEXT_STEPS.md](NEXT_STEPS.md) - Recommended next features
