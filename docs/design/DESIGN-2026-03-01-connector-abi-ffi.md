<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->
<!--
  DESIGN-2026-03-01-connector-abi-ffi.md
  Design document for the ABI (Idris2) and FFI (Zig) layers
  across all 6 proven-servers connector interfaces.
-->

# Connector ABI-FFI Design — 2026-03-01

## Summary

This document describes the formal ABI and FFI layers for all 6
**proven-servers connector interfaces**: `dbconn`, `authconn`, `cacheconn`,
`queueconn`, `resolverconn`, and `storageconn`.

Each connector follows a uniform four-layer architecture:

1. **Idris2 ABI** — Dependent-type definitions proving tag encodings,
   state-machine transitions, and capability witnesses
2. **C Header** — Auto-generated tag constants, opaque struct typedefs,
   and function declarations
3. **Zig FFI** — Runtime state-machine enforcement via exported `callconv(.c)`
   functions
4. **Zig Tests** — ABI version checks, lifecycle tests, invalid-transition
   rejection, NULL safety, and enum tag consistency

## Motivation

The proven-servers connectors define the *interfaces* between a formally
verified server core and external infrastructure (databases, caches,
queues, storage, DNS, authentication). These interfaces must be:

- **Correct by construction** — invalid state transitions are impossible
  at the type level (Idris2 `impossible` keyword eliminates bad cases)
- **Language-agnostic** — any language that can call C can use the connector
- **Testable** — runtime behaviour matches the compile-time proofs

The ABI-FFI pattern achieves all three. The Idris2 ABI *proves* the state
machine is sound; the Zig FFI *enforces* it at runtime; the C header lets
*any* language consume it.

## Architecture

```
                ┌─────────────────────────────────────────────────────┐
                │  Idris2 ABI (compile-time proofs)                  │
                │                                                     │
                │  Layout.idr       Tag encodings + roundtrip proofs  │
                │  Transitions.idr  GADT state machine + witnesses    │
                │  Foreign.idr      Opaque handles + FFI contract     │
                └───────────────────────┬─────────────────────────────┘
                                        │ generates
                                        ▼
                ┌─────────────────────────────────────────────────────┐
                │  C Header (generated/abi/<conn>.h)                 │
                │  Tag #defines · opaque structs · function decls    │
                └───────────────────────┬─────────────────────────────┘
                                        │ imported by
                                        ▼
                ┌─────────────────────────────────────────────────────┐
                │  Zig FFI (ffi/zig/src/<conn>.zig)                  │
                │  enum(u8) types · handle structs · exported fns    │
                └───────────────────────┬─────────────────────────────┘
                                        │ tested by
                                        ▼
                ┌─────────────────────────────────────────────────────┐
                │  Zig Tests (ffi/zig/test/<conn>_test.zig)          │
                │  ABI version · lifecycle · NULL safety · tag match  │
                └─────────────────────────────────────────────────────┘
```

## Per-Connector State Machines

### proven-dbconn (reference implementation)

```
States: Disconnected(0) Connected(1) InTransaction(2) Prepared(3) Failed(4)
Transitions:
  Connect:      Disconnected → Connected
  Disconnect:   Connected    → Disconnected
  BeginTx:      Connected    → InTransaction
  Commit:       InTransaction → Connected
  Rollback:     InTransaction → Connected
  Prepare:      Connected    → Prepared
  Execute:      Prepared     → Connected
  ConnFail:     Connected    → Failed
  Reset:        Failed       → Disconnected
Capabilities:
  CanQuery:    Connected only
  CanBeginTx:  Connected only
```

### proven-authconn

```
States: Unauthenticated(0) Challenging(1) Authenticated(2)
        Expired(3) Revoked(4) Locked(5)
Transitions:
  InitAuth:       Unauthenticated → Challenging     (MFA methods)
  DirectAuth:     Unauthenticated → Authenticated   (password, apikey, cert, opaque)
  LockOut:        Unauthenticated → Locked           (max failed attempts)
  ChallengeOk:    Challenging     → Authenticated
  ChallengeFail:  Challenging     → Unauthenticated
  ChallengeLock:  Challenging     → Locked
  SessionExpire:  Authenticated   → Expired
  Revoke:         Authenticated   → Revoked
  ReAuth:         Expired         → Authenticated
  ResetRevoked:   Revoked         → Unauthenticated
  Unlock:         Locked          → Unauthenticated
Capabilities:
  CanAuthenticate:   Unauthenticated only
  CanAccessResource: Authenticated only
Constants:
  MAX_TOKEN_LIFETIME   = 3600s
  MAX_REFRESH_LIFETIME = 86400s
  MAX_LOGIN_ATTEMPTS   = 5
  LOCKOUT_DURATION     = 900s
```

