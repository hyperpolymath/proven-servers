#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Binding directory inventory and source-policy check. This does not compile,
# link, execute, or establish cross-language ABI conformance.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

printf '%s\n' 'Binding source inventory (no language compiler/linker is invoked):'
for binding_dir in bindings/*/; do
    [ -d "$binding_dir" ] || continue
    language="${binding_dir#bindings/}"
    language="${language%/}"
    source_count="$(find "$binding_dir" -type f \
      \( -name '*.ada' -o -name '*.adb' -o -name '*.ads' -o -name '*.c' -o -name '*.h' \
         -o -name '*.cc' -o -name '*.cpp' -o -name '*.hh' -o -name '*.hpp' -o -name '*.hxx' \
         -o -name '*.cs' -o -name '*.dart' -o -name '*.ex' -o -name '*.exs' \
         -o -name '*.gleam' -o -name '*.go' -o -name '*.hs' -o -name '*.java' \
         -o -name '*.js' -o -name '*.jl' -o -name '*.kt' -o -name '*.lua' \
         -o -name '*.ml' -o -name '*.php' -o -name '*.py' -o -name '*.affine' \
         -o -name '*.rb' -o -name '*.rs' -o -name '*.swift' \) -print | wc -l | tr -d ' ')"
    printf '  %-14s %s source-like files\n' "$language" "$source_count"
done

bash tools/check-binding-policy.sh
printf '%s\n' 'Inventory and source-policy check completed; binding support/conformance was not tested.'
