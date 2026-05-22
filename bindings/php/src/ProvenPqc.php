<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PQC protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** PqcAlgorithm matching the Idris2 ABI tags. */
enum PqcAlgorithm: int
{
    case CrystalsKyber = 0;
    case CrystalsDilithium = 1;
    case Falcon = 2;
    case SphincsPlus = 3;
    case ClassicMceliece = 4;
    case Bike = 5;
    case Hqc = 6;
    case Frodokem = 7;
}

/** NistLevel matching the Idris2 ABI tags. */
enum NistLevel: int
{
    case Nist1 = 0;
    case Nist2 = 1;
    case Nist3 = 2;
    case Nist4 = 3;
    case Nist5 = 4;
}

/** Operation matching the Idris2 ABI tags. */
enum Operation: int
{
    case Keygen = 0;
    case Encapsulate = 1;
    case Decapsulate = 2;
    case Sign = 3;
    case Verify = 4;
}

/** HybridMode matching the Idris2 ABI tags. */
enum HybridMode: int
{
    case ClassicalOnly = 0;
    case PqcOnly = 1;
    case Hybrid = 2;
}

/** AlgorithmCategory matching the Idris2 ABI tags. */
enum AlgorithmCategory: int
{
    case Kem = 0;
    case Signature = 1;
}

/** KeyState matching the Idris2 ABI tags. */
enum KeyState: int
{
    case Empty = 0;
    case Generating = 1;
    case Generated = 2;
    case Active = 3;
    case Expired = 4;
    case Compromised = 5;
}
