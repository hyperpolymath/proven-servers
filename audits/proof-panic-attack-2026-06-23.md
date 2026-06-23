<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Audit: proof-coverage "panic attack" (proven-servers)

**Auditor**: Claude (Opus) for Jonathan D.A. Jewell
**Date**: 2026-06-23
**Scope**: Every Idris2 package and Zig FFI engine under `protocols/`, `core/`,
and `connectors/` — what the "proven" claim does and does not establish, and
where it falls short of excellence.
**Method**: actual tools — `idris2 --build` (type-checking *is* proof checking
in Idris2), `zig build test`, and exhaustive `grep` for proof-escape hatches
and runtime traps. Commands in the appendix.

## TL;DR — does it need proof beyond what Idris provides?

**Yes — but the foundation is genuinely strong.** Every one of the 96 Idris
packages type-checks under `%default total` with zero proof-escape hatches and
zero `@panic`/`unreachable` in the engines. That is a real, machine-checked
result. But the Idris proofs establish properties of a *model*; three honest
gaps stand between that and an end-to-end "proven server":

1. **Model–implementation gap** — the artifact that runs is the Zig engine,
   and nothing machine-checks that it conforms to the proven Idris model.
2. **Soundness without completeness** — validators return a `Maybe` witness
   (sound) but are rarely `Dec` (complete); only 21 uses of `Dec` repo-wide.
3. **Representative facts, and tests-not-proofs at the engine** — many
   properties are single pinned `Refl` facts rather than ∀-quantified
   theorems, and the engines are unit-tested, not exhaustively conformance-
   checked.

All three are addressable. This audit lands exemplary fixes in
`proven-quic`, `proven-http3`, and `proven-timestamp` and gives a template for
the rest.

The sweep also found a concrete, high-severity defect: **three engines
(`proven-amqp`, `proven-diode`, `proven-triplestore`) segfault on *any* FFI
call** — confirmed by gdb — because an oversized fixed-size global overflows
the stack on entry. This is the same bug class hit and fixed in
`proven-timestamp` during development. All three are **fixed here** (verified:
the full Zig sweep goes from 95/98 to **98/98**).

## 1. What Idris actually proves here (the assurance you have)

The house style encodes protocol invariants as dependently-typed data:

* closed sum types for every wire enum (no "unknown" inhabitant);
* `Refl` round-trip proofs for ABI tag encode/decode;
* `ValidXTransition from to` GADTs that are *inhabited only* for legal moves;
* `impossible` / `-> Void` proofs that rule out illegal moves and reaching
  terminal states.

Under `%default total`, a clean build is a proof that all of this holds and
that the functions are total (cover all cases, terminate). Measured over the
repo:

| Signal | Tool | Result |
|---|---|---|
| Idris packages type-check (proofs verified) | `idris2 --build` × 96 | **96 / 96 pass, 0 fail** |
| Proof-escape hatches (`believe_me`, `assert_total`, `assert_smaller`, `idris_crash`, `postulate`) in code | `grep` | **0** |
| `Refl` proofs | `grep` | 4277 |
| `impossible` clauses | `grep` | 308 |
| negative proofs (`-> Void`) | `grep` | 291 |
| `@panic` / `unreachable` keyword in engine `src/` | `grep` | **0** |

This is well above typical "we wrote some types" hygiene: the spec layer is
total, exhaustive, and free of the usual cheats.

## 2. The three gaps (the honest answer)

### 2.1 Model–implementation gap (the significant one)

The proofs are about Idris values. The code that executes — and that bindings
call across the C ABI — is the Zig engine. The correspondence (tag values
match, the transition table matches the GADT, the frame table matches
`frameAllowedIn`) is maintained **by hand and checked by unit tests**, not by
any machine-checked link. So the accurate claim is *"proven specification +
tested implementation,"* not *"proven implementation."* Calling the whole
server "proven" overstates what is mechanised.

### 2.2 Soundness without completeness

A validator of type `(a, b) -> Maybe (ValidXTransition a b)` is **sound**: a
`Just w` carries a proof `w`. It is not, by itself, **complete** — nothing
stops it returning `Nothing` for a transition that is in fact legal. Across
the repo `Dec` (decidable, i.e. sound *and* complete) appears only 21 times;
the dominant pattern is sound-only `Maybe`.

