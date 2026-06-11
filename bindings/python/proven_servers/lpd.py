# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-lpd protocol types.

"""LPD protocol types for proven-servers."""

from enum import IntEnum


class CommandCode(IntEnum):
    """CommandCode matching the Idris2 ABI tags."""
    PRINT_JOB = 1
    RECEIVE_JOB = 2
    SHORT_QUEUE = 3
    LONG_QUEUE = 4
    REMOVE_JOBS = 5


class SubCommandCode(IntEnum):
    """SubCommandCode matching the Idris2 ABI tags."""
    ABORT_JOB = 1
    CONTROL_FILE = 2
    DATA_FILE = 3


class JobStatus(IntEnum):
    """JobStatus matching the Idris2 ABI tags."""
    PENDING = 0
    PRINTING = 1
    COMPLETE = 2
    FAILED = 3
