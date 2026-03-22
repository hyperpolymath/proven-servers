// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file backup.hpp
/// @brief Backup protocol types for proven-servers.

#ifndef PROVEN_BACKUP_HPP
#define PROVEN_BACKUP_HPP

#include <cstdint>

namespace proven {

/// @brief BackupType matching the Idris2 ABI tags.
enum class BackupType : uint8_t {
    Full = 0,
    Incremental = 1,
    Differential = 2,
    Snapshot = 3,
    Mirror = 4
};

/// @brief ScheduleFreq matching the Idris2 ABI tags.
enum class ScheduleFreq : uint8_t {
    Hourly = 0,
    Daily = 1,
    Weekly = 2,
    Monthly = 3,
    OnDemand = 4
};

/// @brief CompressionAlg matching the Idris2 ABI tags.
enum class CompressionAlg : uint8_t {
    None = 0,
    Gzip = 1,
    Zstd = 2,
    Lz4 = 3,
    Xz = 4
};

/// @brief EncryptionAlg matching the Idris2 ABI tags.
enum class EncryptionAlg : uint8_t {
    NoEncryption = 0,
    Aes256Gcm = 1,
    ChaCha20Poly1305 = 2
};

/// @brief BackupState matching the Idris2 ABI tags.
enum class BackupState : uint8_t {
    Idle = 0,
    Running = 1,
    Verifying = 2,
    Complete = 3,
    Failed = 4,
    Cancelled = 5
};

/// @brief RetentionPolicy matching the Idris2 ABI tags.
enum class RetentionPolicy : uint8_t {
    KeepAll = 0,
    KeepLast = 1,
    KeepDaily = 2,
    KeepWeekly = 3,
    KeepMonthly = 4
};

} // namespace proven

#endif // PROVEN_BACKUP_HPP
