<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Backup protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** BackupType matching the Idris2 ABI tags. */
enum BackupType: int
{
    case Full = 0;
    case Incremental = 1;
    case Differential = 2;
    case Snapshot = 3;
    case Mirror = 4;
}

/** ScheduleFreq matching the Idris2 ABI tags. */
enum ScheduleFreq: int
{
    case Hourly = 0;
    case Daily = 1;
    case Weekly = 2;
    case Monthly = 3;
    case OnDemand = 4;
}

/** CompressionAlg matching the Idris2 ABI tags. */
enum CompressionAlg: int
{
    case None = 0;
    case Gzip = 1;
    case Zstd = 2;
    case Lz4 = 3;
    case Xz = 4;
}

/** EncryptionAlg matching the Idris2 ABI tags. */
enum EncryptionAlg: int
{
    case NoEncryption = 0;
    case Aes256Gcm = 1;
    case ChaCha20Poly1305 = 2;
}

/** BackupState matching the Idris2 ABI tags. */
enum BackupState: int
{
    case Idle = 0;
    case Running = 1;
    case Verifying = 2;
    case Complete = 3;
    case Failed = 4;
    case Cancelled = 5;
}

/** RetentionPolicy matching the Idris2 ABI tags. */
enum RetentionPolicy: int
{
    case KeepAll = 0;
    case KeepLast = 1;
    case KeepDaily = 2;
    case KeepWeekly = 3;
    case KeepMonthly = 4;
}
