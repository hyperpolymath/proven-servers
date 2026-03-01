<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

# proven-servers ABI/FFI Documentation

## Overview

This library follows the **Hyperpolymath RSR Standard** for ABI and FFI design:

- **ABI (Application Binary Interface)** defined in **Idris2** with formal proofs
- **FFI (Foreign Function Interface)** implemented in **Zig** for C compatibility
- **Generated C headers** bridge Idris2 ABI to Zig FFI
- **Any language** can call through standard C ABI

## Architecture

```
┌─────────────────────────────────────────────┐
│  ABI Definitions (Idris2)                   │
│  src/<Name>ConnABI/                         │
│  - Layout.idr      (Tag encodings + proofs) │
│  - Transitions.idr (State machine GADTs)    │
│  - Foreign.idr     (Opaque handles + FFI)   │
└─────────────────┬───────────────────────────┘
                  │
                  │ generates
                  ▼
┌─────────────────────────────────────────────┐
│  C Headers (generated)                      │
│  generated/abi/<name>.h                     │
└─────────────────┬───────────────────────────┘
                  │
                  │ imported by
                  ▼
┌─────────────────────────────────────────────┐
│  FFI Implementation (Zig)                   │
│  ffi/zig/src/<name>.zig                     │
│  - Implements C-compatible functions        │
│  - Zero-cost abstractions                   │
│  - Memory-safe by default                   │
└─────────────────┬───────────────────────────┘
                  │
                  │ compiled to libproven_<name>.so/.a
                  ▼
┌─────────────────────────────────────────────┐
│  Any Language via C ABI                     │
│  - Rust, ReScript, Gleam, Elixir, etc.     │
└─────────────────────────────────────────────┘
```

## Directory Structure

Each connector follows this layout:

```
connectors/proven-<name>/
├── src/
│   ├── <Name>Conn.idr               # Core types and constants
│   ├── <Name>Conn/Types.idr         # Sum type definitions
│   ├── <Name>Conn/Main.idr          # Entry point
│   ├── <Name>ConnABI.idr            # Re-export module
│   └── <Name>ConnABI/
│       ├── Layout.idr               # Tag encodings + roundtrip proofs
│       ├── Transitions.idr          # GADT state machine + witnesses
│       └── Foreign.idr              # Opaque handles + FFI contract
├── generated/abi/
│   └── <name>.h                     # C ABI header
└── ffi/zig/
    ├── build.zig                    # Build configuration
    ├── src/<name>.zig               # C-compatible FFI implementation
    └── test/<name>_test.zig         # Integration tests
```

## Why Idris2 for ABI?

### 1. **Formal Verification**

Idris2's dependent types prove properties about the ABI at compile-time:

```idris
-- Prove tag encoding roundtrips correctly
tagToStorageOpRoundtrip : (x : StorageOp) -> tagToStorageOp (storageOpToTag x) = Just x
tagToStorageOpRoundtrip PutObject    = Refl
tagToStorageOpRoundtrip GetObject    = Refl
tagToStorageOpRoundtrip DeleteObject = Refl
-- ...every variant reduces to Refl
```

### 2. **State Machine Proofs**

Encode exactly which transitions are legal as a GADT:

```idris
data ValidTransition : AuthState -> AuthState -> Type where
  InitAuth   : ValidTransition Unauthenticated Challenging
  DirectAuth : ValidTransition Unauthenticated Authenticated
  LockOut    : ValidTransition Unauthenticated Locked
  -- Invalid transitions are simply absent — impossible to construct
```

### 3. **Capability Witnesses**

Prove at the type level which states permit which operations:

```idris
data CanAuthenticate : AuthState -> Type where
  AuthWhenUnauth : CanAuthenticate Unauthenticated

-- Impossible in other states — the compiler proves this
noAuthFromLocked : CanAuthenticate Locked -> Void
noAuthFromLocked x impossible
```

### 4. **Decidability**

Compile-time branching on capability:

```idris
decCanAuthenticate : (s : AuthState) -> Dec (CanAuthenticate s)
decCanAuthenticate Unauthenticated = Yes AuthWhenUnauth
decCanAuthenticate _ = No (\case AuthWhenUnauth impossible)
```

## Why Zig for FFI?

### 1. **C ABI Compatibility**

Zig exports C-compatible functions naturally:

```zig
pub export fn authconn_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}
```

### 2. **Memory Safety**

Compile-time safety without runtime overhead:

```zig
const handle = h orelse return AuthError.invalid_handle;
// NULL check enforced — impossible to dereference null
```

### 3. **Cross-Compilation**

Built-in cross-compilation to any platform:

```bash
zig build -Dtarget=x86_64-linux
zig build -Dtarget=aarch64-macos
zig build -Dtarget=x86_64-windows
```

### 4. **Zero Dependencies**

No runtime, no libc required (unless explicitly needed).

