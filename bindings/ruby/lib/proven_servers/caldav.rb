# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# CalDAV protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # CalDAV protocol types for proven-servers.
  module Caldav
    # ComponentType matching the Idris2 ABI tags.
    module ComponentType
      VEVENT = 0
      VTODO = 1
      VJOURNAL = 2
      VFREEBUSY = 3
    end

    # CalMethod matching the Idris2 ABI tags.
    module CalMethod
      GET = 0
      PUT = 1
      DELETE = 2
      PROPFIND = 3
      PROPPATCH = 4
      REPORT = 5
      MKCALENDAR = 6
    end

    # ScheduleStatus matching the Idris2 ABI tags.
    module ScheduleStatus
      NEEDS_ACTION = 0
      ACCEPTED = 1
      DECLINED = 2
      TENTATIVE = 3
      DELEGATED = 4
    end

    # CalError matching the Idris2 ABI tags.
    module CalError
      VALID_CALENDAR_DATA = 0
      NO_RESOURCE_TYPE_CHANGE = 1
      SUPPORTED_COMPONENT_MISMATCH = 2
      MAX_RESOURCE_SIZE = 3
      UID_CONFLICT = 4
      PRECONDITION_FAILED = 5
    end

    # ServerState matching the Idris2 ABI tags.
    module ServerState
      IDLE = 0
      BOUND = 1
      SERVING = 2
      SCHEDULING = 3
      SHUTDOWN = 4
    end

  end
end
