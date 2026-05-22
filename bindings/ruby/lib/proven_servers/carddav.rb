# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# CardDAV protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # CardDAV protocol types for proven-servers.
  module Carddav
    # PropertyType matching the Idris2 ABI tags.
    module PropertyType
      FN_NAME = 0
      N = 1
      EMAIL = 2
      TEL = 3
      ADR = 4
      ORG = 5
      PHOTO = 6
      URL = 7
      NOTE = 8
    end

    # CardMethod matching the Idris2 ABI tags.
    module CardMethod
      GET = 0
      PUT = 1
      DELETE = 2
      PROPFIND = 3
      PROPPATCH = 4
      REPORT = 5
      MKCOL = 6
    end

    # VCardVersion matching the Idris2 ABI tags.
    module VCardVersion
      VCARD3 = 0
      VCARD4 = 1
    end

    # CardError matching the Idris2 ABI tags.
    module CardError
      VALID_ADDRESS_DATA = 0
      NO_RESOURCE_TYPE = 1
      MAX_RESOURCE_SIZE = 2
      UID_CONFLICT = 3
      SUPPORTED_ADDRESS_DATA = 4
      PRECONDITION_FAILED = 5
    end

    # ServerState matching the Idris2 ABI tags.
    module ServerState
      IDLE = 0
      BOUND = 1
      SERVING = 2
      SHUTDOWN = 3
    end

  end
end
