# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# XMPP protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # XMPP protocol types for proven-servers.
  module Xmpp
    # StanzaType matching the Idris2 ABI tags.
    module StanzaType
      MESSAGE = 0
      PRESENCE = 1
      IQ = 2
    end

    # MessageType matching the Idris2 ABI tags.
    module MessageType
      CHAT = 0
      MESSAGE_TYPE_ERROR = 1
      GROUPCHAT = 2
      HEADLINE = 3
      NORMAL = 4
    end

    # PresenceType matching the Idris2 ABI tags.
    module PresenceType
      AVAILABLE = 0
      AWAY = 1
      DND = 2
      XA = 3
      UNAVAILABLE = 4
    end

    # IqType matching the Idris2 ABI tags.
    module IqType
      GET = 0
      SET = 1
      RESULT = 2
      IQ_TYPE_ERROR = 3
    end

    # StreamError matching the Idris2 ABI tags.
    module StreamError
      BAD_FORMAT = 0
      CONFLICT = 1
      CONNECTION_TIMEOUT = 2
      HOST_GONE = 3
      HOST_UNKNOWN = 4
      NOT_AUTHORIZED = 5
      POLICY_VIOLATION = 6
      RESOURCE_CONSTRAINT = 7
      SYSTEM_SHUTDOWN = 8
    end

  end
end
