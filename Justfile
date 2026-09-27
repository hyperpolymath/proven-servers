# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Repository tasks for proven-servers. Build/test commands are package-scoped
# and fail when required compilers are unavailable. Static smoke checks are
# labelled separately from compiler-backed verification.

set shell := ["bash", "-uc"]
set dotenv-load := true
set positional-arguments := true

# Optional contractile checks; the file contains only repository-specific,
# non-destructive recipes.
import? "contractile.just"

project := "proven-servers"

# Show the available, configured repository tasks.
default:
    @just --list --unsorted

help recipe="":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{recipe}}" ]; then
        just --list --unsorted
    else
        just --show "{{recipe}}"
    fi

info:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Project: {{project}}"
    echo "Current phase: $(sed -n 's/^phase = \"\(.*\)\"/\1/p' .machine_readable/6a2/STATE.a2ml | head -1)"
    echo "Readiness: $(sed -n 's/^\*\*Current Grade:\*\* \([A-FX]\).*/\1/p' READINESS.adoc | head -1)"
    echo "Toolchains: Idris2 and Zig are required for compiler-backed package checks."

# Build every Idris2 package manifest under protocols/, core/, and connectors/.
# The root module tree and not-proven/ examples are not package manifests in
# this configured build set.
build-idris:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v idris2 >/dev/null 2>&1 || { echo "ERROR: idris2 is required" >&2; exit 127; }
    count=0
    while IFS= read -r -d '' package; do
        package_dir="$(dirname "$package")"
        package_name="$(basename "$package")"
        printf '==> idris2 --build %s/%s\n' "$package_dir" "$package_name"
        (cd "$package_dir" && idris2 --build "$package_name")
        count=$((count + 1))
    done < <(find protocols core connectors -type f -name '*.ipkg' -print0 | sort -z)
    [ "$count" -gt 0 ] || { echo "ERROR: no Idris2 package manifests found" >&2; exit 1; }
    echo "Built $count Idris2 package manifests."

# Build the root FFI example and every Zig build manifest under the maintained
# protocol/core/connector trees. not-proven/ is intentionally excluded.
build-zig:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v zig >/dev/null 2>&1 || { echo "ERROR: zig is required" >&2; exit 127; }
    count=0
    while IFS= read -r -d '' build_file; do
        build_dir="$(dirname "$build_file")"
        printf '==> zig build (%s)\n' "$build_dir"
        (cd "$build_dir" && zig build)
        count=$((count + 1))
    done < <({ find protocols core connectors -type f -name 'build.zig' -print0; printf 'ffi/zig/build.zig\0'; } | sort -z)
    [ "$count" -gt 0 ] || { echo "ERROR: no Zig build manifests found" >&2; exit 1; }
    echo "Built $count Zig packages/examples."

# Build all configured Idris2 and Zig packages. Both compilers are required.
build: build-idris build-zig

# There is no uniform release profile across package-specific builds.
build-release:
    @echo "ERROR: no repository-wide release profile is configured; use the package's documented Zig options." >&2
    @exit 2

# There is no repository-wide incremental/watch build target.
build-watch:
    @echo "ERROR: no repository-wide build-watch target is configured." >&2
    @exit 2

# Remove compiler outputs only from maintained source/package trees.
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    find protocols core connectors bindings ffi -type d \( -name build -o -name zig-out -o -name _build \) -prune -exec rm -rf {} +
    rm -rf target/ _build/ dist/ out/ obj/ bin/

clean-all: clean
    rm -rf .cache .tmp

# Run Zig tests for every discovered build manifest and the root FFI example.
test-zig:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v zig >/dev/null 2>&1 || { echo "ERROR: zig is required" >&2; exit 127; }
    count=0
    while IFS= read -r -d '' build_file; do
        test_dir="$(dirname "$build_file")"
        printf '==> zig build test (%s)\n' "$test_dir"
        (cd "$test_dir" && zig build test)
        count=$((count + 1))
    done < <({ find protocols core connectors -type f -name 'build.zig' -print0; printf 'ffi/zig/build.zig\0'; } | sort -z)
    [ "$count" -gt 0 ] || { echo "ERROR: no Zig test targets found" >&2; exit 1; }
    echo "Ran Zig test targets for $count packages/examples."

