# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# SPARQL protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # SPARQL protocol types for proven-servers.
  module Sparql
    # SparqlQueryType matching the Idris2 ABI tags.
    module SparqlQueryType
      SELECT = 0
      CONSTRUCT = 1
      ASK = 2
      DESCRIBE = 3
    end

    # UpdateType matching the Idris2 ABI tags.
    module UpdateType
      INSERT = 0
      DELETE = 1
      LOAD = 2
      CLEAR = 3
      CREATE = 4
      DROP = 5
    end

    # ResultFormat matching the Idris2 ABI tags.
    module ResultFormat
      XML = 0
      JSON = 1
      CSV = 2
      TSV = 3
    end

    # SparqlErrorType matching the Idris2 ABI tags.
    module SparqlErrorType
      PARSE_ERROR = 0
      QUERY_TIMEOUT = 1
      RESULTS_TOO_LARGE = 2
      UNKNOWN_GRAPH = 3
      ACCESS_DENIED = 4
    end

  end
end
