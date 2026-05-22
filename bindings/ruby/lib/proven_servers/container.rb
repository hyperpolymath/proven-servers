# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Container protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Container protocol types for proven-servers.
  module Container
    # ContainerState matching the Idris2 ABI tags.
    module ContainerState
      CREATING = 0
      RUNNING = 1
      PAUSED = 2
      RESTARTING = 3
      STOPPED = 4
      REMOVING = 5
      DEAD = 6
    end

    # ContainerOperation matching the Idris2 ABI tags.
    module ContainerOperation
      CREATE = 0
      START = 1
      STOP = 2
      RESTART = 3
      PAUSE = 4
      UNPAUSE = 5
      KILL = 6
      REMOVE = 7
      EXEC = 8
      LOGS = 9
      INSPECT = 10
    end

    # NetworkMode matching the Idris2 ABI tags.
    module NetworkMode
      BRIDGE = 0
      HOST = 1
      NONE = 2
      OVERLAY = 3
      MACVLAN = 4
    end

    # VolumeType matching the Idris2 ABI tags.
    module VolumeType
      BIND = 0
      NAMED = 1
      TMPFS = 2
    end

    # RestartPolicy matching the Idris2 ABI tags.
    module RestartPolicy
      NO = 0
      ALWAYS = 1
      ON_FAILURE = 2
      UNLESS_STOPPED = 3
    end

    # HealthStatus matching the Idris2 ABI tags.
    module HealthStatus
      STARTING = 0
      HEALTHY = 1
      UNHEALTHY = 2
      NO_CHECK = 3
    end

  end
end
