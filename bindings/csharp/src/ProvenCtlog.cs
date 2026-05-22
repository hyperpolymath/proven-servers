// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CT Log protocol types for proven-servers.

namespace Proven;

/// <summary>LogEntryType matching the Idris2 ABI tags (0-1).</summary>
public enum LogEntryType : byte
{
    X509Entry = 0,
    PrecertEntry = 1
}

/// <summary>SignatureType matching the Idris2 ABI tags (0-1).</summary>
public enum SignatureType : byte
{
    CertificateTimestamp = 0,
    TreeHash = 1
}

/// <summary>MerkleLeafType matching the Idris2 ABI tags (0-0).</summary>
public enum MerkleLeafType : byte
{
    TimestampedEntry = 0
}

/// <summary>SubmissionStatus matching the Idris2 ABI tags (0-5).</summary>
public enum SubmissionStatus : byte
{
    Accepted = 0,
    Duplicate = 1,
    RateLimited = 2,
    Rejected = 3,
    InvalidChain = 4,
    UnknownAnchor = 5
}

/// <summary>VerificationResult matching the Idris2 ABI tags (0-3).</summary>
public enum VerificationResult : byte
{
    ValidProof = 0,
    InvalidProof = 1,
    InconsistentTree = 2,
    StaleSth = 3
}

/// <summary>ServerState matching the Idris2 ABI tags (0-4).</summary>
public enum ServerState : byte
{
    Idle = 0,
    Active = 1,
    Merging = 2,
    Signing = 3,
    Shutdown = 4
}
