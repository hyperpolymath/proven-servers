// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file airgap.hpp
/// @brief Air Gap protocol types for proven-servers.

#ifndef PROVEN_AIRGAP_HPP
#define PROVEN_AIRGAP_HPP

#include <cstdint>

namespace proven {

/// @brief TransferDirection matching the Idris2 ABI tags.
enum class TransferDirection : uint8_t {
    Import = 0,
    Export = 1
};

/// @brief MediaType matching the Idris2 ABI tags.
enum class MediaType : uint8_t {
    Usb = 0,
    OpticalDisc = 1,
    TapeCartridge = 2,
    DiodeLink = 3
};

/// @brief ScanResult matching the Idris2 ABI tags.
enum class ScanResult : uint8_t {
    Clean = 0,
    Suspicious = 1,
    Malicious = 2,
    Unscannable = 3
};

/// @brief TransferState matching the Idris2 ABI tags.
enum class TransferState : uint8_t {
    Pending = 0,
    Scanning = 1,
    Approved = 2,
    Rejected = 3,
    InProgress = 4,
    Complete = 5,
    Failed = 6
};

/// @brief ValidationCheck matching the Idris2 ABI tags.
enum class ValidationCheck : uint8_t {
    HashVerify = 0,
    SignatureVerify = 1,
    FormatCheck = 2,
    ContentInspection = 3,
    MalwareScan = 4
};

} // namespace proven

#endif // PROVEN_AIRGAP_HPP