### proven-cacheconn

```
States: Disconnected(0) Connected(1) Degraded(2) Failed(3)
Transitions:
  Connect:     Disconnected → Connected
  ConnectFail: Disconnected → Failed
  Disconnect:  Connected    → Disconnected
  Degrade:     Connected    → Degraded
  ConnDrop:    Connected    → Failed
  Recover:     Degraded     → Connected
  FullFailure: Degraded     → Failed
  Reset:       Failed       → Disconnected
Capabilities:
  CanOperate: Connected or Degraded
  CanFlush:   Connected only (not degraded)
Constants:
  DEFAULT_TTL      = 3600s
  MAX_KEY_LENGTH   = 512
  MAX_VALUE_SIZE   = 1048576 (1 MiB)
```

### proven-queueconn

```
States: Disconnected(0) Connected(1) Consuming(2) Producing(3) Failed(4)
Transitions:
  Connect:      Disconnected → Connected
  ConnectFail:  Disconnected → Failed
  Subscribe:    Connected    → Consuming
  Unsubscribe:  Consuming    → Connected
  Publish:      Connected    → Producing  (brief)
  PublishDone:  Producing    → Connected
  ConsumeFail:  Consuming    → Failed
  ProduceFail:  Producing    → Failed
  Disconnect:   Connected    → Disconnected
  ConsDrop:     Consuming    → Disconnected
  Reset:        Failed       → Disconnected
Capabilities:
  CanConsume:   Consuming only
  CanProduce:   Producing only  (Connected can initiate)
  CanSubscribe: Connected only
Constants:
  MAX_MESSAGE_SIZE  = 1048576 (1 MiB)
  DEFAULT_PREFETCH  = 10
  ACK_TIMEOUT       = 30s
```

### proven-resolverconn

```
States: Ready(0) Querying(1) Cached(2) Failed(3)
Transitions:
  Query:         Ready    → Querying
  CacheHit:      Ready    → Cached
  InitFail:      Ready    → Failed
  QueryComplete: Querying → Ready
  StoreResult:   Querying → Cached
  QueryFail:     Querying → Failed
  CacheExpire:   Cached   → Ready
  RefreshQuery:  Cached   → Querying
  Reset:         Failed   → Ready
Capabilities:
  CanResolve: Ready only
  CanServe:   Ready or Cached
Record Types (13):
  A(0) AAAA(1) CNAME(2) MX(3) NS(4) SOA(5) TXT(6) SRV(7)
  PTR(8) CAA(9) TLSA(10) HTTPS(11) SVCB(12)
Constants:
  DEFAULT_TIMEOUT    = 5s
  MAX_RETRIES        = 3
  MAX_CACHE_ENTRIES  = 10000
  MIN_TTL            = 60s
```

### proven-storageconn

```
States: Disconnected(0) Connected(1) Uploading(2) Downloading(3) Failed(4)
Transitions:
  Connect:       Disconnected → Connected
  ConnectFail:   Disconnected → Failed
  StartUpload:   Connected    → Uploading
  StartDownload: Connected    → Downloading
  UploadDone:    Uploading    → Connected
  UploadFail:    Uploading    → Failed
  DownloadDone:  Downloading  → Connected
  DownloadFail:  Downloading  → Failed
  Disconnect:    Connected    → Disconnected
  UploadCancel:  Uploading    → Connected
  Reset:         Failed       → Disconnected
Capabilities:
  CanOperate: Connected only (Uploading/Downloading are busy)
Constants:
  MAX_OBJECT_SIZE       = 5368709120 (5 GiB)
  MAX_KEY_LENGTH        = 1024
  MAX_BUCKET_NAME_LEN   = 63
```

## Idris2 ABI Layer Detail

Each connector's Idris2 ABI consists of three modules:

### Layout.idr

Defines tag encodings as `Bits8` with three components per type:

1. **Size constant** — `<Type>Size : Nat` (number of variants)
2. **Encoder** — `<type>ToTag : <Type> -> Bits8` (type → tag)
3. **Decoder** — `tagTo<Type> : Bits8 -> Maybe <Type>` (tag → type)
4. **Roundtrip proof** — `tagTo<Type>Roundtrip : (x : <Type>) -> tagTo<Type> (<type>ToTag x) = Just x`

