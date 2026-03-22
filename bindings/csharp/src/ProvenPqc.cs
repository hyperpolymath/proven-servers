// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PQC protocol types for proven-servers.

namespace Proven;

/// <summary>PqcAlgorithm matching the Idris2 ABI tags (0-7).</summary>
public enum PqcAlgorithm : byte
{
    CrystalsKyber = 0,
    CrystalsDilithium = 1,
    Falcon = 2,
    SphincsPlus = 3,
    ClassicMceliece = 4,
    Bike = 5,
    Hqc = 6,
    Frodokem = 7
}

/// <summary>NistLevel matching the Idris2 ABI tags (0-4).</summary>
public enum NistLevel : byte
{
    Nist1 = 0,
    Nist2 = 1,
    Nist3 = 2,
    Nist4 = 3,
    Nist5 = 4
}

/// <summary>Operation matching the Idris2 ABI tags (0-4).</summary>
public enum Operation : byte
{
    Keygen = 0,
    Encapsulate = 1,
    Decapsulate = 2,
    Sign = 3,
    Verify = 4
}

/// <summary>HybridMode matching the Idris2 ABI tags (0-2).</summary>
public enum HybridMode : byte
{
    ClassicalOnly = 0,
    PqcOnly = 1,
    Hybrid = 2
}

/// <summary>AlgorithmCategory matching the Idris2 ABI tags (0-1).</summary>
public enum AlgorithmCategory : byte
{
    Kem = 0,
    Signature = 1
}

/// <summary>KeyState matching the Idris2 ABI tags (0-5).</summary>
public enum KeyState : byte
{
    Empty = 0,
    Generating = 1,
    Generated = 2,
    Active = 3,
    Expired = 4,
    Compromised = 5
}
