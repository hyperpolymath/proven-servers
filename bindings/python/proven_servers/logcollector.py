# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-logcollector protocol types.

"""Log Collector protocol types for proven-servers."""

from enum import IntEnum


class LogLevel(IntEnum):
    """LogLevel matching the Idris2 ABI tags."""
    TRACE = 0
    DEBUG = 1
    INFO = 2
    WARN = 3
    ERR = 4
    FATAL = 5


class InputFormat(IntEnum):
    """InputFormat matching the Idris2 ABI tags."""
    JSON = 0
    LOGFMT = 1
    SYSLOG = 2
    CEF = 3
    GELF = 4
    RAW = 5


class OutputTarget(IntEnum):
    """OutputTarget matching the Idris2 ABI tags."""
    FILE = 0
    ELASTICSEARCH = 1
    S3 = 2
    KAFKA = 3
    STDOUT = 4


class FilterOp(IntEnum):
    """FilterOp matching the Idris2 ABI tags."""
    INCLUDE = 0
    EXCLUDE = 1
    TRANSFORM = 2
    REDACT = 3
    SAMPLE = 4


class PipelineStage(IntEnum):
    """PipelineStage matching the Idris2 ABI tags."""
    INPUT = 0
    PARSE = 1
    FILTER = 2
    PIPELINE_TRANSFORM = 3
    OUTPUT = 4
