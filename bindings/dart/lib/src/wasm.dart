// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WASM protocol types for proven-servers.

/// ValType matching the Idris2 ABI tags.
enum ValType {
  i32(0),
  i64(1),
  f32(2),
  f64(3),
  v128(4),
  funcRef(5),
  externRef(6);

  const ValType(this.tag);
  final int tag;

  static ValType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ExternKind matching the Idris2 ABI tags.
enum ExternKind {
  funcExtern(0),
  tableExtern(1),
  memExtern(2),
  globalExtern(3);

  const ExternKind(this.tag);
  final int tag;

  static ExternKind? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Mutability matching the Idris2 ABI tags.
enum Mutability {
  immutable(0),
  mutable(1);

  const Mutability(this.tag);
  final int tag;

  static Mutability? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
