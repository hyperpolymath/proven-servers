<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CT Log protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** LogEntryType matching the Idris2 ABI tags. */
enum LogEntryType: int
{
    case X509Entry = 0;
    case PrecertEntry = 1;
}

/** SignatureType matching the Idris2 ABI tags. */
enum SignatureType: int
{
    case CertificateTimestamp = 0;
    case TreeHash = 1;
}

/** MerkleLeafType matching the Idris2 ABI tags. */
enum MerkleLeafType: int
{
    case TimestampedEntry = 0;
}

/** SubmissionStatus matching the Idris2 ABI tags. */
enum SubmissionStatus: int
{
    case Accepted = 0;
    case Duplicate = 1;
    case RateLimited = 2;
    case Rejected = 3;
    case InvalidChain = 4;
    case UnknownAnchor = 5;
}

/** VerificationResult matching the Idris2 ABI tags. */
enum VerificationResult: int
{
    case ValidProof = 0;
    case InvalidProof = 1;
    case InconsistentTree = 2;
    case StaleSth = 3;
}

/** ServerState matching the Idris2 ABI tags. */
enum ServerState: int
{
    case Idle = 0;
    case Active = 1;
    case Merging = 2;
    case Signing = 3;
    case Shutdown = 4;
}
