-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ComposeABI.Transitions: Valid pipeline lifecycle proofs for composition.
--
-- Models the lifecycle of a composed pipeline:
--
--   Idle --Configure--> Configured --Assemble--> Assembled
--   Assembled --Activate--> Running --Deactivate--> Stopped
--   Running --Fail--> Failed
--   Configured|Assembled --Fail--> Failed
--   Failed --Reset--> Idle
--   Stopped --Reset--> Idle
--
-- The key invariant: a pipeline must be configured before assembly,
-- assembled before activation, and cannot be reconfigured while running.

module ComposeABI.Transitions

import Compose.Types

%default total

---------------------------------------------------------------------------
-- PipelineState — the lifecycle state of a composed pipeline.
---------------------------------------------------------------------------

||| The lifecycle state of a composed pipeline session.
public export
data PipelineState : Type where
  ||| No pipeline configured.
  Idle       : PipelineState
  ||| Pipeline stages defined but not yet assembled.
  Configured : PipelineState
  ||| Pipeline assembled (connections verified) but not running.
  Assembled  : PipelineState
  ||| Pipeline is actively processing data.
  Running    : PipelineState
  ||| Pipeline stopped normally.
  Stopped    : PipelineState
  ||| Pipeline stopped due to an error.
  Failed     : PipelineState

public export
Show PipelineState where
  show Idle       = "Idle"
  show Configured = "Configured"
  show Assembled  = "Assembled"
  show Running    = "Running"
  show Stopped    = "Stopped"
  show Failed     = "Failed"

---------------------------------------------------------------------------
-- ValidPipelineTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that a pipeline state transition is valid.
public export
data ValidPipelineTransition : PipelineState -> PipelineState -> Type where
  ||| Idle -> Configured (define pipeline stages).
  Configure     : ValidPipelineTransition Idle Configured
  ||| Configured -> Assembled (verify and connect stages).
  Assemble      : ValidPipelineTransition Configured Assembled
  ||| Assembled -> Running (activate the pipeline).
  Activate      : ValidPipelineTransition Assembled Running
  ||| Running -> Stopped (graceful shutdown).
  Deactivate    : ValidPipelineTransition Running Stopped
  ||| Configured -> Failed (assembly-time error).
  FailConfigure : ValidPipelineTransition Configured Failed
  ||| Assembled -> Failed (activation-time error).
  FailAssemble  : ValidPipelineTransition Assembled Failed
  ||| Running -> Failed (runtime error).
  FailRunning   : ValidPipelineTransition Running Failed
  ||| Failed -> Idle (reset after error).
  ResetFailed   : ValidPipelineTransition Failed Idle
  ||| Stopped -> Idle (reset after clean stop, for reuse).
  ResetStopped  : ValidPipelineTransition Stopped Idle

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a pipeline can accept data (running).
public export
data CanProcess : PipelineState -> Type where
  RunningCanProcess : CanProcess Running

||| Proof that a pipeline can be reconfigured (idle).
public export
data CanConfigure : PipelineState -> Type where
  IdleCanConfigure : CanConfigure Idle

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot configure while running.
public export
cannotConfigureWhileRunning : ValidPipelineTransition Running Configured -> Void
cannotConfigureWhileRunning _ impossible

||| Cannot activate from Idle (must configure and assemble first).
public export
cannotActivateFromIdle : ValidPipelineTransition Idle Running -> Void
cannotActivateFromIdle _ impossible

||| Cannot assemble from Idle (must configure first).
public export
cannotAssembleFromIdle : ValidPipelineTransition Idle Assembled -> Void
cannotAssembleFromIdle _ impossible

||| Cannot activate from Configured (must assemble first).
public export
cannotActivateFromConfigured : ValidPipelineTransition Configured Running -> Void
cannotActivateFromConfigured _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a pipeline state transition is valid.
public export
validatePipelineTransition : (from : PipelineState) -> (to : PipelineState) -> Maybe (ValidPipelineTransition from to)
validatePipelineTransition Idle       Configured = Just Configure
validatePipelineTransition Configured Assembled  = Just Assemble
validatePipelineTransition Assembled  Running    = Just Activate
validatePipelineTransition Running    Stopped    = Just Deactivate
validatePipelineTransition Configured Failed     = Just FailConfigure
validatePipelineTransition Assembled  Failed     = Just FailAssemble
validatePipelineTransition Running    Failed     = Just FailRunning
validatePipelineTransition Failed     Idle       = Just ResetFailed
validatePipelineTransition Stopped    Idle       = Just ResetStopped
validatePipelineTransition _ _                   = Nothing
