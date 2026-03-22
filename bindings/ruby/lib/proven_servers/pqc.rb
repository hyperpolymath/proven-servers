# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# PQC protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # PQC protocol types for proven-servers.
  module Pqc
    # PqcAlgorithm matching the Idris2 ABI tags.
    module PqcAlgorithm
      CRYSTALS_KYBER = 0
      CRYSTALS_DILITHIUM = 1
      FALCON = 2
      SPHINCS_PLUS = 3
      CLASSIC_MCELIECE = 4
      BIKE = 5
      HQC = 6
      FRODOKEM = 7
    end

    # NistLevel matching the Idris2 ABI tags.
    module NistLevel
      NIST1 = 0
      NIST2 = 1
      NIST3 = 2
      NIST4 = 3
      NIST5 = 4
    end

    # Operation matching the Idris2 ABI tags.
    module Operation
      KEYGEN = 0
      ENCAPSULATE = 1
      DECAPSULATE = 2
      SIGN = 3
      VERIFY = 4
    end

    # HybridMode matching the Idris2 ABI tags.
    module HybridMode
      CLASSICAL_ONLY = 0
      PQC_ONLY = 1
      HYBRID = 2
    end

    # AlgorithmCategory matching the Idris2 ABI tags.
    module AlgorithmCategory
      KEM = 0
      SIGNATURE = 1
    end

    # KeyState matching the Idris2 ABI tags.
    module KeyState
      EMPTY = 0
      GENERATING = 1
      GENERATED = 2
      ACTIVE = 3
      EXPIRED = 4
      COMPROMISED = 5
    end

  end
end
