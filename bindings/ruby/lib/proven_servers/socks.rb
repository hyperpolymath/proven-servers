# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# SOCKS5 protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # SOCKS5 protocol types for proven-servers.
  module Socks
    # AuthMethod matching the Idris2 ABI tags.
    module AuthMethod
      NO_AUTH = 0
      GSSAPI = 1
      USERNAME_PASSWORD = 2
      NO_ACCEPTABLE = 3
    end

    # Command matching the Idris2 ABI tags.
    module Command
      CONNECT = 0
      BIND = 1
      UDP_ASSOCIATE = 2
    end

    # AddressType matching the Idris2 ABI tags.
    module AddressType
      I_PV4 = 0
      DOMAIN_NAME = 1
      I_PV6 = 2
    end

    # Reply matching the Idris2 ABI tags.
    module Reply
      SUCCEEDED = 0
      GENERAL_FAILURE = 1
      NOT_ALLOWED = 2
      NETWORK_UNREACHABLE = 3
      HOST_UNREACHABLE = 4
      CONNECTION_REFUSED = 5
      TTL_EXPIRED = 6
      COMMAND_NOT_SUPPORTED = 7
      ADDRESS_TYPE_NOT_SUPPORTED = 8
    end

    # State matching the Idris2 ABI tags.
    module State
      INITIAL = 0
      AUTHENTICATING = 1
      AUTHENTICATED = 2
      CONNECTING = 3
      ESTABLISHED = 4
      CLOSED = 5
    end

  end
end