### 2.3 Representative facts and engine tests

Properties such as "STREAM frames are not allowed in Initial packets" are
often pinned as a single `Refl` about one case, rather than a ∀-quantified
theorem. And the engines — the part that runs — are validated by example-based
unit tests, which is good practice but is not proof.

## 3. Panic-attack results — whole repo

* **Compilation / proofs:** 96 / 96 Idris packages pass `idris2 --build`. No
  package is broken; every proof in the tree currently checks.
* **Engine tests:** `zig build test` across all 98 engines → **95 / 98 pass
  on the unmodified tree; 3 crash (SIGSEGV)**: `proven-amqp`,
  `proven-diode`, `proven-triplestore`. After the fixes in §4: **98 / 98**.
  The crash is a stack overflow on function entry, confirmed with gdb on the
  amqp test binary:

  ```
  Program received signal SIGSEGV
  0x...0d in amqp.validSlot (slot=16915)        # slot value is prologue garbage
  => test   %esp,-0x1000(%rsp,%r10,1)           # stack-clash probe in the prologue
  #1 amqp_state (slot=0)                          # any call hits it
  ```

  Root cause: the session/gateway pool is a single fixed global so large
  (e.g. amqp `[64]Session` ≈ 9 MB; diode/triplestore ≈ 33 MB each) that the
  stack-clash probe walks past the guard page before the function body runs.
  Reducing the pool count makes the crash vanish (verified: amqp 64→8 turns
  the suite green), confirming the diagnosis.
* **Runtime-trap freedom:** no `@panic` and no `unreachable` keyword in any
  engine `src/` (the `*_unreachable` hits are enum *names* such as
  `network_unreachable`).
* **Proof hygiene:** no `believe_me` / `assert_total` / `postulate` /
  `idris_crash` in code. (One `||| ... believe_me ...` docstring in
  `proven-nesy` is prose, not a use.)

### Shortfalls found

| # | Shortfall | Where | Severity | Status |
|---|---|---|---|---|
| S1 | Validators sound but not complete (`Dec` rare: 21) | repo-wide | medium | pattern fixed in quic/http3 |
| S2 | `partial main` disables totality checking (rest of repo uses `covering`) | proven-sparql, proven-semweb, proven-chat | low | **fixed** → `covering` |
| S3 | Top-level re-export modules lack `%default total` | 8 modules (CLI, DNS, LPD, MQTT, NeSy, SMTP, WASM, WS) | low | documented (see §5) |
| S4 | Model–implementation correspondence is by hand + sampled tests | repo-wide | medium | bridged for finite tables in quic; template in §5 |
| S5 | Engine SIGSEGVs on any call (oversized fixed global overflows stack) | proven-amqp, proven-diode, proven-triplestore | **high** | **fixed** → pool sizes reduced; 98/98 |

## 4. What was fixed, with actual proofs and tools

All changes below were re-verified (`idris2 --build` clean = proofs hold;
`zig build test` green).

* **Completeness proofs (S1)** — turned the sound validators into *verified
  decision procedures* by proving, by induction on the witness, that every
  legal move is found:
  * `proven-quic`: `validateConnComplete`, `validateSendComplete`,
    `validateRecvComplete` (`Quic.Transitions`).
  * `proven-http3`: `validateReqComplete` (`Http3.Request`).
* **Universally-quantified safety theorems (S-2.3)** — `proven-quic`
  `Quic.Frames` now proves `retryHasNoFrames` and `vnHasNoFrames` for *every*
  frame kind (`(f : FrameKind) -> frameAllowedIn f PRetry = False`), not one
  pinned case. `proven-http3` already proves `controlAndRequestDisjoint` (the
  control/request frame sets are disjoint for all frames).
* **Totality hygiene (S2)** — `partial main` → `covering main` in the three
  offending packages; all three still build, confirming `partial` was
  unnecessary.
* **Model–implementation bridge (S4)** — `proven-quic` gains *exhaustive*
  conformance tests that check the engine's `quic_{conn,send,recv}_can_transition`
  against the proven relation on **all 36 cells each**. Over a finite domain,
  exhaustive checking decides conformance rather than sampling it.
