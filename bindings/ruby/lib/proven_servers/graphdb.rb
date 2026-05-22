# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Graph DB protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Graph DB protocol types for proven-servers.
  module Graphdb
    # ElementType matching the Idris2 ABI tags.
    module ElementType
      NODE = 0
      EDGE = 1
      PROPERTY = 2
      LABEL = 3
      INDEX = 4
    end

    # QueryLanguage matching the Idris2 ABI tags.
    module QueryLanguage
      CYPHER = 0
      GREMLIN = 1
      SPARQL = 2
      GRAPH_QL = 3
    end

    # TraversalStrategy matching the Idris2 ABI tags.
    module TraversalStrategy
      BFS = 0
      DFS = 1
      DIJKSTRA = 2
      A_STAR = 3
      RANDOM = 4
    end

    # Consistency matching the Idris2 ABI tags.
    module Consistency
      STRONG = 0
      EVENTUAL = 1
      SESSION = 2
      CAUSAL = 3
    end

    # ErrorCode matching the Idris2 ABI tags.
    module ErrorCode
      SYNTAX_ERROR = 0
      NODE_NOT_FOUND = 1
      EDGE_NOT_FOUND = 2
      CONSTRAINT_VIOLATION = 3
      INDEX_EXISTS = 4
      TRANSACTION_CONFLICT = 5
      OUT_OF_MEMORY = 6
    end

    # SessionState matching the Idris2 ABI tags.
    module SessionState
      IDLE = 0
      CONNECTED = 1
      QUERYING = 2
      TRAVERSING = 3
      DISCONNECTING = 4
    end

  end
end
