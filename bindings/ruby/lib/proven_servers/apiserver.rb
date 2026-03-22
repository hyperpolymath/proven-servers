# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# API Server protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # API Server protocol types for proven-servers.
  module Apiserver
    # AuthScheme matching the Idris2 ABI tags.
    module AuthScheme
      API_KEY = 0
      BEARER = 1
      BASIC = 2
      O_AUTH2 = 3
      HMAC = 4
      MTLS = 5
    end

    # RateLimitStrategy matching the Idris2 ABI tags.
    module RateLimitStrategy
      FIXED_WINDOW = 0
      SLIDING_WINDOW = 1
      TOKEN_BUCKET = 2
      LEAKY_BUCKET = 3
    end

    # ApiVersion matching the Idris2 ABI tags.
    module ApiVersion
      V1 = 0
      V2 = 1
      V3 = 2
      LATEST = 3
      DEPRECATED = 4
    end

    # ResponseFormat matching the Idris2 ABI tags.
    module ResponseFormat
      JSON = 0
      XML = 1
      PROTOBUF = 2
      MESSAGE_PACK = 3
    end

    # GatewayError matching the Idris2 ABI tags.
    module GatewayError
      UNAUTHORIZED = 0
      RATE_LIMITED = 1
      NOT_FOUND = 2
      BAD_REQUEST = 3
      SERVICE_UNAVAILABLE = 4
      CIRCUIT_OPEN = 5
    end

  end
end
