<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# PROOF-NEEDS.md — proven-servers

## Current State

- **src/abi/*.idr**: YES — `Types.idr`, `Layout.idr`, `Foreign.idr`
- **Dangerous patterns**: 0 in own code (1 reference in NeSy/Types.idr is a documentation comment about neurosymbolic equivalent of believe_me)
- **LOC**: ~21,700 (Idris2 + Rust + Gleam + Go + Haskell)
- **ABI layer**: Complete Idris2 ABI; proven-dns and proven-nesy protocol definitions in Idris2

## What Needs Proving

| Component | What | Why |
|-----------|------|-----|
| DNS name validation | DNS name parser accepts only valid names per RFC | Invalid DNS names cause resolution failures |
| DNS protocol correctness | DNS query/response handling is correct | Wrong DNS responses break name resolution |
| NeSy type safety | Neurosymbolic type system is sound | NeSy Types.idr defines the neurosymbolic bridge — must be correct |
| Rust FFI bindings | All 9 FFI modules (dns, firewall, ftp, graphql, grpc, httpd, mqtt, smtp, ssh) correctly implement Idris2 ABI | FFI boundary bugs defeat proven guarantees |
| Server protocol compliance | Each protocol server (httpd, smtp, ssh, etc.) adheres to its RFC | Protocol violations cause interoperability failures |
| Firewall rule evaluation | Firewall rules evaluate correctly and completely | Missed rules create security gaps |
| NeSy believe_me-equivalent tracking | Track and minimize neurosymbolic escape hatches | The documented "believe_me equivalent" must be minimized |

## Recommended Prover

**Idris2** — ABI layer complete. DNS and NeSy protocol proofs are natural extensions. Server protocol RFC compliance could use **Lean4** for the specification-level proofs.

## Priority

**HIGH** — Server protocol implementations with security implications (firewall, SSH, SMTP, DNS). Incorrect protocol handling is a security vulnerability. The 9 Rust FFI modules are the critical boundary where proven guarantees could be lost.