* **Engine crash fix (S5)** — reduced the dominant fixed-pool sizes so the
  global no longer overflows the stack: `proven-amqp` `MAX_SESSIONS` 64→16,
  `proven-diode` `MAX_GATEWAYS` 64→8, `proven-triplestore` `MAX_SESSIONS`
  64→8. Each suite now passes (amqp 53/53, diode 21/21, triplestore 30/30).
  This is a stop-gap that trades pool capacity for correctness; see §5 for the
  proper fix.

Post-fix verification: `proven-quic` 17/17 engine tests, `proven-http3` 13/13,
`proven-timestamp` 23/23, and the three repaired engines green; all Idris
packages type-check (96/96); full engine sweep 98/98.

## 5. Recommendations to bring the rest to excellence

1. **Make every transition relation decidable.** For each `ValidXTransition`,
   add `validateXComplete : (w : ...) -> validateX a b = Just w` (one `Refl`
   per constructor). Cheap, and it upgrades soundness to soundness +
   completeness. Template: the `Quic.Transitions` module in `proven-quic`.
2. **Close the model–implementation gap for finite tables** with an exhaustive
   conformance test per engine table (transition matrices, frame/packet
   tables, tag maps). Template:
   `protocols/proven-quic/ffi/zig/test/integration_test.zig`
   (the `EXHAUSTIVE:` tests).
3. **Single-source the ABI tags.** Generate the Zig enum values and the Idris
   `xToTag` from one declaration so the two cannot drift, replacing the
   hand-maintained "tags MUST match" comments.
4. **Quantify the pinned facts.** Where a property holds for a whole type,
   state it as `(x : T) -> ...` (as now done for the Retry/VN frame rules).
5. **Totality consistency.** Add `%default total` to the 8 re-export modules
   in S3 and prefer `covering`/`total` over `partial` on every `main`.
6. **Bound the fixed-pool footprint (proper fix for S5).** The §4 size
   reductions are a stop-gap. The durable fix is to keep multi-megabyte pools
   off the stack-probed path: either heap-allocate the pool once at init
   (`std.heap` + a global pointer) so functions touching it carry no large
   frame, or cap `sizeof(pool)` to a small budget (e.g. < 1 MB) by construction.
   Add a `comptime` assertion such as
   `comptime { if (@sizeOf(@TypeOf(sessions)) > 1 << 20) @compileError("pool too large"); }`
   so the regression cannot recur silently. The same pattern should be audited
   across every engine with a fixed session/connection pool.

## 6. Residual honest caveats

Even with §5 applied, some things remain trusted rather than proven, and the
READMEs should keep saying so:

* **Infinite-domain logic** cannot be exhaustively conformance-tested — e.g.
  the QUIC varint codec (`u64`) and `proven-timestamp`'s hashing. These are
  covered by RFC known-answer vectors plus boundary/property tests, and the
  receipt pre-image is pinned identically in Idris, Zig, and `openssl`.
* **The C ABI itself, the Zig compiler, and `std.crypto`** are part of the
  trusted base.
* "Proven" here means *the protocol's structural invariants are
  machine-checked and the engine conforms to them on finite domains* — not a
  proof of the full networked system.

## Appendix — commands

```sh
# Idris: type-check every package (proof checking)
for p in $(find protocols core connectors -name '*.ipkg'); do
  (cd "$(dirname "$p")" && idris2 --build "$(basename "$p")"); done

# Zig: build + run every engine's tests
for b in $(find protocols core connectors -path '*/ffi/zig/build.zig'); do
  (cd "$(dirname "$b")" && zig build test); done

# Proof-escape hatches and runtime traps
grep -rnE 'believe_me|assert_total|assert_smaller|idris_crash|postulate' \
  protocols core connectors --include='*.idr'
grep -rn '@panic' protocols core connectors --include='*.zig' | grep -v /test/
```

## Addendum (2026-06-23): edge-case resolution

The 16 ABI-migration edge cases (S2) were examined and 15 resolved; each fix
was build-verified. The examination surfaced several real bugs that had been
invisible precisely because the modules were never compiled.

