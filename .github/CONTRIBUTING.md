<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk> -->

# Contributing to proven-servers

Thank you for helping improve this repository. It contains protocol models,
Idris2 packages, Zig FFI prototypes, language-binding sources, tests, and
maintenance material. It is **not** a production server distribution, and the
20 language-named binding directories are an inventory rather than a support
promise.

## Before you start

1. Read [README.adoc](../README.adoc), [QUICKSTART-DEV.adoc](../QUICKSTART-DEV.adoc),
   [AI conventions](../docs/AI-CONVENTIONS.adoc), and the package-local README.
2. Check [READINESS.adoc](../READINESS.adoc) and
   [PROOF-NEEDS.adoc](../PROOF-NEEDS.adoc) for current evidence limits.
3. For security reports, follow [SECURITY.adoc](../SECURITY.adoc); do not use a
   public issue or pull request to disclose a vulnerability.

## Development workflow

Use a focused branch and a package-specific change. Before opening a PR:

```sh
just validate
just test-static
# When installed, run the applicable compiler checks:
just build-idris
just build-zig
just test-zig
```

`just test-static` runs source-pattern and inventory heuristics; it is not a
runtime test, formal proof, ABI-conformance test, or security certification.
The compiler-backed tasks require Idris2 and Zig. Record exact compiler
versions and clearly list any checks that could not run. Toolchain versions are
not yet fully pinned repository-wide.

For changes to an individual component, also follow that package's README and
manifest. An Idris2 build validates only the definitions in the selected
`.ipkg`; a Zig test supports only the code paths it executes. Neither alone
proves that a separate header or language binding conforms.

## Change expectations

* Keep changes small and explain the problem and evidence in the PR.
* Preserve fail-closed behavior where credentials, key material, or a verified
  backend is absent. Do not turn an unavailable security operation into a
  success path.
* Do not claim bindings are wired/supported until they build, link, and run
  against the intended native library.
* Update `.machine_readable/BINDINGS.a2ml`, `READINESS.adoc`, or
  `PROOF-NEEDS.adoc` only when current evidence justifies the change.
* Preserve file-level SPDX identifiers and third-party license notices.
* Keep root `Justfile` synchronized with
  `.machine_readable/contractiles/Justfile`.
* Do not build, sign, push, or deploy the container scaffolding; no runnable
  application target is established.

There is no repository-wide language formatter or complete multi-language lint
matrix. `just fmt-check` checks Git whitespace only; do not describe it as code
formatting.

## Pull requests

Use the repository PR template. Include:

* a summary and motivation;
* affected packages and any compatibility impact;
* exact test/build commands and outcomes, with tool versions;
* explicit skipped checks and remaining risks;
* relevant issue or advisory references, when applicable.

A green source grep or historical audit report is not evidence that modified
native code builds today. Maintainers review changes before merging.
