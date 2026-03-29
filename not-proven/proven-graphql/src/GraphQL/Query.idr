-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GraphQL.Query: Query representation with depth/complexity proofs.
--
-- Models GraphQL operations (query, mutation, subscription) as a structured
-- AST with provable depth and complexity bounds for DoS prevention.
-- Also provides batch query representation with status tracking.

module GraphQL.Query

import GraphQL.Types
import GraphQLABI.Layout
import GraphQLABI.Transitions

%default total

---------------------------------------------------------------------------
-- Selection set depth
---------------------------------------------------------------------------

||| A query depth value with its bound proof.
||| The Nat parameter is the maximum allowed depth.
public export
data BoundedDepth : (maxDepth : Nat) -> Type where
  ||| A depth value that is within the allowed bound.
  MkBoundedDepth : (depth : Nat) -> LTE depth maxDepth -> BoundedDepth maxDepth

||| Extract the raw depth value.
public export
depthValue : BoundedDepth m -> Nat
depthValue (MkBoundedDepth d _) = d

||| Check whether a depth is within bounds (runtime).
public export
checkDepth : (depth : Nat) -> (maxDepth : Nat) -> Maybe (BoundedDepth maxDepth)
checkDepth depth maxDepth = case isLTE depth maxDepth of
  Yes prf => Just (MkBoundedDepth depth prf)
  No _    => Nothing

---------------------------------------------------------------------------
-- Complexity scoring
---------------------------------------------------------------------------

||| A complexity score with its bound proof.
public export
data BoundedComplexity : (maxScore : Nat) -> Type where
  MkBoundedComplexity : (score : Nat) -> LTE score maxScore -> BoundedComplexity maxScore

||| Extract the raw complexity score.
public export
complexityValue : BoundedComplexity m -> Nat
complexityValue (MkBoundedComplexity s _) = s

||| Check whether a complexity score is within bounds (runtime).
public export
checkComplexity : (score : Nat) -> (maxScore : Nat) -> Maybe (BoundedComplexity maxScore)
checkComplexity score maxScore = case isLTE score maxScore of
  Yes prf => Just (MkBoundedComplexity score prf)
  No _    => Nothing

---------------------------------------------------------------------------
-- Query validation result
---------------------------------------------------------------------------

||| Outcome of validating a parsed query against depth and complexity limits.
public export
data ValidationResult : Type where
  ||| Query passed all validation checks.
  Valid       : ValidationResult
  ||| Query exceeds the maximum allowed nesting depth.
  TooDeep     : (actual : Nat) -> (limit : Nat) -> ValidationResult
  ||| Query exceeds the maximum allowed complexity score.
  TooComplex  : (actual : Nat) -> (limit : Nat) -> ValidationResult
  ||| Query has both depth and complexity violations.
  BothExceeded : (depthActual : Nat) -> (depthLimit : Nat)
              -> (complexActual : Nat) -> (complexLimit : Nat) -> ValidationResult

public export
Show ValidationResult where
  show Valid = "VALID"
  show (TooDeep a l) = "TOO_DEEP(depth=" ++ show a ++ ",limit=" ++ show l ++ ")"
  show (TooComplex a l) = "TOO_COMPLEX(score=" ++ show a ++ ",limit=" ++ show l ++ ")"
  show (BothExceeded da dl ca cl) =
    "BOTH_EXCEEDED(depth=" ++ show da ++ "/" ++ show dl
    ++ ",complexity=" ++ show ca ++ "/" ++ show cl ++ ")"

||| Validate a query's depth and complexity against limits.
public export
validateLimits : (depth : Nat) -> (maxDepth : Nat)
              -> (complexity : Nat) -> (maxComplexity : Nat)
              -> ValidationResult
validateLimits depth maxDepth complexity maxComplexity =
  case (isLTE depth maxDepth, isLTE complexity maxComplexity) of
    (Yes _, Yes _)   => Valid
    (No _,  Yes _)   => TooDeep depth maxDepth
    (Yes _, No _)    => TooComplex complexity maxComplexity
    (No _,  No _)    => BothExceeded depth maxDepth complexity maxComplexity

---------------------------------------------------------------------------
-- Batch query support
---------------------------------------------------------------------------

||| Status of an individual query within a batch.
public export
data BatchQueryStatus : Type where
  Pending   : BatchQueryStatus
  Running   : BatchQueryStatus
  Complete  : BatchQueryStatus
  BqFailed  : BatchQueryStatus

public export
Show BatchQueryStatus where
  show Pending  = "PENDING"
  show Running  = "RUNNING"
  show Complete = "COMPLETE"
  show BqFailed = "FAILED"

||| Tag encoding for BatchQueryStatus (matches C header).
public export
batchQueryStatusToTag : BatchQueryStatus -> Bits8
batchQueryStatusToTag Pending  = 0
batchQueryStatusToTag Running  = 1
batchQueryStatusToTag Complete = 2
batchQueryStatusToTag BqFailed = 3

public export
tagToBatchQueryStatus : Bits8 -> Maybe BatchQueryStatus
tagToBatchQueryStatus 0 = Just Pending
tagToBatchQueryStatus 1 = Just Running
tagToBatchQueryStatus 2 = Just Complete
tagToBatchQueryStatus 3 = Just BqFailed
tagToBatchQueryStatus _ = Nothing

public export
batchQueryStatusRoundtrip : (s : BatchQueryStatus) -> tagToBatchQueryStatus (batchQueryStatusToTag s) = Just s
batchQueryStatusRoundtrip Pending  = Refl
batchQueryStatusRoundtrip Running  = Refl
batchQueryStatusRoundtrip Complete = Refl
batchQueryStatusRoundtrip BqFailed = Refl

||| Overall batch status derived from individual query statuses.
||| A batch is Complete when all queries are Complete.
||| A batch is Failed if any query Failed.
||| A batch is Running if any query is Running.
||| Otherwise it is Pending.
public export
deriveBatchStatus : List BatchQueryStatus -> BatchQueryStatus
deriveBatchStatus [] = Complete
deriveBatchStatus statuses =
  if any isFailed statuses then BqFailed
  else if all isComplete statuses then Complete
  else if any isRunning statuses then Running
  else Pending
  where
    isFailed : BatchQueryStatus -> Bool
    isFailed BqFailed = True
    isFailed _        = False
    isComplete : BatchQueryStatus -> Bool
    isComplete Complete = True
    isComplete _        = False
    isRunning : BatchQueryStatus -> Bool
    isRunning Running = True
    isRunning _       = False

---------------------------------------------------------------------------
-- Batch size bounds
---------------------------------------------------------------------------

||| Maximum number of queries in a single batch request.
public export
maxBatchSize : Nat
maxBatchSize = 16

||| Proof that a batch size is within bounds.
public export
data ValidBatchSize : (n : Nat) -> Type where
  MkValidBatchSize : (prf : LTE n 16) -> ValidBatchSize n

||| Non-zero batch size constraint.
public export
data NonEmptyBatch : (n : Nat) -> Type where
  MkNonEmptyBatch : (prf : LTE 1 n) -> NonEmptyBatch n

||| Zero-size batches are rejected.
public export
zeroBatchInvalid : NonEmptyBatch 0 -> Void
zeroBatchInvalid (MkNonEmptyBatch prf) = absurd prf
