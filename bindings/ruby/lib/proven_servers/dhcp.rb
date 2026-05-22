# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# DHCP protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # DHCP protocol types for proven-servers.
  module Dhcp
    # MessageType matching the Idris2 ABI tags.
    module MessageType
      DISCOVER = 0
      OFFER = 1
      REQUEST = 2
      ACK = 3
      NAK = 4
      RELEASE = 5
      INFORM = 6
      DECLINE = 7
    end

    # OptionCode matching the Idris2 ABI tags.
    module OptionCode
      SUBNET_MASK = 0
      ROUTER = 1
      DNS = 2
      DOMAIN_NAME = 3
      LEASE_TIME = 4
      SERVER_ID = 5
      REQUESTED_IP = 6
      MSG_TYPE = 7
    end

    # HardwareType matching the Idris2 ABI tags.
    module HardwareType
      ETHERNET = 0
      IEEE802 = 1
      ARCNET = 2
      FRAME_RELAY = 3
    end

    # DhcpState matching the Idris2 ABI tags.
    module DhcpState
      IDLE = 0
      DISCOVER_RECEIVED = 1
      OFFER_SENT = 2
      REQUEST_RECEIVED = 3
      ACK_SENT = 4
      NAK_SENT = 5
    end

    # LeaseState matching the Idris2 ABI tags.
    module LeaseState
      AVAILABLE = 0
      OFFERED = 1
      BOUND = 2
      RENEWING = 3
      REBINDING = 4
      EXPIRED = 5
    end

    # RelaySubOption matching the Idris2 ABI tags.
    module RelaySubOption
      CIRCUIT_ID = 0
      REMOTE_ID = 1
    end

  end
end
