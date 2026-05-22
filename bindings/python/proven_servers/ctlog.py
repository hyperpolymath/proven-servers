# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-ctlog protocol types.

"""CT Log protocol types for proven-servers."""

from enum import IntEnum


class LogEntryType(IntEnum):
    """LogEntryType matching the Idris2 ABI tags."""
    X509_ENTRY = 0
    PRECERT_ENTRY = 1


class SignatureType(IntEnum):
    """SignatureType matching the Idris2 ABI tags."""
    CERTIFICATE_TIMESTAMP = 0
    TREE_HASH = 1


class MerkleLeafType(IntEnum):
    """MerkleLeafType matching the Idris2 ABI tags."""
    TIMESTAMPED_ENTRY = 0


class SubmissionStatus(IntEnum):
    """SubmissionStatus matching the Idris2 ABI tags."""
    ACCEPTED = 0
    DUPLICATE = 1
    RATE_LIMITED = 2
    REJECTED = 3
    INVALID_CHAIN = 4
    UNKNOWN_ANCHOR = 5


class VerificationResult(IntEnum):
    """VerificationResult matching the Idris2 ABI tags."""
    VALID_PROOF = 0
    INVALID_PROOF = 1
    INCONSISTENT_TREE = 2
    STALE_STH = 3


class ServerState(IntEnum):
    """ServerState matching the Idris2 ABI tags."""
    IDLE = 0
    ACTIVE = 1
    MERGING = 2
    SIGNING = 3
    SHUTDOWN = 4
