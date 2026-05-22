# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# NeSy protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # NeSy protocol types for proven-servers.
  module Nesy
    # ReasoningMode matching the Idris2 ABI tags.
    module ReasoningMode
      SYMBOLIC = 0
      NEURAL = 1
      SYM_TO_NEURAL = 2
      NEURAL_TO_SYM = 3
      ENSEMBLE = 4
      CASCADE = 5
    end

    # ProofStatus matching the Idris2 ABI tags.
    module ProofStatus
      PENDING = 0
      ATTEMPTING = 1
      PROVED = 2
      FAILED = 3
      ASSUMED = 4
      VACUOUS = 5
    end

    # ConstraintKind matching the Idris2 ABI tags.
    module ConstraintKind
      TYPE_EQUALITY = 0
      SUBTYPE = 1
      LINEARITY = 2
      TERMINATION = 3
      TOTALITY = 4
      INVARIANT = 5
      REFINEMENT = 6
      DEPENDENT_INDEX = 7
    end

    # NeuralBackend matching the Idris2 ABI tags.
    module NeuralBackend
      LOCAL_MODEL = 0
      CLAUDE = 1
      GEMINI = 2
      MISTRAL = 3
      GPT = 4
      CUSTOM_NEURAL = 5
    end

    # Confidence matching the Idris2 ABI tags.
    module Confidence
      VERIFIED = 0
      HIGH_NEURAL = 1
      MEDIUM_NEURAL = 2
      LOW_NEURAL = 3
      UNKNOWN = 4
      CONTRADICTED = 5
    end

    # DriftKind matching the Idris2 ABI tags.
    module DriftKind
      NO_DRIFT = 0
      SEMANTIC_DRIFT = 1
      CONFIDENCE_DRIFT = 2
      FACTUAL_DRIFT = 3
      TEMPORAL_DRIFT = 4
      CATASTROPHIC_DRIFT = 5
    end

    # NeSyState matching the Idris2 ABI tags.
    module NeSyState
      IDLE = 0
      READY = 1
      REASONING = 2
      VERIFYING = 3
      DRIFT = 4
      SHUTDOWN = 5
    end

  end
end
