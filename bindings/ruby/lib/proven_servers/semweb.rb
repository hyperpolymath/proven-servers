# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Semantic Web protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Semantic Web protocol types for proven-servers.
  module Semweb
    # RdfFormat matching the Idris2 ABI tags.
    module RdfFormat
      RDF_XML = 0
      TURTLE = 1
      N_TRIPLES = 2
      N_QUADS = 3
      JSON_LD = 4
      TRIG = 5
    end

    # SemwebResourceType matching the Idris2 ABI tags.
    module SemwebResourceType
      CLASS = 0
      PROPERTY = 1
      INDIVIDUAL = 2
      ONTOLOGY = 3
      NAMED_GRAPH = 4
    end

    # HttpMethod matching the Idris2 ABI tags.
    module HttpMethod
      GET = 0
      POST = 1
      PUT = 2
      PATCH = 3
      DELETE = 4
    end

    # ContentNegotiation matching the Idris2 ABI tags.
    module ContentNegotiation
      NEG_RDF_XML = 0
      NEG_TURTLE = 1
      NEG_JSON_LD = 2
      NEG_HTML = 3
    end

    # SemwebErrorCode matching the Idris2 ABI tags.
    module SemwebErrorCode
      NOT_FOUND = 0
      INVALID_URI = 1
      MALFORMED_RDF = 2
      UNSUPPORTED_FORMAT = 3
      CONFLICTING_TRIPLES = 4
    end

  end
end
