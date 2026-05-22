// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file ctlog.hpp
/// @brief CT Log protocol types for proven-servers.

#ifndef PROVEN_CTLOG_HPP
#define PROVEN_CTLOG_HPP

#include <cstdint>

namespace proven {

/// @brief LogEntryType matching the Idris2 ABI tags.
enum class LogEntryType : uint8_t {
    X509Entry = 0,
    PrecertEntry = 1
};

/// @brief SignatureType matching the Idris2 ABI tags.
enum class SignatureType : uint8_t {
    CertificateTimestamp = 0,
    TreeHash = 1
};

/// @brief MerkleLeafType matching the Idris2 ABI tags.
enum class MerkleLeafType : uint8_t {
    TimestampedEntry = 0
};

/// @brief SubmissionStatus matching the Idris2 ABI tags.
enum class SubmissionStatus : uint8_t {
    Accepted = 0,
    Duplicate = 1,
    RateLimited = 2,
    Rejected = 3,
    InvalidChain = 4,
    UnknownAnchor = 5
};

/// @brief VerificationResult matching the Idris2 ABI tags.
enum class VerificationResult : uint8_t {
    ValidProof = 0,
    InvalidProof = 1,
    InconsistentTree = 2,
    StaleSth = 3
};

/// @brief ServerState matching the Idris2 ABI tags.
enum class ServerState : uint8_t {
    Idle = 0,
    Active = 1,
    Merging = 2,
    Signing = 3,
    Shutdown = 4
};

} // namespace proven

#endif // PROVEN_CTLOG_HPP
