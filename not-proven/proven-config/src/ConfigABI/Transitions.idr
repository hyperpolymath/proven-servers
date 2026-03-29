-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ConfigABI.Transitions: Config lifecycle state machine GADT.
--
-- Models the lifecycle of a configuration session:
--
--   Uninitialised --Load--> Loading --Validate--> Validating
--   Validating --Accept--> Active
--   Validating --Reject--> Invalid
--   Active --Reload--> Loading
--   Active --Lock--> Frozen
--   Frozen --Unlock--> Active
--   Invalid --Reset--> Uninitialised
--   Any active state --Error--> Errored
--   Errored --Reset--> Uninitialised
--
-- Key invariant: a Frozen configuration cannot be modified — only read.
-- Security policies cannot be weakened during reload (downgrade prevention).

module ConfigABI.Transitions

import Config.Types

%default total

---------------------------------------------------------------------------
-- ConfigState — the lifecycle state of a config session.
---------------------------------------------------------------------------

||| The lifecycle state of a configuration session.
public export
data ConfigState : Type where
  ||| No configuration loaded.
  Uninitialised : ConfigState
  ||| Configuration is being loaded from source.
  Loading       : ConfigState
  ||| Configuration is being validated against schema and policies.
  Validating    : ConfigState
  ||| Configuration is active and in use.
  Active        : ConfigState
  ||| Configuration is frozen (read-only, cannot be modified).
  Frozen        : ConfigState
  ||| Configuration failed validation.
  Invalid       : ConfigState
  ||| An error occurred during config processing.
  Errored       : ConfigState

public export
Show ConfigState where
  show Uninitialised = "Uninitialised"
  show Loading       = "Loading"
  show Validating    = "Validating"
  show Active        = "Active"
  show Frozen        = "Frozen"
  show Invalid       = "Invalid"
  show Errored       = "Errored"

---------------------------------------------------------------------------
-- ConfigState Bits8 tags (matching Layout pattern)
---------------------------------------------------------------------------

public export
configStateToTag : ConfigState -> Bits8
configStateToTag Uninitialised = 0
configStateToTag Loading       = 1
configStateToTag Validating    = 2
configStateToTag Active        = 3
configStateToTag Frozen        = 4
configStateToTag Invalid       = 5
configStateToTag Errored       = 6

public export
tagToConfigState : Bits8 -> Maybe ConfigState
tagToConfigState 0 = Just Uninitialised
tagToConfigState 1 = Just Loading
tagToConfigState 2 = Just Validating
tagToConfigState 3 = Just Active
tagToConfigState 4 = Just Frozen
tagToConfigState 5 = Just Invalid
tagToConfigState 6 = Just Errored
tagToConfigState _ = Nothing

public export
configStateRoundtrip : (s : ConfigState) -> tagToConfigState (configStateToTag s) = Just s
configStateRoundtrip Uninitialised = Refl
configStateRoundtrip Loading       = Refl
configStateRoundtrip Validating    = Refl
configStateRoundtrip Active        = Refl
configStateRoundtrip Frozen        = Refl
configStateRoundtrip Invalid       = Refl
configStateRoundtrip Errored       = Refl

---------------------------------------------------------------------------
-- ValidConfigTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that a config state transition is valid.
public export
data ValidConfigTransition : ConfigState -> ConfigState -> Type where
  ||| Uninitialised -> Loading (begin loading configuration).
  Load          : ValidConfigTransition Uninitialised Loading
  ||| Loading -> Validating (source loaded, begin validation).
  Validate      : ValidConfigTransition Loading Validating
  ||| Validating -> Active (validation passed, config is live).
  Accept        : ValidConfigTransition Validating Active
  ||| Validating -> Invalid (validation failed).
  Reject        : ValidConfigTransition Validating Invalid
  ||| Active -> Loading (hot-reload: re-load from source).
  Reload        : ValidConfigTransition Active Loading
  ||| Active -> Frozen (lock config to prevent changes).
  Lock          : ValidConfigTransition Active Frozen
  ||| Frozen -> Active (unlock config to allow changes).
  Unlock        : ValidConfigTransition Frozen Active
  ||| Invalid -> Uninitialised (reset after failed validation).
  ResetInvalid  : ValidConfigTransition Invalid Uninitialised
  ||| Loading -> Errored (load error).
  ErrorLoad     : ValidConfigTransition Loading Errored
  ||| Validating -> Errored (validation error).
  ErrorValidate : ValidConfigTransition Validating Errored
  ||| Active -> Errored (runtime error).
  ErrorActive   : ValidConfigTransition Active Errored
  ||| Errored -> Uninitialised (reset after error).
  ResetErrored  : ValidConfigTransition Errored Uninitialised

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that config values can be read (Active or Frozen).
public export
data CanRead : ConfigState -> Type where
  ActiveCanRead : CanRead Active
  FrozenCanRead : CanRead Frozen

||| Proof that config values can be modified (Active only, not Frozen).
public export
data CanModify : ConfigState -> Type where
  ActiveCanModify : CanModify Active

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot modify a Frozen configuration.
public export
cannotModifyFrozen : ValidConfigTransition Frozen Loading -> Void
cannotModifyFrozen _ impossible

||| Cannot reload from Frozen — must unlock first.
public export
cannotReloadFrozen : ValidConfigTransition Frozen Loading -> Void
cannotReloadFrozen _ impossible

||| Cannot skip validation (Loading cannot go directly to Active).
public export
cannotSkipValidation : ValidConfigTransition Loading Active -> Void
cannotSkipValidation _ impossible

||| Cannot go from Invalid to Active without resetting and reloading.
public export
invalidCannotActivate : ValidConfigTransition Invalid Active -> Void
invalidCannotActivate _ impossible

||| Cannot lock an Uninitialised config.
public export
uninitCannotLock : ValidConfigTransition Uninitialised Frozen -> Void
uninitCannotLock _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a config state transition is valid.
public export
validateConfigTransition : (from : ConfigState) -> (to : ConfigState) -> Maybe (ValidConfigTransition from to)
validateConfigTransition Uninitialised Loading       = Just Load
validateConfigTransition Loading       Validating    = Just Validate
validateConfigTransition Validating    Active        = Just Accept
validateConfigTransition Validating    Invalid       = Just Reject
validateConfigTransition Active        Loading       = Just Reload
validateConfigTransition Active        Frozen        = Just Lock
validateConfigTransition Frozen        Active        = Just Unlock
validateConfigTransition Invalid       Uninitialised = Just ResetInvalid
validateConfigTransition Loading       Errored       = Just ErrorLoad
validateConfigTransition Validating    Errored       = Just ErrorValidate
validateConfigTransition Active        Errored       = Just ErrorActive
validateConfigTransition Errored       Uninitialised = Just ResetErrored
validateConfigTransition _             _             = Nothing