The roundtrip proof ensures the encoder and decoder are consistent —
encoding then decoding always recovers the original value. This is
proved by case-splitting on every variant, each reducing to `Refl`.

### Transitions.idr

Defines a GADT `ValidTransition : <State> -> <State> -> Type` where each
constructor names a legal transition:

```idris
data ValidTransition : AuthState -> AuthState -> Type where
  InitAuth  : ValidTransition Unauthenticated Challenging
  DirectAuth : ValidTransition Unauthenticated Authenticated
  ...
```

**Capability witnesses** are predicates on single states:

```idris
data CanAuthenticate : AuthState -> Type where
  AuthWhenUnauth : CanAuthenticate Unauthenticated
```

**Impossibility proofs** use the `impossible` keyword to eliminate
nonsensical states:

```idris
noAuthFromLocked : CanAuthenticate Locked -> Void
noAuthFromLocked x impossible
```

**Decidability procedures** return `Dec (CanX s)` for any state `s`,
allowing callers to branch on capability at compile-time:

```idris
decCanAuthenticate : (s : AuthState) -> Dec (CanAuthenticate s)
decCanAuthenticate Unauthenticated = Yes AuthWhenUnauth
decCanAuthenticate _ = No (\case AuthWhenUnauth impossible)
```

### Foreign.idr

Declares opaque handle types and the FFI contract:

```idris
data SessionHandle : Type where [external]
```

The `[external]` pragma tells Idris2 the type has no Idris-side
representation — it exists only as a pointer in the FFI layer. The
module also documents the ABI version and lists all exported functions
with their Zig/C signatures.

## Zig FFI Layer Detail

Each Zig implementation:

1. Defines `enum(u8)` types matching the C header tag values exactly
2. Defines a handle `struct` holding the current `state` and any
   connection parameters (port, TLS flag, etc.)
3. Uses `std.heap.GeneralPurposeAllocator` for handle allocation
4. Exports functions with `pub export fn ... callconv(.c)` that:
   - Return early with an error on NULL handles (`orelse return ...`)
   - Switch on `handle.state` to enforce the state machine
   - Return domain-appropriate errors for invalid states

### Naming Conventions

- Zig enums use `snake_case` matching the Idris2 constructors
- Zig avoids keyword collisions: `none_` for `None` (IntegrityCheck),
  `opaque_` for `Opaque` (CredentialType)
- C header constants use `SCREAMING_SNAKE_CASE` with a connector prefix:
  `AUTHCONN_STATE_AUTHENTICATED`, `STORAGECONN_ERR_PATH_TRAVERSAL`

## Error Tag Convention

All connectors reserve **tag 0 for "no error"**. Error variants begin
at tag 1. This is consistent across all 6 connectors and matches the
C convention where 0 indicates success.

## Testing Strategy

Each connector has a Zig test file exercising:

| Category | Description |
|----------|-------------|
| ABI version | `_abi_version()` returns 1 |
| Happy path | Connect → operate → disconnect lifecycle |
| Invalid transitions | Operations in wrong state return errors |
| NULL safety | All functions handle NULL handles gracefully |
| Enum tag consistency | Every variant's `@intFromEnum` matches the C header tag |

Test counts: authconn (20), cacheconn (13), queueconn (17),
resolverconn (12), storageconn (14), dbconn (per prior session).

## Build

Each connector builds independently:

```bash
cd connectors/proven-<name>/ffi/zig
zig build                         # shared + static libraries
zig build test                    # run integration tests
zig build -Doptimize=ReleaseFast  # optimised build
```

Output: `zig-out/lib/libproven_<name>.so` (shared) and
`zig-out/lib/libproven_<name>.a` (static).

## Verification Summary

All 6 connectors verified on 2026-03-01:

- **Zig 0.15.2** — `zig build` produces 0 errors for all 6
- **Zig 0.15.2** — `zig build test` passes for all 6
- **Reversal test** — checking out `c7f6796` (prior commit) confirms
  all FFI directories are absent and builds fail; restoring `2011a1f`
  confirms all files are present and builds succeed

## Future Work

- **Language bindings** — Rust, ReScript, Gleam, Elixir wrappers
  consuming the C ABI
- **Core primitives ABI-FFI** — same pattern for the 8 core
  primitives (socket, frame, fsm, wire, compose, tls, config, audit)
- **Protocol ABI-FFI** — 94 protocol skeletons (lower priority;
  connectors and core are the integration surface)
- **Idris2 type-checking** — currently the Idris2 files define types
  but are not compiled (no Idris2 in CI yet); adding `idris2 --check`
  to CI is a tracked goal