# Source-pattern heuristics, selected policy checks, and language inventory;
# these are not substitutes for compiler tests or formal proofs.
test-static:
    bash tests/source_smoke_test.sh
    bash tests/aspect/security_test.sh
    bash tests/binding_inventory.sh

test: build-idris test-zig test-static

test-verbose: test

test-smoke: test-static

source-smoke:
    bash tests/source_smoke_test.sh

security-test:
    bash tests/aspect/security_test.sh

binding-inventory:
    bash tests/binding_inventory.sh

e2e:
    bash tests/e2e.sh

# Run configured checks only; language-specific formatting is not configured.
quality: fmt-check lint test
    @echo "Configured build, test, shell, and policy checks passed."

# No repository-wide formatter is declared. Do not report a no-op as formatting.
fmt:
    @echo "ERROR: no repository-wide formatter is configured." >&2
    @exit 2

# Check whitespace in staged and unstaged changes; not a language formatter.
fmt-check:
    git diff --check
    git diff --cached --check

# Validate shell syntax and the binding inventory/scaffold policy.
lint:
    #!/usr/bin/env bash
    set -euo pipefail
    while IFS= read -r -d '' script; do
        bash -n "$script"
    done < <(find . -path './.git' -prune -o -type f -name '*.sh' -print0)
    bash tools/check-binding-policy.sh
    echo "Shell syntax and binding-policy checks passed; no complete multi-language lint matrix is configured."

# Report required compiler/task-runner availability; missing tools fail the task.
deps:
    #!/usr/bin/env bash
    set -euo pipefail
    missing=0
    for tool in just idris2 zig; do
        if command -v "$tool" >/dev/null 2>&1; then
            printf 'available: %s (%s)\n' "$tool" "$(command -v "$tool")"
        else
            printf 'missing: %s\n' "$tool" >&2
            missing=1
        fi
    done
    [ "$missing" -eq 0 ] || exit 127

# Run a filesystem vulnerability scan; fail if Trivy is not installed.
deps-audit:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v trivy >/dev/null 2>&1 || { echo "ERROR: trivy is required for dependency/filesystem auditing" >&2; exit 127; }
    trivy fs --severity HIGH,CRITICAL --exit-code 1 --quiet .

security: security-test deps-audit
    @echo "Configured static smoke checks and Trivy scan passed."

# Generate an SPDX JSON SBOM only when Syft is available.
sbom:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v syft >/dev/null 2>&1 || { echo "ERROR: syft is required to generate the SBOM" >&2; exit 127; }
    mkdir -p docs/security
    syft . -o spdx-json > docs/security/sbom.spdx.json
    echo "Generated docs/security/sbom.spdx.json"

# Generate the Justfile cookbook and man page (not all project documentation).
docs: cookbook man
    @echo "Generated Justfile task reference and man page."

cookbook:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p docs
    output="docs/just-cookbook.adoc"
    {
        echo '= proven-servers Justfile Cookbook'
        echo ':toc: left'
        echo ':toclevels: 2'
        echo
        echo 'This file is generated from the configured root Justfile recipes.'
        echo
        echo '== Available Recipes'
        echo
        just --list --unsorted
    } > "$output"
    echo "Generated $output"

man:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p docs/man
    cat > docs/man/proven-servers.1 <<'EOF'
    .TH proven-servers 1 "$(date +%Y-%m-%d)" "proven-servers" "User Commands"
    .SH NAME
    proven-servers \- protocol models and FFI prototype sources
    .SH DESCRIPTION
    This source repository is not a production server distribution. The Justfile provides package-scoped build and test tasks plus static smoke checks.
    .SH SEE ALSO
    README.adoc(7), QUICKSTART-DEV.adoc(7)
    EOF
    echo "Generated docs/man/proven-servers.1"

