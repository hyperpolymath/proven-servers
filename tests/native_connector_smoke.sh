#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Native-connector pilot smoke test: build proven-amqp's Zig library, then
# drive it through ps_invoke from the C, Rust and Julia connectors in
# native-connectors/. Needs zig, cc, cargo and julia.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

for tool in zig cc cargo julia; do
    command -v "$tool" >/dev/null 2>&1 || { echo "ERROR: $tool is required" >&2; exit 127; }
done

AMQP="protocols/proven-amqp/ffi/zig"
# ReleaseSafe, not Debug: under Debug several amqp_* exports reserve 2.7-13.6 MB
# of stack (the session pool is copied), which overflows an 8 MB main thread.
# That is a pre-existing issue in amqp.zig, reported separately.
(cd "$AMQP" && zig build -Doptimize=ReleaseSafe)
LIB="$ROOT/$AMQP/zig-out/lib/libproven_amqp.so"
[ -f "$LIB" ] || { echo "ERROR: $LIB was not built" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "==> C connector"
cc -std=c11 -Wall -Wextra -Werror -o "$WORK/smoke" \
    native-connectors/c/smoke.c native-connectors/c/ps_connector.c -ldl
"$WORK/smoke" "$LIB"

echo "==> Rust connector"
PS_AMQP_LIB="$LIB" CARGO_TARGET_DIR="$WORK/rust" \
    cargo test --quiet --locked --manifest-path native-connectors/rust/Cargo.toml

echo "==> Julia connector"
PS_AMQP_LIB="$LIB" JULIA_DEPOT_PATH="$WORK/julia:" \
    julia --project=native-connectors/julia/ProvenConnector -e 'using Pkg; Pkg.test()'

echo "Native connector smoke tests passed (proven-amqp only)."
