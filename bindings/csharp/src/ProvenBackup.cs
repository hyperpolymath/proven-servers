// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Backup protocol types for proven-servers.

namespace Proven;

/// <summary>BackupType matching the Idris2 ABI tags (0-4).</summary>
public enum BackupType : byte
{
    Full = 0,
    Incremental = 1,
    Differential = 2,
    Snapshot = 3,
    Mirror = 4
}

/// <summary>ScheduleFreq matching the Idris2 ABI tags (0-4).</summary>
public enum ScheduleFreq : byte
{
    Hourly = 0,
    Daily = 1,
    Weekly = 2,
    Monthly = 3,
    OnDemand = 4
}

/// <summary>CompressionAlg matching the Idris2 ABI tags (0-4).</summary>
public enum CompressionAlg : byte
{
    None = 0,
    Gzip = 1,
    Zstd = 2,
    Lz4 = 3,
    Xz = 4
}

/// <summary>EncryptionAlg matching the Idris2 ABI tags (0-2).</summary>
public enum EncryptionAlg : byte
{
    NoEncryption = 0,
    Aes256Gcm = 1,
    ChaCha20Poly1305 = 2
}

/// <summary>BackupState matching the Idris2 ABI tags (0-5).</summary>
public enum BackupState : byte
{
    Idle = 0,
    Running = 1,
    Verifying = 2,
    Complete = 3,
    Failed = 4,
    Cancelled = 5
}

/// <summary>RetentionPolicy matching the Idris2 ABI tags (0-4).</summary>
public enum RetentionPolicy : byte
{
    KeepAll = 0,
    KeepLast = 1,
    KeepDaily = 2,
    KeepWeekly = 3,
    KeepMonthly = 4
}