# Validate repository-specific metadata locations and synchronized task copies.
validate-rsr:
    #!/usr/bin/env bash
    set -euo pipefail
    required=(
        .editorconfig .gitattributes .gitignore mise.toml Justfile
        README.adoc LICENSE SECURITY.adoc MAINTAINERS .github/CODEOWNERS
        0-AI-MANIFEST.a2ml .well-known/security.txt
        .machine_readable/6a2/AGENTIC.a2ml
        .machine_readable/6a2/ECOSYSTEM.a2ml
        .machine_readable/6a2/META.a2ml
        .machine_readable/6a2/NEUROSYM.a2ml
        .machine_readable/6a2/PLAYBOOK.a2ml
        .machine_readable/6a2/STATE.a2ml
        .machine_readable/6a2/anchor/ANCHOR.a2ml
        .machine_readable/rsr-profile.a2ml
        .machine_readable/BINDINGS.a2ml
        .machine_readable/contractiles/Adjustfile.a2ml
        .machine_readable/contractiles/Intentfile.a2ml
        .machine_readable/contractiles/Mustfile.a2ml
        .machine_readable/contractiles/Trustfile.a2ml
        .machine_readable/contractiles/Justfile
        .machine_readable/policies/MAINTENANCE-AXES.a2ml
        .machine_readable/policies/MAINTENANCE-CHECKLIST.a2ml
        .machine_readable/policies/SOFTWARE-DEVELOPMENT-APPROACH.a2ml
        .machine_readable/ai/README.adoc
        .machine_readable/bot_directives/README.adoc
        docs/maintenance/MAINTENANCE-CHECKLIST.adoc
        docs/practice/SOFTWARE-DEVELOPMENT-APPROACH.adoc
        docs/AI-CONVENTIONS.adoc
    )
    missing=0
    for path in "${required[@]}"; do
        if [ ! -e "$path" ]; then
            printf 'MISSING: %s\n' "$path" >&2
            missing=1
        fi
    done
    for name in STATE META ECOSYSTEM AGENTIC NEUROSYM PLAYBOOK; do
        if [ -e ".machine_readable/$name.a2ml" ]; then
            printf 'DUPLICATE CORE METADATA: .machine_readable/%s.a2ml\n' "$name" >&2
            missing=1
        fi
    done
    if ! cmp -s Justfile .machine_readable/contractiles/Justfile; then
        echo "MISMATCH: .machine_readable/contractiles/Justfile is not synchronized with Justfile" >&2
        missing=1
    fi
    [ "$missing" -eq 0 ] || exit 1
    echo "Repository metadata paths and Justfile copy are consistent."

# Validate only basic required fields; this is not a complete A2ML parser.
validate-state:
    #!/usr/bin/env bash
    set -euo pipefail
    state=.machine_readable/6a2/STATE.a2ml
    test -f "$state"
    grep -q '^\[metadata\]$' "$state"
    grep -q '^project = "proven-servers"$' "$state"
    grep -Eq '^last-updated = "[0-9]{4}-[0-9]{2}-[0-9]{2}"$' "$state"
    grep -q '^\[position\]$' "$state"
    grep -Eq '^phase = "[^"]+"$' "$state"
    echo "STATE.a2ml has the required project and position fields (syntax not fully parsed)."

# Ensure AI-facing onboarding warns about scope and points to real developer steps.
validate-onboarding:
    #!/usr/bin/env bash
    set -euo pipefail
    guide=docs/AI_INSTALLATION_GUIDE.adoc
    test -f "$guide"
    grep -q 'not a production server' "$guide"
    grep -q 'QUICKSTART-DEV.adoc' "$guide"
    if grep -q 'TODO-AI-INSTALL' "$guide"; then
        echo "ERROR: obsolete AI-install placeholders remain in $guide" >&2
        exit 1
    fi
    echo "AI-assisted developer onboarding states its deployment boundary."

