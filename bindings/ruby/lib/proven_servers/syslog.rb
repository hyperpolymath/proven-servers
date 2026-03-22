# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Syslog protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Syslog protocol types for proven-servers.
  module Syslog
    # Severity matching the Idris2 ABI tags.
    module Severity
      EMERGENCY = 0
      SEVERITY_ALERT = 1
      CRITICAL = 2
      ERROR = 3
      WARNING = 4
      NOTICE = 5
      INFORMATIONAL = 6
      DEBUG = 7
    end

    # Facility matching the Idris2 ABI tags.
    module Facility
      KERN = 0
      USER = 1
      MAIL = 2
      DAEMON = 3
      AUTH = 4
      SYSLOG = 5
      LPR = 6
      NEWS = 7
      UUCP = 8
      CRON = 9
      AUTH_PRIV = 10
      FTP = 11
      NTP = 12
      AUDIT = 13
      FACILITY_ALERT = 14
      CLOCK = 15
      LOCAL0 = 16
      LOCAL1 = 17
      LOCAL2 = 18
      LOCAL3 = 19
      LOCAL4 = 20
      LOCAL5 = 21
      LOCAL6 = 22
      LOCAL7 = 23
    end

    # Transport matching the Idris2 ABI tags.
    module Transport
      UDP514 = 0
      TCP514 = 1
      TLS6514 = 2
    end

  end
end
