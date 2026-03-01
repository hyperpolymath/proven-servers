-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Compose.Types: Core type definitions for composition combinators.
-- Closed sum types representing how protocols are snapped together —
-- combinators, compatibility checks, directions, errors, and pipeline stages.

module Compose.Types

%default total

---------------------------------------------------------------------------
-- Combinator — the ways two protocols can be composed.
---------------------------------------------------------------------------

||| A combinator for composing two protocol components.
public export
data Combinator : Type where
  ||| Sequential composition: output of first feeds input of second.
  Chain     : Combinator
  ||| Parallel composition: both run simultaneously on the same input.
  Parallel  : Combinator
  ||| Proxy: one protocol acts as a proxy for another.
  Proxy     : Combinator
  ||| Relay: messages are forwarded between protocols.
  Relay     : Combinator
  ||| Multiplex: multiple logical streams over one connection.
  Mux       : Combinator
  ||| Demultiplex: split one stream into multiple logical streams.
  Demux     : Combinator
  ||| Filter: selectively pass or drop messages.
  Filter    : Combinator
  ||| Transform: modify messages as they pass through.
  Transform : Combinator
  ||| Tap: observe messages without modifying them.
  Tap       : Combinator

public export
Show Combinator where
  show Chain     = "Chain"
  show Parallel  = "Parallel"
  show Proxy     = "Proxy"
  show Relay     = "Relay"
  show Mux       = "Mux"
  show Demux     = "Demux"
  show Filter    = "Filter"
  show Transform = "Transform"
  show Tap       = "Tap"

---------------------------------------------------------------------------
-- Compatibility — whether two components can be composed.
---------------------------------------------------------------------------

||| The result of checking whether two protocol components are composable.
public export
data Compatibility : Type where
  ||| The components are fully compatible for composition.
  Compatible            : Compatibility
  ||| The components have incompatible message types.
  IncompatibleTypes     : Compatibility
  ||| The components use incompatible framing strategies.
  IncompatibleFraming   : Compatibility
  ||| The components have incompatible security requirements.
  IncompatibleSecurity  : Compatibility
  ||| The components have incompatible data flow directions.
  IncompatibleDirection : Compatibility

public export
Show Compatibility where
  show Compatible            = "Compatible"
  show IncompatibleTypes     = "IncompatibleTypes"
  show IncompatibleFraming   = "IncompatibleFraming"
  show IncompatibleSecurity  = "IncompatibleSecurity"
  show IncompatibleDirection = "IncompatibleDirection"

---------------------------------------------------------------------------
-- Direction — the data flow direction.
---------------------------------------------------------------------------

||| The direction of data flow in a composed pipeline.
public export
data Direction : Type where
  ||| Data flows toward the origin / client.
  Upstream      : Direction
  ||| Data flows toward the destination / server.
  Downstream    : Direction
  ||| Data flows in both directions.
  Bidirectional : Direction

public export
Show Direction where
  show Upstream      = "Upstream"
  show Downstream    = "Downstream"
  show Bidirectional = "Bidirectional"

---------------------------------------------------------------------------
-- Composition error — errors that arise during composition.
---------------------------------------------------------------------------

||| Errors that can arise when composing protocol components.
public export
data CompositionError : Type where
  ||| The output type of one component does not match the input of the next.
  TypeMismatch      : CompositionError
  ||| Composing would result in a security downgrade.
  SecurityDowngrade : CompositionError
  ||| The composition graph contains a cycle.
  CycleDetected     : CompositionError
  ||| A required dependency is not available in the pipeline.
  MissingDependency : CompositionError
  ||| Multiple routes exist and the correct one is ambiguous.
  AmbiguousRoute    : CompositionError

public export
Show CompositionError where
  show TypeMismatch      = "TypeMismatch"
  show SecurityDowngrade = "SecurityDowngrade"
  show CycleDetected     = "CycleDetected"
  show MissingDependency = "MissingDependency"
  show AmbiguousRoute    = "AmbiguousRoute"

---------------------------------------------------------------------------
-- Pipeline stage — named stages within a composed pipeline.
---------------------------------------------------------------------------

||| A named stage within a composed protocol pipeline.
public export
data PipelineStage : Type where
  ||| The entry point where data arrives.
  Ingress      : PipelineStage
  ||| The core processing stage.
  Process      : PipelineStage
  ||| The exit point where data is sent out.
  Egress       : PipelineStage
  ||| The error handling stage.
  ErrorHandler : PipelineStage
  ||| The audit / logging stage.
  Audit        : PipelineStage

public export
Show PipelineStage where
  show Ingress      = "Ingress"
  show Process      = "Process"
  show Egress       = "Egress"
  show ErrorHandler = "ErrorHandler"
  show Audit        = "Audit"
