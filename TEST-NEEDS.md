# TEST-NEEDS.md — proven-servers

> Generated 2026-03-29 by punishing audit.

## Current State

| Category     | Count | Notes |
|-------------|-------|-------|
| Unit tests   | ~100  | Zig integration tests per protocol (~84 protocols, most have integration_test.zig). Some protocols have additional focused tests (amqp_test, dns_test, ftp_test, graphql_test, grpc_test, ca_test, agentic_test) |
| Integration  | 1     | tests/cross_binding_test.sh |
| E2E          | 0     | None |
| Benchmarks   | 1     | bindings/rust/benches/protocols.rs — REAL, comprehensive (tag roundtrip, state machine validation, domain validation, classification helpers, frame construction) |

**Source modules:** ~1821 across 84 protocols (Idris2 ABI + Zig FFI each), 5 core modules (frame, fsm, compose, audit, cli), 6 connectors, bindings (Rust, others). Each protocol has Types.idr + Foreign.idr + main.zig minimum.

## What's Missing

### P2P (Property-Based) Tests
- [ ] State machine transitions: property tests for each protocol's FSM (no impossible states reached)
- [ ] Type encoding roundtrip: for each protocol, all enum tags survive encode/decode
- [ ] Cross-protocol: property tests for protocol composition invariants

### E2E Tests
- [ ] Per-protocol: for at least the top 20 protocols, full lifecycle (connect -> handshake -> operate -> disconnect)
- [ ] proven-compose: compose 2+ protocols and verify combined behavior
- [ ] proven-audit: generate audit trail for protocol operations, verify completeness
- [ ] proven-cli: all CLI commands execute against mock servers

### Aspect Tests
- **Security:** No tests for protocol state machine bypass, buffer overflow in Zig FFI, authentication spoofing per protocol. 84 network protocols with ZERO security-specific tests
- **Performance:** Rust benchmarks exist and are REAL (tag roundtrip, state machine, domain validation). Missing: Zig FFI overhead per protocol, connection setup latency, throughput under load
- **Concurrency:** No tests for concurrent protocol connections, connection pool exhaustion, state machine race conditions
- **Error handling:** No tests for malformed protocol messages, connection drops, timeout handling, invalid state transitions

### Build & Execution
- [ ] Zig build + test for all 84 protocols
- [ ] Idris2 compilation of all protocol ABI specs
- [ ] Rust cargo bench
- [ ] Cross-binding test execution

### Benchmarks Needed (Existing + Missing)
- [x] Tag roundtrip latency (EXISTS, real)
- [x] State machine validation (EXISTS, real)
- [x] Domain validation (EXISTS, real)
- [x] Classification helpers (EXISTS, real)
- [x] Frame construction (EXISTS, real)
- [ ] Per-protocol connection setup time
- [ ] Zig FFI call overhead per protocol
- [ ] Memory usage per active connection
- [ ] Throughput under concurrent connections

### Self-Tests
- [ ] All 84 protocol ABI versions agree between Idris2 and Zig
- [ ] State machine completeness: every valid transition is reachable
- [ ] Audit trail integrity verification
- [ ] Protocol compliance self-check (RFC conformance)

### COVERAGE ANALYSIS

The per-protocol Zig integration tests are REAL and protocol-specific (verified: AMQP, DNS, Cache all have different content). Each test covers: ABI version, enum encoding, context lifecycle, transition table, invalid slot safety.

However: 84 protocols x ~3-5 test functions each = ~300-400 tests. This sounds impressive but each test only covers the FFI seam — the Idris2 formal specifications (752 files) and the protocol logic itself are tested only by type-checking.

| Area | Files | Tests | Status |
|------|-------|-------|--------|
| Protocol Idris2 ABI | 752 | 0 unit (type-checked) | Type-check only |
| Protocol Zig FFI | 425 | ~100 integration | **24% by file** |
| Core modules | 5 dirs | 5 tests | ~1 per core |
| Connectors | 6 | 0 | **Untested** |
| Rust bindings | 111 | 1 bench | Bench only |

## Priority

**HIGH.** 1821 source files with ~100 Zig integration tests and 1 excellent Rust benchmark suite. The per-protocol FFI tests are genuine and cover the critical seam. The Idris2 type-checking provides formal guarantees for specifications. BUT: 6 connectors are untested, no E2E tests for any protocol, no security tests for 84 network protocol implementations, and no concurrency tests. The Rust benchmark is a model — extend its pattern to all protocols.

## FAKE-FUZZ ALERT

- `tests/fuzz/placeholder.txt` is a scorecard placeholder inherited from rsr-template-repo — it does NOT provide real fuzz testing
- Replace with an actual fuzz harness (see rsr-template-repo/tests/fuzz/README.adoc) or remove the file
- Priority: P2 — creates false impression of fuzz coverage
