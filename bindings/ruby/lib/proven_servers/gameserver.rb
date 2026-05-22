# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Game Server protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Game Server protocol types for proven-servers.
  module Gameserver
    # SessionType matching the Idris2 ABI tags.
    module SessionType
      LOBBY = 0
      MATCH = 1
      PRACTICE = 2
      SPECTATOR = 3
      TOURNAMENT = 4
    end

    # PlayerState matching the Idris2 ABI tags.
    module PlayerState
      IDLE = 0
      QUEUING = 1
      LOADING = 2
      PLAYING = 3
      SPECTATING = 4
      DISCONNECTED = 5
    end

    # MatchState matching the Idris2 ABI tags.
    module MatchState
      WAITING = 0
      STARTING = 1
      IN_PROGRESS = 2
      PAUSED = 3
      ENDING = 4
      COMPLETE = 5
    end

  end
end