validate: validate-rsr validate-state validate-onboarding

state-touch:
    #!/usr/bin/env bash
    set -euo pipefail
    state=.machine_readable/6a2/STATE.a2ml
    sed -i "s/^last-updated = \"[^"]*\"/last-updated = \"$(date +%Y-%m-%d)\"/" "$state"
    echo "Updated $state timestamp."

state-phase:
    @sed -n 's/^phase = "\(.*\)"/\1/p' .machine_readable/6a2/STATE.a2ml | head -1

# Run all configured local quality gates; requires the declared toolchains.
ci: quality security
    @echo "Configured local CI tasks passed."

install-hooks:
    #!/usr/bin/env bash
    set -euo pipefail
    hooks_dir="$(git rev-parse --git-path hooks)"
    mkdir -p "$hooks_dir"
    cat > "$hooks_dir/pre-commit" <<'HOOK'
    #!/usr/bin/env bash
    set -euo pipefail
    just fmt-check
    just lint
    HOOK
    chmod +x "$hooks_dir/pre-commit"
    echo "Installed pre-commit hook at $hooks_dir/pre-commit"

# Run the standards scanner only when installed; absence is an explicit error.
assail:
    @command -v panic-attack >/dev/null 2>&1 || { echo "ERROR: panic-attack is required for this scan" >&2; exit 127; }
    panic-attack assail .

doctor:
    #!/usr/bin/env bash
    set -euo pipefail
    missing=0
    for tool in git just idris2 zig; do
        if command -v "$tool" >/dev/null 2>&1; then
            printf '[OK] %s: %s\n' "$tool" "$(command -v "$tool")"
        else
            printf '[MISSING] %s\n' "$tool" >&2
            missing=1
        fi
    done
    printf 'Branch: %s\n' "$(git branch --show-current)"
    printf 'Working tree: %s\n' "$(if [ -z "$(git status --porcelain)" ]; then echo clean; else echo modified; fi)"
    exit "$missing"

status:
    @git status --short

log count="20":
    @git log --oneline -{{count}}

tour:
    @echo "Read README.adoc, QUICKSTART-DEV.adoc, and the package-local README before building a component."

help-me:
    @echo "Issues: https://github.com/hyperpolymath/proven-servers/issues/new"
    @echo "Include the exact package, commit, tool versions, command, and complete output."

todos:
    @git grep -n -E 'TODO|FIXME|XXX|HACK|STUB|PARTIAL' -- ':!PLACEHOLDERS.adoc' || true

crg-grade:
    @sed -n 's/^\*\*Current Grade:\*\* \([A-FX]\).*/\1/p' READINESS.adoc | head -1

crg-badge:
    #!/usr/bin/env bash
    set -euo pipefail
    grade="$(sed -n 's/^\*\*Current Grade:\*\* \([A-FX]\).*/\1/p' READINESS.adoc | head -1)"
    [ -n "$grade" ] || grade=X
    case "$grade" in
        A) color=brightgreen ;; B) color=green ;; C) color=yellow ;;
        D) color=orange ;; E) color=red ;; F) color=critical ;;
        *) color=lightgrey ;;
    esac
    printf '[![CRG %s](https://img.shields.io/badge/CRG-%s-%s?style=flat-square)](https://github.com/hyperpolymath/standards/tree/main/component-readiness-grades)\n' "$grade" "$grade" "$color"

# This source tree is not a deployable service: refuse container operations
# until a real executable target, health endpoint, and image tests are added.
container-build container-verify container-up container-down container-sign container-push container-run:
    @echo "ERROR: container deployment is disabled; this repository has no deployable server binary." >&2
    @exit 2
