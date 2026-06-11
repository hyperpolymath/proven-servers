# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-backup protocol types.

"""Backup protocol types for proven-servers."""

from enum import IntEnum


class BackupType(IntEnum):
    """BackupType matching the Idris2 ABI tags."""
    FULL = 0
    INCREMENTAL = 1
    DIFFERENTIAL = 2
    SNAPSHOT = 3
    MIRROR = 4


class ScheduleFreq(IntEnum):
    """ScheduleFreq matching the Idris2 ABI tags."""
    HOURLY = 0
    DAILY = 1
    WEEKLY = 2
    MONTHLY = 3
    ON_DEMAND = 4


class CompressionAlg(IntEnum):
    """CompressionAlg matching the Idris2 ABI tags."""
    NONE = 0
    GZIP = 1
    ZSTD = 2
    LZ4 = 3
    XZ = 4


class EncryptionAlg(IntEnum):
    """EncryptionAlg matching the Idris2 ABI tags."""
    NO_ENCRYPTION = 0
    AES256_GCM = 1
    CHA_CHA20_POLY1305 = 2


class BackupState(IntEnum):
    """BackupState matching the Idris2 ABI tags."""
    IDLE = 0
    RUNNING = 1
    VERIFYING = 2
    COMPLETE = 3
    FAILED = 4
    CANCELLED = 5


class RetentionPolicy(IntEnum):
    """RetentionPolicy matching the Idris2 ABI tags."""
    KEEP_ALL = 0
    KEEP_LAST = 1
    KEEP_DAILY = 2
    KEEP_WEEKLY = 3
    KEEP_MONTHLY = 4
