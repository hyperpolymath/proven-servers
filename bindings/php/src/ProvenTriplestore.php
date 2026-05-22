<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Triplestore protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Statement matching the Idris2 ABI tags. */
enum Statement: int
{
    case Triple = 0;
    case Quad = 1;
}

/** IndexOrder matching the Idris2 ABI tags. */
enum IndexOrder: int
{
    case Spo = 0;
    case Pos = 1;
    case Osp = 2;
    case Gspo = 3;
    case Gpos = 4;
    case Gosp = 5;
}

/** StorageBackend matching the Idris2 ABI tags. */
enum StorageBackend: int
{
    case InMemory = 0;
    case BTree = 1;
    case Lsm = 2;
    case Persistent = 3;
}

/** ImportFormat matching the Idris2 ABI tags. */
enum ImportFormat: int
{
    case NTriples = 0;
    case Turtle = 1;
    case RdfXml = 2;
    case JsonLd = 3;
    case NQuads = 4;
    case Trig = 5;
}

/** TransactionIsolation matching the Idris2 ABI tags. */
enum TransactionIsolation: int
{
    case ReadCommitted = 0;
    case Serializable = 1;
    case Snapshot = 2;
}

/** StoreState matching the Idris2 ABI tags. */
enum StoreState: int
{
    case Idle = 0;
    case Ready = 1;
    case InTransaction = 2;
    case Importing = 3;
    case Closing = 4;
}
