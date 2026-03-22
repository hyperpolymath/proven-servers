# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# SDN protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # SDN protocol types for proven-servers.
  module Sdn
    # SdnMessageType matching the Idris2 ABI tags.
    module SdnMessageType
      HELLO = 0
      ERROR = 1
      ECHO_REQUEST = 2
      ECHO_REPLY = 3
      FEATURES_REQUEST = 4
      FEATURES_REPLY = 5
      FLOW_MOD = 6
      PACKET_IN = 7
      PACKET_OUT = 8
      PORT_STATUS = 9
      BARRIER_REQUEST = 10
      BARRIER_REPLY = 11
    end

    # FlowAction matching the Idris2 ABI tags.
    module FlowAction
      OUTPUT = 0
      SET_FIELD = 1
      DROP = 2
      PUSH_VLAN = 3
      POP_VLAN = 4
      SET_QUEUE = 5
      GROUP = 6
    end

    # MatchField matching the Idris2 ABI tags.
    module MatchField
      IN_PORT = 0
      ETH_DST = 1
      ETH_SRC = 2
      ETH_TYPE = 3
      VLAN_ID = 4
      IP_SRC = 5
      IP_DST = 6
      TCP_SRC = 7
      TCP_DST = 8
      UDP_SRC = 9
      UDP_DST = 10
    end

    # PortState matching the Idris2 ABI tags.
    module PortState
      UP = 0
      DOWN = 1
      BLOCKED = 2
    end

  end
end
