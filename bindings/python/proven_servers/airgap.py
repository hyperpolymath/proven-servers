# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-airgap protocol types.

"""Air Gap protocol types for proven-servers."""

from enum import IntEnum


class TransferDirection(IntEnum):
    """TransferDirection matching the Idris2 ABI tags."""
    IMPORT = 0
    EXPORT = 1


class MediaType(IntEnum):
    """MediaType matching the Idris2 ABI tags."""
    USB = 0
    OPTICAL_DISC = 1
    TAPE_CARTRIDGE = 2
    DIODE_LINK = 3


class ScanResult(IntEnum):
    """ScanResult matching the Idris2 ABI tags."""
    CLEAN = 0
    SUSPICIOUS = 1
    MALICIOUS = 2
    UNSCANNABLE = 3


class TransferState(IntEnum):
    """TransferState matching the Idris2 ABI tags."""
    PENDING = 0
    SCANNING = 1
    APPROVED = 2
    REJECTED = 3
    IN_PROGRESS = 4
    COMPLETE = 5
    FAILED = 6


class ValidationCheck(IntEnum):
    """ValidationCheck matching the Idris2 ABI tags."""
    HASH_VERIFY = 0
    SIGNATURE_VERIFY = 1
    FORMAT_CHECK = 2
    CONTENT_INSPECTION = 3
    MALWARE_SCAN = 4
