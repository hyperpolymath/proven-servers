# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-caldav protocol types.

"""CalDAV protocol types for proven-servers."""

from enum import IntEnum


class ComponentType(IntEnum):
    """ComponentType matching the Idris2 ABI tags."""
    VEVENT = 0
    VTODO = 1
    VJOURNAL = 2
    VFREEBUSY = 3


class CalMethod(IntEnum):
    """CalMethod matching the Idris2 ABI tags."""
    GET = 0
    PUT = 1
    DELETE = 2
    PROPFIND = 3
    PROPPATCH = 4
    REPORT = 5
    MKCALENDAR = 6


class ScheduleStatus(IntEnum):
    """ScheduleStatus matching the Idris2 ABI tags."""
    NEEDS_ACTION = 0
    ACCEPTED = 1
    DECLINED = 2
    TENTATIVE = 3
    DELEGATED = 4


class CalError(IntEnum):
    """CalError matching the Idris2 ABI tags."""
    VALID_CALENDAR_DATA = 0
    NO_RESOURCE_TYPE_CHANGE = 1
    SUPPORTED_COMPONENT_MISMATCH = 2
    MAX_RESOURCE_SIZE = 3
    UID_CONFLICT = 4
    PRECONDITION_FAILED = 5


class ServerState(IntEnum):
    """ServerState matching the Idris2 ABI tags."""
    IDLE = 0
    BOUND = 1
    SERVING = 2
    SCHEDULING = 3
    SHUTDOWN = 4
