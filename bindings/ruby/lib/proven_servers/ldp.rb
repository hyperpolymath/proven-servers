# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# LDP protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # LDP protocol types for proven-servers.
  module Ldp
    # ContainerType matching the Idris2 ABI tags.
    module ContainerType
      BASIC = 0
      DIRECT = 1
      INDIRECT = 2
    end

    # LdpResourceType matching the Idris2 ABI tags.
    module LdpResourceType
      RDF_SOURCE = 0
      NON_RDF_SOURCE = 1
      CONTAINER = 2
    end

    # Preference matching the Idris2 ABI tags.
    module Preference
      MINIMAL_CONTAINER = 0
      INCLUDE_CONTAINMENT = 1
      INCLUDE_MEMBERSHIP = 2
      OMIT_CONTAINMENT = 3
      OMIT_MEMBERSHIP = 4
    end

    # InteractionModel matching the Idris2 ABI tags.
    module InteractionModel
      LDPR = 0
      LDPC = 1
      LDP_BASIC_CONTAINER = 2
      LDP_DIRECT_CONTAINER = 3
      LDP_INDIRECT_CONTAINER = 4
    end

    # ConstraintViolation matching the Idris2 ABI tags.
    module ConstraintViolation
      MEMBERSHIP_CONSTANT = 0
      CONTAINS_TRIPLES_MODIFIED = 1
      SERVER_MANAGED = 2
      TYPE_CONFLICT = 3
    end

  end
end