**Fixed (15):**

- *6 mis-detected orphans* (ospf, pop3, proxy, ptp, rtsp, wasm): the first
  migration script read the namespace from a docstring comment ("This module
  defines…"); using the anchored `^module` declaration they migrate cleanly.
- *5 invalid lowercase `abi` namespaces* (mcp, mdns, media, metrics, modbus):
  declared `module abi.Types`, which the ipkg parser rejects ("Expected end of
  file"). Renamed to capitalized `<Name>ABI` and compiled.
- *graphdb — a real proof bug*: `idleCannotQuery : SessionState -> Void;
  idleCannotQuery _ impossible` is not a valid impossible case (SessionState is
  inhabited). Fixed by adding the `CanQuery` capability witness and restating it
  as `CanQuery GDBIdle -> Void`.
- *caldav, carddav, dds — no ipkg at all*: added a library ipkg and removed a
  stale duplicate `src/abi/`. Their ABI proofs now compile (the protocols
  otherwise remain incomplete: no `Main`, top module, or Zig engine).

**Resolved follow-up (1) — `proven-radius`:** the remaining edge was a genuine
mess: the orphaned ABI was two overlapping module families. A redundant,
self-contained `RadiusABI.Types` (mixed-case) re-declared the core types from
scratch — and that is where the real bug lived: a data type `ServiceType` *and*
an `AttributeType` constructor also named `ServiceType` in the same namespace (a
clash). Alongside it sat a coherent all-caps family, `RADIUSABI.Layout` +
`RADIUSABI.Transitions`, which correctly `import RADIUS.Types` and add the
ABI-only `AuthMethod`/`RadiusResult`/`SessionState` plus the AAA state machine.

The three reported issues resolved as follows:

1. *`ServiceType` collision* — existed only inside the redundant `RadiusABI.Types`.
   Its tag values were byte-for-byte identical to `RADIUSABI.Layout`, so the file
   was deleted with no loss of ABI information.
2. *Module overlap* — consolidated onto the single `RADIUSABI.*` family (the
   casing the Zig engine already documents) under `src/RADIUSABI/`; `Foreign`
   became `RADIUSABI.Foreign` importing `RADIUSABI.Layout`.
3. *`maxGEMin` proof* — not a logic error at all: `So`/`Oh` were simply never in
   scope. Adding `import Data.So` lets `So (4096 >= 20)` reduce and `Oh` close it.

All three ABI modules are now in the ipkg and build-verified: `idris2 --build`
compiles all six modules, the executable runs, and the Zig engine still passes
48/48 tests (tag values were preserved throughout).

Net: all 73 originally-orphaned ABIs now compile — every round-trip proof is
verified for the first time.

## Addendum 2 (2026-06-23): a stricter orphan sweep

The earlier passes detected orphans by *path* (the tell-tale lowercase
`src/abi/`). A second, stricter check — *is every `.idr` module actually named
in some ipkg's `modules =` list?* — found a class the path heuristic missed:
modules sitting at the correct `src/<Name>ABI/` path, with the correct
namespace, that were simply never added to `modules =`. The compiler never saw
them, so their proofs were written but unverified.

The sweep flagged **36 such modules** across 17 protocols: the ABI
`Layout`/`Types`/`Transitions`/`Foreign` modules of agentic, bfd, coap, diode,
doh, doq, dot, irc, kerberos, kms, ldp, loadbalancer, logcollector, lpd, vpn,
and zerotrust, plus a dead `Main.idr` in nesy (which had been configured as a
library with no `main`/`executable`).

Resolution: the 35 ABI modules were added to their ipkgs; nesy was wired as an
executable (`main = Main`) like its siblings. Every one of the 17 protocols then
builds cleanly with `idris2 --build` (these proofs happened to be correct, just
unverified — unlike graphdb/radius, the only way to know was to compile them),
and nesy's executable runs.

Re-running the sweep afterwards: **0 orphaned / 498 total `.idr` modules** —
every proof module in the repository is now compiled, and therefore checked.
Escape hatches in active Idris code remain 0; `@panic` in Zig production code
remains 0.
