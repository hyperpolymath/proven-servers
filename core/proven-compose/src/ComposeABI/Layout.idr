-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ComposeABI.Layout: C-ABI-compatible numeric representations of compose types.
--
-- Maps every constructor of the five core sum types (Combinator, Compatibility,
-- Direction, CompositionError, PipelineStage) to fixed Bits8 values for C interop.
-- Each type gets a total encoder, partial decoder, and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/compose.h) and the
-- Zig FFI enums (ffi/zig/src/compose.zig) exactly.

module ComposeABI.Layout

import Compose.Types

%default total

---------------------------------------------------------------------------
-- Combinator (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
combinatorSize : Nat
combinatorSize = 1

public export
combinatorToTag : Combinator -> Bits8
combinatorToTag Chain     = 0
combinatorToTag Parallel  = 1
combinatorToTag Proxy     = 2
combinatorToTag Relay     = 3
combinatorToTag Mux       = 4
combinatorToTag Demux     = 5
combinatorToTag Filter    = 6
combinatorToTag Transform = 7
combinatorToTag Tap       = 8

public export
tagToCombinator : Bits8 -> Maybe Combinator
tagToCombinator 0 = Just Chain
tagToCombinator 1 = Just Parallel
tagToCombinator 2 = Just Proxy
tagToCombinator 3 = Just Relay
tagToCombinator 4 = Just Mux
tagToCombinator 5 = Just Demux
tagToCombinator 6 = Just Filter
tagToCombinator 7 = Just Transform
tagToCombinator 8 = Just Tap
tagToCombinator _ = Nothing

public export
combinatorRoundtrip : (c : Combinator) -> tagToCombinator (combinatorToTag c) = Just c
combinatorRoundtrip Chain     = Refl
combinatorRoundtrip Parallel  = Refl
combinatorRoundtrip Proxy     = Refl
combinatorRoundtrip Relay     = Refl
combinatorRoundtrip Mux       = Refl
combinatorRoundtrip Demux     = Refl
combinatorRoundtrip Filter    = Refl
combinatorRoundtrip Transform = Refl
combinatorRoundtrip Tap       = Refl

---------------------------------------------------------------------------
-- Compatibility (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
compatibilitySize : Nat
compatibilitySize = 1

public export
compatibilityToTag : Compatibility -> Bits8
compatibilityToTag Compatible            = 0
compatibilityToTag IncompatibleTypes     = 1
compatibilityToTag IncompatibleFraming   = 2
compatibilityToTag IncompatibleSecurity  = 3
compatibilityToTag IncompatibleDirection = 4

public export
tagToCompatibility : Bits8 -> Maybe Compatibility
tagToCompatibility 0 = Just Compatible
tagToCompatibility 1 = Just IncompatibleTypes
tagToCompatibility 2 = Just IncompatibleFraming
tagToCompatibility 3 = Just IncompatibleSecurity
tagToCompatibility 4 = Just IncompatibleDirection
tagToCompatibility _ = Nothing

public export
compatibilityRoundtrip : (c : Compatibility) -> tagToCompatibility (compatibilityToTag c) = Just c
compatibilityRoundtrip Compatible            = Refl
compatibilityRoundtrip IncompatibleTypes     = Refl
compatibilityRoundtrip IncompatibleFraming   = Refl
compatibilityRoundtrip IncompatibleSecurity  = Refl
compatibilityRoundtrip IncompatibleDirection = Refl

---------------------------------------------------------------------------
-- Direction (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
directionSize : Nat
directionSize = 1

public export
directionToTag : Direction -> Bits8
directionToTag Upstream      = 0
directionToTag Downstream    = 1
directionToTag Bidirectional = 2

public export
tagToDirection : Bits8 -> Maybe Direction
tagToDirection 0 = Just Upstream
tagToDirection 1 = Just Downstream
tagToDirection 2 = Just Bidirectional
tagToDirection _ = Nothing

public export
directionRoundtrip : (d : Direction) -> tagToDirection (directionToTag d) = Just d
directionRoundtrip Upstream      = Refl
directionRoundtrip Downstream    = Refl
directionRoundtrip Bidirectional = Refl

---------------------------------------------------------------------------
-- CompositionError (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
compositionErrorSize : Nat
compositionErrorSize = 1

public export
compositionErrorToTag : CompositionError -> Bits8
compositionErrorToTag TypeMismatch      = 0
compositionErrorToTag SecurityDowngrade = 1
compositionErrorToTag CycleDetected     = 2
compositionErrorToTag MissingDependency = 3
compositionErrorToTag AmbiguousRoute    = 4

public export
tagToCompositionError : Bits8 -> Maybe CompositionError
tagToCompositionError 0 = Just TypeMismatch
tagToCompositionError 1 = Just SecurityDowngrade
tagToCompositionError 2 = Just CycleDetected
tagToCompositionError 3 = Just MissingDependency
tagToCompositionError 4 = Just AmbiguousRoute
tagToCompositionError _ = Nothing

public export
compositionErrorRoundtrip : (e : CompositionError) -> tagToCompositionError (compositionErrorToTag e) = Just e
compositionErrorRoundtrip TypeMismatch      = Refl
compositionErrorRoundtrip SecurityDowngrade = Refl
compositionErrorRoundtrip CycleDetected     = Refl
compositionErrorRoundtrip MissingDependency = Refl
compositionErrorRoundtrip AmbiguousRoute    = Refl

---------------------------------------------------------------------------
-- PipelineStage (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
pipelineStageSize : Nat
pipelineStageSize = 1

public export
pipelineStageToTag : PipelineStage -> Bits8
pipelineStageToTag Ingress      = 0
pipelineStageToTag Process      = 1
pipelineStageToTag Egress       = 2
pipelineStageToTag ErrorHandler = 3
pipelineStageToTag Audit        = 4

public export
tagToPipelineStage : Bits8 -> Maybe PipelineStage
tagToPipelineStage 0 = Just Ingress
tagToPipelineStage 1 = Just Process
tagToPipelineStage 2 = Just Egress
tagToPipelineStage 3 = Just ErrorHandler
tagToPipelineStage 4 = Just Audit
tagToPipelineStage _ = Nothing

public export
pipelineStageRoundtrip : (s : PipelineStage) -> tagToPipelineStage (pipelineStageToTag s) = Just s
pipelineStageRoundtrip Ingress      = Refl
pipelineStageRoundtrip Process      = Refl
pipelineStageRoundtrip Egress       = Refl
pipelineStageRoundtrip ErrorHandler = Refl
pipelineStageRoundtrip Audit        = Refl
