# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# App Server protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # App Server protocol types for proven-servers.
  module Appserver
    # RequestType matching the Idris2 ABI tags.
    module RequestType
      HTTP = 0
      WEB_SOCKET = 1
      GRPC = 2
      GRAPH_QL = 3
    end

    # LifecycleState matching the Idris2 ABI tags.
    module LifecycleState
      INITIALIZING = 0
      STARTING = 1
      RUNNING = 2
      DRAINING = 3
      STOPPING = 4
      STOPPED = 5
    end

    # HealthCheck matching the Idris2 ABI tags.
    module HealthCheck
      LIVENESS = 0
      READINESS = 1
      STARTUP = 2
    end

    # DeployStrategy matching the Idris2 ABI tags.
    module DeployStrategy
      ROLLING_UPDATE = 0
      BLUE_GREEN = 1
      CANARY = 2
      RECREATE = 3
    end

    # ErrorCategory matching the Idris2 ABI tags.
    module ErrorCategory
      CLIENT_ERROR = 0
      SERVER_ERROR = 1
      TIMEOUT = 2
      CIRCUIT_OPEN = 3
      RATE_LIMITED = 4
    end

  end
end
