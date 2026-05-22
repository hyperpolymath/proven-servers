// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Backup protocol types for proven-servers.

/// BackupType matching the Idris2 ABI tags.
public enum BackupType: UInt8, CaseIterable, Sendable {
    case full = 0
    case incremental = 1
    case differential = 2
    case snapshot = 3
    case mirror = 4
}

/// ScheduleFreq matching the Idris2 ABI tags.
public enum ScheduleFreq: UInt8, CaseIterable, Sendable {
    case hourly = 0
    case daily = 1
    case weekly = 2
    case monthly = 3
    case onDemand = 4
}

/// CompressionAlg matching the Idris2 ABI tags.
public enum CompressionAlg: UInt8, CaseIterable, Sendable {
    case none = 0
    case gzip = 1
    case zstd = 2
    case lz4 = 3
    case xz = 4
}

/// EncryptionAlg matching the Idris2 ABI tags.
public enum EncryptionAlg: UInt8, CaseIterable, Sendable {
    case noEncryption = 0
    case aes256Gcm = 1
    case chaCha20Poly1305 = 2
}

/// BackupState matching the Idris2 ABI tags.
public enum BackupState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case running = 1
    case verifying = 2
    case complete = 3
    case failed = 4
    case cancelled = 5
}

/// RetentionPolicy matching the Idris2 ABI tags.
public enum RetentionPolicy: UInt8, CaseIterable, Sendable {
    case keepAll = 0
    case keepLast = 1
    case keepDaily = 2
    case keepWeekly = 3
    case keepMonthly = 4
}
