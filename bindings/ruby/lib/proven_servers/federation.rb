# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Federation protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Federation protocol types for proven-servers.
  module Federation
    # ActivityType matching the Idris2 ABI tags.
    module ActivityType
      CREATE = 0
      UPDATE = 1
      DELETE = 2
      FOLLOW = 3
      ACCEPT = 4
      REJECT = 5
      ANNOUNCE = 6
      LIKE = 7
      UNDO = 8
      BLOCK = 9
      FLAG = 10
    end

    # ActorType matching the Idris2 ABI tags.
    module ActorType
      PERSON = 0
      SERVICE = 1
      APPLICATION = 2
      GROUP = 3
      ORGANIZATION = 4
    end

    # DeliveryStatus matching the Idris2 ABI tags.
    module DeliveryStatus
      PENDING = 0
      DELIVERED = 1
      FAILED = 2
      REJECTED = 3
      DEFERRED = 4
    end

    # TrustLevel matching the Idris2 ABI tags.
    module TrustLevel
      SELF_SIGNED = 0
      PEER_VERIFIED = 1
      FEDERATION_TRUSTED = 2
      REVOKED = 3
      UNKNOWN = 4
    end

    # ObjectType matching the Idris2 ABI tags.
    module ObjectType
      NOTE = 0
      ARTICLE = 1
      IMAGE = 2
      VIDEO = 3
      AUDIO = 4
      DOCUMENT = 5
      EVENT = 6
      COLLECTION = 7
      ORDERED_COLLECTION = 8
    end

    # ServerState matching the Idris2 ABI tags.
    module ServerState
      IDLE = 0
      ACTIVE = 1
      PROCESSING = 2
      DELIVERING = 3
      SHUTDOWN = 4
    end

  end
end
