<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

# 0002. Add proven-epistemic: a provably non-amplifying disclosure core

Date: 2026-06-11

## Status

Accepted

## Context

Estate consumer products (first: flat-mate's Squad Audit,
`flat-mate/docs/design/squad-audit-v1.adoc`) need a server core that governs
*who may learn what* about a data subject: per-field governance metadata
`{purpose, revealingness, minTier}`, reciprocal disclosure tiers
(LinkedIn-style: you see at most what you yourself grant), and a session
lifecycle in which over-tier disclosure is impossible rather than merely
checked.

"Epistemic type server" is our coinage, not an established term — but the
substance is classical and citable: Denning (1976) lattice model of secure
information flow; Goguen & Meseguer (1982) noninterference; Volpano, Smith &
Irvine (1996) security type systems; Myers (1999) JFlow/Jif; Fagin, Halpern,
Moses & Vardi, *Reasoning About Knowledge* (epistemic logic); Byun & Li (2005)
purpose-based access control. This component is a small, honest instance of
Denning-style lattice flow control encoded in dependent types.

Scope boundary (deliberate): this is the **authorized-disclosure policy
layer** only. Adjacent privacy-enhancing technologies live on other layers and
are explicitly out of scope here: differential privacy bounds *inferential*
leakage from aggregates (relevant to consumers' telemetry, not to this core);
SMPC and homomorphic encryption shrink *trust in the computing substrate*.
None of them fix output leakage (a disclosed score reveals information about
its inputs — the "self-inference" caveat); that is an epistemic fact about
functions, not a gap in this design.

## Decision

Add `protocols/proven-epistemic/` as the 95th protocol skeleton, following
the standard skeleton idiom (closed sum types, total Show instances, indexed
transition witnesses, impossibility proofs, `%default total`, no
`believe_me`/`assert_total`):

- `Epistemic.Types` — `Tier` (Band < Relational < Full), `Revealingness`
  (Innocuous/Contextual/Sensitive), `Purpose`, `FieldGovernance` record,
  `SessionPhase`, `DisclosureError`.
- `Epistemic.Lattice` — `TierLTE` order witnesses; `meet`; machine-checked
  lattice laws: `meetSym` (reciprocity), `meetIdem`, `meetAssoc`,
  `bandAbsorbs` (deny-by-default absorbs), `meetLowerLeft`/`meetLowerRight`
  (never above either grant), `meetGreatest` (no permitted disclosure is
  wasted), decidable ordering `isTierLTE`.
- `Epistemic.Transitions` — session FSM
  (Initiated → TiersAgreed → Disclosing → Closed, with refusal edges,
  terminal-Closed and cannot-skip-agreement impossibility proofs);
  `Disclosable` witness whose only constructor demands the ordering proof
  (over-tier disclosure is *unrepresentable*); `disclosableMonotone`;
  `decideDisclosable`; `WellGoverned` (Sensitive ⇒ minTier = Full) with
  `sensitiveNeverAtBand` / `sensitiveNeverAtRelational`.

All modules typecheck under Idris2 0.8.0 with `%default total` and zero
escape hatches.

## Consequences

### Positive

- Consumers (flat-mate conceal lattice first) get a reference semantics with
  machine-checked reciprocity and non-amplification, instead of ad-hoc
  redaction logic; runtime implementations in other languages can be
  cross-tested against this core's truth tables.
- The "never above your own grant" property — the product-level privacy
  promise — is a theorem, not a code-review hope.
- GDPR Art. 25 (data protection by design) documentation can cite a formal
  artifact.

### Negative

- No FFI layer yet: unlike the 6 connectors, this skeleton ships Idris-only.
  A Zig FFI + truth-table conformance tests is the natural next increment if
  a consumer wants to call the core directly rather than mirror it.
- The 3-tier chain is fixed; a consumer needing a richer lattice (per-purpose
  tiers, incomparable elements) must generalize `Tier` — deliberate, since
  the chain keeps every proof by exhaustive case analysis.

### Neutral

- Counts in README move from 108/94 to 109/95.
- The name "epistemic" enters the catalog's Security section; the module
  headers carry the literature lineage so the coinage is self-defining.
