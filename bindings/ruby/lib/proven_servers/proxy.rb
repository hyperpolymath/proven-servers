# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Proxy protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Proxy protocol types for proven-servers.
  module Proxy
    # ProxyMode matching the Idris2 ABI tags.
    module ProxyMode
      FORWARD = 0
      REVERSE = 1
    end

    # HopByHopHeader matching the Idris2 ABI tags.
    module HopByHopHeader
      CONNECTION = 0
      KEEP_ALIVE = 1
      PROXY_AUTH = 2
      PROXY_AUTHZ = 3
      TE = 4
      TRAILERS = 5
      TRANSFER_ENCODING = 6
      UPGRADE = 7
    end

    # CacheDirective matching the Idris2 ABI tags.
    module CacheDirective
      NO_CACHE = 0
      NO_STORE = 1
      MAX_AGE = 2
      PUBLIC = 3
      PRIVATE = 4
      MUST_REVALIDATE = 5
    end

    # ProxyError matching the Idris2 ABI tags.
    module ProxyError
      BAD_GATEWAY = 0
      GATEWAY_TIMEOUT = 1
      UPSTREAM_REFUSED = 2
      UPSTREAM_TLS = 3
    end

  end
end
