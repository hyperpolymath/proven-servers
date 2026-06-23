<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
<!-- Replace proven-servers with your project name -->

# proven-servers Component Readiness Assessment

**Standard:** [Component Readiness Grades (CRG) v1.0](https://github.com/hyperpolymath/standards/tree/main/component-readiness-grades)
**Assessed:** 2026-03-02
**Assessor:** Jonathan D.A. Jewell

**Current Grade:** C

## Grade Reference

| Grade | Name                  | Release Stage      | Meaning                                              |
|-------|-----------------------|--------------------|------------------------------------------------------|
| X     | Untested              | —                  | No testing performed. Status unknown.                |
| F     | Harmful / Wasteful    | —                  | Reject, deprecate, or delegate.                      |
| E     | Minimal / Salvageable | Pre-alpha          | Barely functional. Needs redesign or major work.     |
| D     | Partial / Inconsistent| Alpha              | Works on some things but not systematically.         |
| C     | Self-Validated        | Beta               | Dogfooded and reliable in home context.              |
| B     | Broadly Validated     | Release Candidate  | Tested on 6+ diverse external targets.               |
| A     | Field-Proven          | Stable             | Real-world feedback confirms value. No harm in wild. |

## Component Assessment

Assessed by component group. Evidence is tool-backed (see
`audits/proof-panic-attack-2026-06-23.md`): `idris2 --build` type-checks the
proofs; `zig build test` exercises the engines.

| Component group | Count | Grade | Release Stage | Evidence Summary | Last Assessed |
|-----------------|-------|-------|---------------|------------------|---------------|
| Connector ABI-FFI (`connectors/proven-*conn`) | 6 | B | Release Candidate | Full RSR stack: Idris2 ABI proofs + generated C headers + Zig FFI; exercised via Rust/Gleam/Elixir bindings. | 2026-06-23 |
| Protocol cores (`protocols/proven-*`) | 88 | C | Beta | Idris2 types + proofs compile under `%default total` (96/96 packages); Zig engines pass FFI tests (98/98). In-memory skeletons, dogfooded; not externally validated. | 2026-06-23 |
| Reference servers (`proven-timestamp`, `proven-quic`, `proven-http3`) | 3 | C | Beta | As above, plus deeper proofs (validator decidability, exhaustive conformance, universal safety theorems) and reproducible RFC/test vectors. | 2026-06-23 |
| Core primitives (`core/proven-*`) | 8 | C | Beta | Idris2 cores compile; Zig engines pass where present. | 2026-06-23 |
| Language bindings (`bindings/`) | 10 langs | D | Alpha | Present for 10 languages; only Rust/Gleam/Elixir carry tests (ReScript has none); not conformance-tested against the C ABI. | 2026-06-23 |

## Detailed Assessment

### Protocol cores — Grade C (Beta)

- **Evidence:** All 96 Idris2 packages type-check (proofs verified); all 98 Zig
  FFI engines pass `zig build test`; no proof-escape hatches and no
  `@panic`/`unreachable` in engine code.
- **Known limitations:** the proofs constrain an Idris *model*; the Zig engine
  that runs is linked to it by hand + tests, not by a machine-checked proof
  (the model–implementation gap). Engines are in-memory state machines — no
  real networking, TLS/crypto, or persistence. 16 protocols still carry an
  unverified (orphaned) ABI pending migration.
- **Promotion path (→ B):** close the model–implementation gap (exhaustive
  conformance / single-sourced tags), make every transition relation `Dec`,
  and validate on 6+ external targets via the bindings.
- **Demotion risk:** Low — the build + test gates are green and reproducible.

### Connector ABI-FFI — Grade B (Release Candidate)

- **Evidence:** the 6 connectors are the only components with the complete,
  documented ABI-FFI layer and multi-language binding coverage.
- **Promotion path (→ A):** real-world deployment feedback.
- **Demotion risk:** Low.

## Notes

- Grades are per-component, not per-project.
- Grade A does not mean perfection — it means demonstrated value in the field.
- Grade F includes opportunity cost — maintaining something when a better tool exists.
- Grades can be skipped if evidence supports it (e.g., X → C if dogfooded immediately).
- Review all grades before each release and at least once per release cycle.
- See the [full CRG standard](https://github.com/hyperpolymath/standards/tree/main/component-readiness-grades) for complete definitions, evidence requirements, and transition criteria.
