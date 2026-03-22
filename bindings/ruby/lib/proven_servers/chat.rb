# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Chat protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Chat protocol types for proven-servers.
  module Chat
    # MessageType matching the Idris2 ABI tags.
    module MessageType
      TEXT = 0
      IMAGE = 1
      FILE = 2
      SYSTEM = 3
      REACTION = 4
      EDIT = 5
      DELETE = 6
      REPLY = 7
      THREAD = 8
    end

    # PresenceStatus matching the Idris2 ABI tags.
    module PresenceStatus
      ONLINE = 0
      AWAY = 1
      DND = 2
      INVISIBLE = 3
      OFFLINE = 4
    end

    # RoomType matching the Idris2 ABI tags.
    module RoomType
      DIRECT = 0
      GROUP = 1
      CHANNEL = 2
      BROADCAST = 3
    end

    # Permission matching the Idris2 ABI tags.
    module Permission
      READ = 0
      WRITE = 1
      ADMIN = 2
      INVITE = 3
      KICK = 4
      BAN = 5
      PIN = 6
      DELETE_OTHERS = 7
    end

    # Event matching the Idris2 ABI tags.
    module Event
      MESSAGE_SENT = 0
      MESSAGE_DELIVERED = 1
      MESSAGE_READ = 2
      USER_JOINED = 3
      USER_LEFT = 4
      TYPING = 5
      ROOM_CREATED = 6
    end

  end
end
