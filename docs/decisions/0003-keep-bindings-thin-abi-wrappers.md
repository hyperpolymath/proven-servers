<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

# 0003. Keep language bindings as thin C-ABI wrappers (no logic in bindings)

Date: 2026-06-24

## Status

Accepted

## Context

`proven-servers` is a derivative of the canonical `proven` library. Its own
clade registry records the lineage (`.machine_readable/CLADE.a2ml`):

> parent = "MCP servers exposing proven library operations"

It therefore inherits `proven`'s architecture — Idris2 proofs → Zig FFI →
generated C ABI → thin language bindings — and `proven`'s binding contract:
bindings are the cross-language product, but they carry **no safety logic**.
`proven`'s README states the rule directly: *"any non-Idris safety logic in
bindings is being removed or rewritten."*

An audit of `bindings/` triggered by a documentation discrepancy found two
problems:

1. **The docs undercounted and mischaracterised.** README, EXPLAINME,
   QUICKSTART-DEV, READINESS and ROADMAP all said "10 languages" and described
   the bindings uniformly as "type mirrors". The tree actually contains **20**
   language bindings, and they are *not* uniform.

2. **Three bindings reimplement unproven logic.** The reality is a spectrum:
   - **Fully FFI-wired** to `libproven_<proto>` — Ada (`pragma Import (C, …)`,
     links `-lproven_dns` …), Java (JNI `native` + `System.loadLibrary`), and
     Rust/Go/Python/OCaml/Julia/C++/C#/Dart/Haskell/Kotlin/Lua/PHP/Ruby/Swift.
   - **Reimplemented logic** — **Elixir, Gleam, ReScript** contain pure
     binding-language validation and state-machine code (e.g. `validate_domain_name`
     doing RFC 1035 byte-length checks, `validate_*_transition` encoding protocol
     FSMs). Elixir and Gleam have *no* FFI at all; ReScript has partial FFI.
     This is unproven safety logic living inside a library named *proven* — the
     exact anti-pattern.

A survey of the generated C ABI (34 headers, one per protocol/module) shows it
exposes **no standalone validators**: validation only happens implicitly inside
context-bound operations (`dns_parse_query` etc.). The only stateless callables
are `<proto>_can_transition(from, to)` and the `mqtt_topic_matches` /
`amqp_routing_match` matchers. So the reimplemented validators in
Elixir/Gleam/ReScript **cannot be "rewired" to a proven callable** — there is
nothing equivalent to call — and two of the three bindings have no FFI bridge
to call anything.

## Decision

1. **Keep all 20 bindings.** This mirrors `proven`, where bindings are the
   product (120+ targets, most "scaffolded"). We do not delete bindings.

2. **Bindings are thin C-ABI wrappers.** A binding file may only:
   (a) call the generated C ABI via that language's FFI, or
   (b) declare ABI-conformant constants / types / tag↔int converters whose
       values are checked against the ABI by the conformance sweep.
   A binding **must not** reimplement safety logic — validation, parsing, or
   state-machine transitions — in the binding language. **Ada and Java are the
   reference implementations** of this contract.

3. **Remove the unproven logic from Elixir, Gleam, ReScript now.** Because the
   ABI exposes no standalone validator to redirect to, and (for Elixir/Gleam)
   no FFI bridge exists, the offending functions are **deleted**, not rewired.
   Their conformance-checked constants and types are kept. Each removed function
   leaves a marker pointing here. The binding becomes a constants-only scaffold —
   consistent with `proven`'s scaffolded-binding tier — until provable FFI is
   built (see future work).

4. **Record state and guard it.** Add a machine-readable registry
   (`.machine_readable/BINDINGS.a2ml`) tiering every binding, and a CI tripwire
   (`tools/check-binding-policy.sh`, run from `tests/e2e.sh`) that fails if a
   `bindings/<lang>` directory is unregistered, or if the removed logic
   signatures reappear in a binding.

## Consequences

### Positive

- No unproven safety logic ships inside a formally-verified library; the
  `proven` invariant holds across all bindings.
- The documentation matches reality (20 bindings, honest per-binding tier and
  maturity) instead of a stale "10 type mirrors" claim.
- A standing tripwire prevents regression — logic cannot silently creep back
  into a binding, and a new hand-written binding cannot appear unregistered.
- Ada and Java stand as a concrete template for completing the rest.

### Negative

- Elixir, Gleam and ReScript temporarily lose validation / state-transition
  features (they become constants-only) until FFI is wired. This is a
  deliberate, honest reduction: a missing function is better than an unproven
  one in this library.
- The conformance sweep (a separate workstream) must grow to cover binding
  *constants*, which are still hand-mirrored; today they are guarded by review
  plus the Zig comptime guard on the generated side, not yet by per-binding
  cross-tests.
- The tripwire's "no logic" rule is enforced by a denylist of the removed
  signatures, not a general proof that a binding is logic-free; it catches
  regression of the known anti-patterns, not every conceivable one.

### Neutral

- Binding count in the docs moves 10 → 20.
- Future work, tracked separately: build the FFI bridge for the three scaffolded
  bindings — a NIF (or Zigler) layer for Elixir, `@external` for Gleam, and
  extended `@module` externals for ReScript — then restore the removed features
  by *calling* the verified core (`<proto>_can_transition`, the slot-based
  parse/validate path) instead of reimplementing it.
