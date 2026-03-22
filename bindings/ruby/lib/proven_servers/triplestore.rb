# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Triplestore protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Triplestore protocol types for proven-servers.
  module Triplestore
    # Statement matching the Idris2 ABI tags.
    module Statement
      TRIPLE = 0
      QUAD = 1
    end

    # IndexOrder matching the Idris2 ABI tags.
    module IndexOrder
      SPO = 0
      POS = 1
      OSP = 2
      GSPO = 3
      GPOS = 4
      GOSP = 5
    end

    # StorageBackend matching the Idris2 ABI tags.
    module StorageBackend
      IN_MEMORY = 0
      B_TREE = 1
      LSM = 2
      PERSISTENT = 3
    end

    # ImportFormat matching the Idris2 ABI tags.
    module ImportFormat
      N_TRIPLES = 0
      TURTLE = 1
      RDF_XML = 2
      JSON_LD = 3
      N_QUADS = 4
      TRIG = 5
    end

    # TransactionIsolation matching the Idris2 ABI tags.
    module TransactionIsolation
      READ_COMMITTED = 0
      SERIALIZABLE = 1
      SNAPSHOT = 2
    end

    # StoreState matching the Idris2 ABI tags.
    module StoreState
      IDLE = 0
      READY = 1
      IN_TRANSACTION = 2
      IMPORTING = 3
      CLOSING = 4
    end

  end
end
