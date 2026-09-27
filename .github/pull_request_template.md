<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk> -->

## Summary

<!-- What changed and why? Link related issues with `Closes #N` where applicable. -->

## Scope and evidence

- [ ] I reviewed the package-local README and manifest(s).
- [ ] I distinguish model checks, native tests, ABI checks, binding tests, and source-pattern smoke checks.
- [ ] I have not promoted directory counts, historical audits, or source greps into current build/conformance claims.
- [ ] Any readiness/binding claims are backed by current, reproducible evidence.

## Checks

List exact commands, tool versions, and outcomes. Mark unavailable checks explicitly.

- [ ] `just validate`
- [ ] `just test-static` (heuristic/inventory checks only)
- [ ] Applicable Idris2 build(s):
- [ ] Applicable Zig build/test(s):
- [ ] Binding build/link/runtime checks, if a binding changed:
- [ ] `git diff --check`

**Skipped checks and reason:**

<!-- Include tool versions and complete failure/skipped output where useful. -->

## Safety and compatibility

- [ ] Unavailable authentication/cryptographic operations remain fail-closed.
- [ ] Native ABI declarations and buffer/length boundaries were reviewed.
- [ ] No secrets or credentials are included.
- [ ] File-level SPDX identifiers and third-party license notices are preserved.
- [ ] No container image is built, signed, pushed, or deployed by this change.

## Documentation and metadata

- [ ] Human-readable docs match the implementation and test scope.
- [ ] `.machine_readable/6a2/STATE.a2ml`, `META.a2ml`, or `ECOSYSTEM.a2ml` updated if relevant.
- [ ] `.machine_readable/BINDINGS.a2ml` and readiness docs updated only where new evidence supports it.
- [ ] Root `Justfile` and `.machine_readable/contractiles/Justfile` remain synchronized.
- [ ] `TOPOLOGY.adoc` or `CHANGELOG.adoc` updated if relevant.

## Remaining risks / follow-up

<!-- State limitations plainly. A source smoke pass is not a proof, conformance result, or security certification. -->
