-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NeSy.Reasoning: Reasoning request and response protocol types.
-- Defines the wire format for asking the neurosymbolic server to reason
-- about a query, with configurable mode, backend, and proof requirements.

module NeSy.Reasoning

import NeSy.Types

%default total

------------------------------------------------------------------------
-- ReasoningPriority
-- How urgently the reasoning result is needed.
------------------------------------------------------------------------

||| Priority level for a reasoning request. Higher priority requests
||| may preempt lower-priority ones or bypass caching.
public export
data ReasoningPriority : Type where
  ||| Background reasoning — can be deferred or batched.
  Background : ReasoningPriority
  ||| Normal interactive reasoning — respond within seconds.
  Normal     : ReasoningPriority
  ||| Urgent — blocking a user action, respond ASAP.
  Urgent     : ReasoningPriority
  ||| Critical — safety-related, must not be dropped or delayed.
  Critical   : ReasoningPriority

export
Show ReasoningPriority where
  show Background = "Background"
  show Normal     = "Normal"
  show Urgent     = "Urgent"
  show Critical   = "Critical"

------------------------------------------------------------------------
-- CachePolicy
-- Whether to use cached results or force fresh reasoning.
------------------------------------------------------------------------

||| Cache policy for reasoning results. Symbolic proofs are eternally
||| valid (they don't expire), but neural results may go stale.
public export
data CachePolicy : Type where
  ||| Use cached result if available and not stale.
  AllowCache  : CachePolicy
  ||| Force fresh reasoning, ignore cache.
  ForceRefresh : CachePolicy
  ||| Use cache for symbolic, force refresh for neural.
  SymCacheOnly : CachePolicy
  ||| Never cache this result (one-shot reasoning).
  NoStore      : CachePolicy

export
Show CachePolicy where
  show AllowCache   = "AllowCache"
  show ForceRefresh = "ForceRefresh"
  show SymCacheOnly = "SymCacheOnly"
  show NoStore      = "NoStore"

------------------------------------------------------------------------
-- ProofRequirement
-- What proof obligation the requester demands.
------------------------------------------------------------------------

||| What level of proof the caller requires before accepting the result.
public export
data ProofRequirement : Type where
  ||| No proof needed — accept neural output as-is.
  NoProof       : ProofRequirement
  ||| Best-effort proof — attempt verification, accept without if it fails.
  BestEffort    : ProofRequirement
  ||| Proof required — reject result if symbolic verification fails.
  ProofRequired : ProofRequirement
  ||| Machine-checked — proof must pass an external proof checker.
  MachineChecked : ProofRequirement

export
Show ProofRequirement where
  show NoProof        = "NoProof"
  show BestEffort     = "BestEffort"
  show ProofRequired  = "ProofRequired"
  show MachineChecked = "MachineChecked"

------------------------------------------------------------------------
-- ResultDisposition
-- What happened to the reasoning result.
------------------------------------------------------------------------

||| Outcome classification for a completed reasoning request.
public export
data ResultDisposition : Type where
  ||| Reasoning succeeded, result available.
  Completed     : ResultDisposition
  ||| Reasoning timed out before completing.
  TimedOut      : ResultDisposition
  ||| Reasoning was cancelled by the requester.
  Cancelled     : ResultDisposition
  ||| Reasoning failed due to an internal error.
  InternalError : ResultDisposition
  ||| Symbolic layer rejected the query as ill-formed.
  Rejected      : ResultDisposition
  ||| Neural layer returned a result that failed symbolic verification.
  VerificationFailed : ResultDisposition

export
Show ResultDisposition where
  show Completed          = "Completed"
  show TimedOut           = "TimedOut"
  show Cancelled          = "Cancelled"
  show InternalError      = "InternalError"
  show Rejected           = "Rejected"
  show VerificationFailed = "VerificationFailed"
