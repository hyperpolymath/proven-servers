<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- TOPOLOGY.md — proven-servers architecture map and completion dashboard -->
<!-- Last updated: 2026-03-01 -->

# proven-servers — Project Topology

## System Architecture

```
                ┌─────────────────────────────────────────────────────────┐
                │                   PROVEN-SERVERS                        │
                │     108 Formally Verified Server Components             │
                └───────────────────────┬─────────────────────────────────┘
                                        │
              ┌─────────────────────────┼─────────────────────────┐
              │                         │                         │
              ▼                         ▼                         ▼
  ┌───────────────────┐   ┌───────────────────┐   ┌───────────────────┐
  │  CORE PRIMITIVES  │   │    PROTOCOLS       │   │   CONNECTORS      │
  │  (8 components)   │   │  (94 skeletons)    │   │  (6 interfaces)   │
  │                   │   │                    │   │                    │
  │  socket  frame    │   │  dns   smtp  httpd │   │  dbconn    authconn│
  │  fsm     wire     │   │  mqtt  bgp   tls   │   │  cacheconn queueconn│
  │  compose tls      │   │  irc   ldap  ftp   │   │  resolverconn     │
  │  config  audit    │   │  ... (91 more)     │   │  storageconn      │
  └─────────┬─────────┘   └────────┬───────────┘   └────────┬──────────┘
            │                      │                         │
            └──────────────────────┼─────────────────────────┘
                                   │
                                   ▼
                ┌─────────────────────────────────────────────────────────┐
                │                ABI-FFI LAYER                            │
                │                                                         │
                │  ┌─────────────┐  ┌────────────┐  ┌─────────────────┐  │
                │  │  Idris2 ABI │  │  C Headers  │  │  Zig FFI        │  │
                │  │  (proofs)   │──│  (generated) │──│  (runtime)      │  │
                │  │             │  │             │  │                 │  │
                │  │  Layout     │  │  tag #defs  │  │  enum(u8)       │  │
                │  │  Transitions│  │  opaques    │  │  handle structs │  │
                │  │  Foreign    │  │  fn decls   │  │  callconv(.c)   │  │
                │  └─────────────┘  └────────────┘  └─────────────────┘  │
                └───────────────────────┬─────────────────────────────────┘
                                        │
                                        ▼
                ┌─────────────────────────────────────────────────────────┐
                │              LANGUAGE BINDINGS                           │
                │  Rust · ReScript · Gleam · Elixir · Haskell · OCaml    │
                │  Ada · Julia · C/Zig (free) · (any C-ABI language)     │
                └───────────────────────┬─────────────────────────────────┘
                                        │
                                        ▼
                ┌─────────────────────────────────────────────────────────┐
                │              CONSUMERS                                  │
                │  PanLL VAB · stapeln containers · user applications     │
                └─────────────────────────────────────────────────────────┘
```

## Completion Dashboard

```
COMPONENT                              STATUS              NOTES
─────────────────────────────────────  ──────────────────  ──────────────────────────────

PROTOCOL SKELETONS (94)
  Type definitions (Types.idr)           ██████████ 100%    All 94 protocols have types
  State machines (Idris2 proofs)         ░░░░░░░░░░   0%    Not yet started
  ABI-FFI (Zig + C headers)             ░░░░░░░░░░   0%    Not yet started
  Language bindings                      ░░░░░░░░░░   0%    Not yet started

CORE PRIMITIVES (8)
  Type definitions (Types.idr)           ██████████ 100%    socket, frame, fsm, wire,
                                                            compose, tls, config, audit
  State machines (Idris2 proofs)         ░░░░░░░░░░   0%    Not yet started
  ABI-FFI (Zig + C headers)             ░░░░░░░░░░   0%    Not yet started
  Language bindings                      ░░░░░░░░░░   0%    Not yet started

CONNECTORS (6)
  Type definitions (Types.idr)           ██████████ 100%    dbconn, authconn, cacheconn,
                                                            queueconn, resolverconn,
                                                            storageconn
  ABI: Layout.idr (tag encodings)        ██████████ 100%    All 6 — roundtrip proofs ✓
  ABI: Transitions.idr (state machines)  ██████████ 100%    All 6 — GADTs + witnesses ✓
  ABI: Foreign.idr (FFI contract)        ██████████ 100%    All 6 — opaque handles ✓
  C Headers (generated)                  ██████████ 100%    All 6 — tag #defines + decls
  Zig FFI (runtime enforcement)          ██████████ 100%    All 6 — build clean ✓
  Zig Tests (integration)                ██████████ 100%    All 6 — 76+ tests pass ✓
  Language bindings                      ░░░░░░░░░░   0%    Not yet started

INFRASTRUCTURE
  Repository scaffolding (RSR)           ██████████ 100%    Justfile, CI, governance
  Documentation                          ██████████ 100%    Design docs, READMEs, TOPOLOGY
  Machine-readable metadata              ██████████ 100%    STATE, ECOSYSTEM, META (.a2ml)
  CI/CD (Zig builds)                     ░░░░░░░░░░   0%    Not yet in GitHub Actions
  CI/CD (Idris2 type-checking)           ░░░░░░░░░░   0%    Not yet in GitHub Actions

─────────────────────────────────────────────────────────────────────────────────────────
OVERALL:                                 ███░░░░░░░  35%    Connector ABI-FFI complete;
                                                            core and protocols pending
```

## Key Dependencies

```
Idris2 compiler ───► ABI definitions ───► C header generation ───► Zig FFI
       │                    │                     │                    │
       ▼                    ▼                     ▼                    ▼
  Type proofs         Tag encodings          #define tags         enum(u8) types
  State machines      Roundtrip proofs       Opaque structs       Handle structs
  Capabilities        Impossibility proofs   Function decls       callconv(.c) fns
                                                                      │
                                                                      ▼
                                                               Language bindings
                                                            (Rust, ReScript, etc.)
                                                                      │
                                                                      ▼
                                                              PanLL VAB panel
                                                            (visual composition)
```

## Update Protocol

This file is maintained by both humans and AI agents. When updating:

1. **After completing a component**: Change its bar and percentage
2. **After adding a component**: Add a new row in the appropriate section
3. **After architectural changes**: Update the ASCII diagram
4. **Date**: Update the `Last updated` comment at the top of this file

Progress bars use: `█` (filled) and `░` (empty), 10 characters wide.
Percentages: 0%, 10%, 20%, ... 100% (in 10% increments).