## Components with ABI-FFI (as of 2026-03-01)

| Component | States | Transitions | Tests | Library |
|-----------|--------|-------------|-------|---------|
| proven-dbconn | 5 | 9 | ✓ | libproven_dbconn |
| proven-authconn | 6 | 11 | 20 | libproven_authconn |
| proven-cacheconn | 4 | 8 | 13 | libproven_cacheconn |
| proven-queueconn | 5 | 11 | 17 | libproven_queueconn |
| proven-resolverconn | 4 | 9 | 12 | libproven_resolverconn |
| proven-storageconn | 5 | 11 | 14 | libproven_storageconn |

## Building

### Build a single connector

```bash
cd connectors/proven-dbconn/ffi/zig
zig build                         # Build debug (shared + static)
zig build -Doptimize=ReleaseFast  # Build optimised
zig build test                    # Run integration tests
```

### Build all connectors

```bash
for conn in dbconn authconn cacheconn queueconn resolverconn storageconn; do
  (cd connectors/proven-$conn/ffi/zig && zig build test) && echo "$conn: OK"
done
```

### Cross-Compile

```bash
cd connectors/proven-dbconn/ffi/zig
zig build -Dtarget=x86_64-linux
zig build -Dtarget=aarch64-macos
zig build -Dtarget=x86_64-windows
```

## Usage

### From C

```c
#include "dbconn.h"

int main() {
    dbconn_error_t err;
    dbconn_handle_t *h = dbconn_connect("localhost", 5432, 1, &err);
    if (!h || err != DBCONN_ERR_NONE) return 1;

    // State is now Connected — can query
    err = dbconn_query(h, "SELECT 1", 8, NULL, 0, NULL);

    dbconn_disconnect(h);
    return 0;
}
```

Compile with:
```bash
gcc -o example example.c -lproven_dbconn -L./zig-out/lib
```

### From Rust

```rust
#[link(name = "proven_authconn")]
extern "C" {
    fn authconn_abi_version() -> u32;
    fn authconn_create_session(method: u8, err: *mut u8) -> *mut std::ffi::c_void;
    fn authconn_authenticate(h: *mut std::ffi::c_void,
                             cred: *const u8, cred_len: u32) -> u8;
    fn authconn_destroy_session(h: *mut std::ffi::c_void) -> u8;
}

fn main() {
    unsafe {
        assert_eq!(authconn_abi_version(), 1);
        let mut err: u8 = 0;
        let h = authconn_create_session(0, &mut err); // password auth
        assert!(!h.is_null());
        authconn_destroy_session(h);
    }
}
```

### From Julia

```julia
const libdbconn = "libproven_dbconn"

function connect(host, port, require_tls)
    err = Ref{UInt8}(0)
    h = ccall((:dbconn_connect, libdbconn), Ptr{Cvoid},
              (Cstring, UInt16, UInt8, Ptr{UInt8}),
              host, port, require_tls, err)
    h == C_NULL && error("Connection failed: error $(err[])")
    h
end

function disconnect(h)
    ccall((:dbconn_disconnect, libdbconn), UInt8, (Ptr{Cvoid},), h)
end

h = connect("localhost", 5432, 1)
try
    # ... use connection ...
finally
    disconnect(h)
end
```

## Testing

### Run connector tests

```bash
cd connectors/proven-storageconn/ffi/zig
zig build test
```

Tests cover:
- **ABI version** — `_abi_version()` returns 1
- **Lifecycle** — connect → operate → disconnect
- **Invalid transitions** — wrong-state operations return errors
- **NULL safety** — all functions handle NULL handles gracefully
- **Enum tag consistency** — `@intFromEnum` matches C header `#define` values

## Contributing

When modifying the ABI/FFI:

1. **Update ABI first** (`src/<Name>ConnABI/*.idr`)
   - Modify type definitions and proofs
   - Ensure roundtrip proofs still hold
   - Maintain backward compatibility

2. **Regenerate C header** (`generated/abi/<name>.h`)
   - Update tag `#define` values
   - Update function declarations

3. **Update FFI implementation** (`ffi/zig/src/<name>.zig`)
   - Implement new functions
   - Match ABI types exactly

4. **Add tests** (`ffi/zig/test/<name>_test.zig`)
   - Lifecycle tests for new transitions
   - Enum tag consistency for new variants
   - NULL safety for new functions

5. **Update documentation**
   - Design doc in `docs/design/`
   - TOPOLOGY.md completion dashboard
   - STATE.a2ml milestones

## License

SPDX-License-Identifier: PMPL-1.0-or-later

Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)

## See Also

- [Connector overview](connectors/README.adoc)
- [Design document](docs/design/DESIGN-2026-03-01-connector-abi-ffi.md)
- [Idris2 Documentation](https://idris2.readthedocs.io)
- [Zig Documentation](https://ziglang.org/documentation/master/)
