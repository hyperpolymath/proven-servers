# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Load Balancer protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Load Balancer protocol types for proven-servers.
  module Loadbalancer
    # Algorithm matching the Idris2 ABI tags.
    module Algorithm
      ROUND_ROBIN = 0
      LEAST_CONNECTIONS = 1
      IP_HASH = 2
      RANDOM = 3
      WEIGHTED_ROUND_ROBIN = 4
      LEAST_RESPONSE_TIME = 5
    end

    # HealthCheckType matching the Idris2 ABI tags.
    module HealthCheckType
      HEALTH_CHECK_TYPE_HTTP = 0
      HEALTH_CHECK_TYPE_TCP = 1
      HEALTH_CHECK_TYPE_GRPC = 2
      SCRIPT = 3
    end

    # BackendState matching the Idris2 ABI tags.
    module BackendState
      HEALTHY = 0
      UNHEALTHY = 1
      DRAINING = 2
      DISABLED = 3
    end

    # SessionPersistence matching the Idris2 ABI tags.
    module SessionPersistence
      NONE = 0
      COOKIE = 1
      SOURCE_IP = 2
      HEADER = 3
    end

    # LbProtocol matching the Idris2 ABI tags.
    module LbProtocol
      LB_PROTOCOL_HTTP = 0
      HTTPS = 1
      LB_PROTOCOL_TCP = 2
      UDP = 3
      LB_PROTOCOL_GRPC = 4
    end

  end
end
