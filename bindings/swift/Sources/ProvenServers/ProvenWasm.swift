// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WASM protocol types for proven-servers.

/// ValType matching the Idris2 ABI tags.
public enum ValType: UInt8, CaseIterable, Sendable {
    case i32 = 0
    case i64 = 1
    case f32 = 2
    case f64 = 3
    case v128 = 4
    case funcRef = 5
    case externRef = 6
}

/// ExternKind matching the Idris2 ABI tags.
public enum ExternKind: UInt8, CaseIterable, Sendable {
    case funcExtern = 0
    case tableExtern = 1
    case memExtern = 2
    case globalExtern = 3
}

/// Mutability matching the Idris2 ABI tags.
public enum Mutability: UInt8, CaseIterable, Sendable {
    case immutable = 0
    case mutable = 1
}
