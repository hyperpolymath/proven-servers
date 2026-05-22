# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# DDS protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # DDS protocol types for proven-servers.
  module Dds
    # ReliabilityKind matching the Idris2 ABI tags.
    module ReliabilityKind
      BEST_EFFORT = 0
      RELIABLE = 1
    end

    # DurabilityKind matching the Idris2 ABI tags.
    module DurabilityKind
      TRANSIENT_LOCAL = 1
      TRANSIENT = 2
      PERSISTENT = 3
    end

    # HistoryKind matching the Idris2 ABI tags.
    module HistoryKind
      KEEP_LAST = 0
      KEEP_ALL = 1
    end

    # OwnershipKind matching the Idris2 ABI tags.
    module OwnershipKind
      SHARED = 0
      EXCLUSIVE = 1
    end

    # EntityType matching the Idris2 ABI tags.
    module EntityType
      PARTICIPANT = 0
      PUBLISHER = 1
      SUBSCRIBER = 2
      TOPIC = 3
      DATA_WRITER = 4
      DATA_READER = 5
    end

    # ParticipantState matching the Idris2 ABI tags.
    module ParticipantState
      IDLE = 0
      JOINED = 1
      PUBLISHING = 2
      SUBSCRIBING = 3
      LEAVING = 4
    end

  end
end
