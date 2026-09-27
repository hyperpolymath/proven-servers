#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Selected package build/test sweep. Despite the historical filename, this is
# not a full network-service E2E test or cross-language conformance suite.
# It checks two Idris2 packages, all current core/connector Zig test targets,
# and an explicitly selected sample of protocol Zig test targets.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

for tool in idris2 zig; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: $tool is required for the selected package test sweep" >&2
        exit 127
    fi
done

echo "Selected package build/test sweep (not full E2E/conformance)"
echo "Idris2: $(idris2 --version | head -1)"
echo "Zig: $(zig version)"

idris_packages=(
    protocols/proven-dns/proven-dns.ipkg
    protocols/proven-authserver/proven-authserver.ipkg
)
for package in "${idris_packages[@]}"; do
    package_dir="$(dirname "$package")"
    package_file="$(basename "$package")"
    echo "==> Idris2: $package"
    (cd "$package_dir" && idris2 --build "$package_file")
done

# Run every current core and connector Zig test target.
while IFS= read -r -d '' build_file; do
    build_dir="$(dirname "$build_file")"
    echo "==> Zig test: $build_dir"
    (cd "$build_dir" && zig build test)
done < <(find core connectors -type f -name build.zig -print0 | sort -z)

# Keep the protocol sample explicit so the run stays bounded and auditable.
protocols=(
    proven-dns proven-mqtt proven-amqp proven-authserver proven-ca
    proven-pqc proven-zerotrust proven-ctlog proven-kerberos proven-backup
)
for protocol in "${protocols[@]}"; do
    build_dir="protocols/$protocol/ffi/zig"
    if [ ! -f "$build_dir/build.zig" ]; then
        echo "ERROR: selected protocol has no Zig build manifest: $build_dir" >&2
        exit 1
    fi
    echo "==> Zig test: $build_dir"
    (cd "$build_dir" && zig build test)
done

echo "Selected package tests completed. This does not establish protocol conformance, ABI-wide equivalence, or production readiness."
