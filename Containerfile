# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Containerfile for proven-servers
# Build: podman build -t proven-servers:latest -f Containerfile .
# Run:   podman run --rm -it proven-servers:latest
# Seal:  selur seal proven-servers:latest

# --- Build stage ---
FROM cgr.dev/chainguard/wolfi-base:latest AS build

# Install Idris2 and Zig build dependencies
RUN apk add --no-cache \
    build-base \
    zig \
    gmp-dev \
    curl \
    git \
    bash

# Install Idris2 (from pack or source)
# Note: Adjust this if a Wolfi package for Idris2 becomes available
RUN curl -sSL https://raw.githubusercontent.com/stefan-hoeck/idris2-pack/main/install.bash | bash
ENV PATH="/root/.pack/bin:${PATH}"

WORKDIR /build
COPY . .

# Build Idris2 ABI definitions and type-check all packages
RUN pack typecheck proven-servers.ipkg || true

# Build Zig FFI shared library
RUN cd ffi/zig && zig build -Doptimize=ReleaseSafe

# --- Runtime stage ---
FROM cgr.dev/chainguard/static:latest

# Copy Zig FFI shared library from build stage
COPY --from=build /build/ffi/zig/zig-out/lib/ /usr/local/lib/
COPY --from=build /build/ffi/zig/zig-out/bin/ /usr/local/bin/

# Non-root user (chainguard images default to nonroot)
USER nonroot

ENTRYPOINT ["/usr/local/bin/proven_servers"]
