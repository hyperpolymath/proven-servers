// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Triplestore protocol types for proven-servers.

namespace Proven;

/// <summary>Statement matching the Idris2 ABI tags (0-1).</summary>
public enum Statement : byte
{
    Triple = 0,
    Quad = 1
}

/// <summary>IndexOrder matching the Idris2 ABI tags (0-5).</summary>
public enum IndexOrder : byte
{
    Spo = 0,
    Pos = 1,
    Osp = 2,
    Gspo = 3,
    Gpos = 4,
    Gosp = 5
}

/// <summary>StorageBackend matching the Idris2 ABI tags (0-3).</summary>
public enum StorageBackend : byte
{
    InMemory = 0,
    BTree = 1,
    Lsm = 2,
    Persistent = 3
}

/// <summary>ImportFormat matching the Idris2 ABI tags (0-5).</summary>
public enum ImportFormat : byte
{
    NTriples = 0,
    Turtle = 1,
    RdfXml = 2,
    JsonLd = 3,
    NQuads = 4,
    Trig = 5
}

/// <summary>TransactionIsolation matching the Idris2 ABI tags (0-2).</summary>
public enum TransactionIsolation : byte
{
    ReadCommitted = 0,
    Serializable = 1,
    Snapshot = 2
}

/// <summary>StoreState matching the Idris2 ABI tags (0-4).</summary>
public enum StoreState : byte
{
    Idle = 0,
    Ready = 1,
    InTransaction = 2,
    Importing = 3,
    Closing = 4
}
