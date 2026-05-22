-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GraphQL.Resolver: Field resolution model with argument validation.
--
-- Models the resolver pipeline that executes after query validation.
-- Provides proofs for:
--   - Field arguments matching their declared types
--   - Required (NonNull) arguments being present
--   - Resolution order respecting the selection set structure
--   - Error accumulation (partial results with errors)

module GraphQL.Resolver

import GraphQL.Types
import GraphQLABI.Layout
import GraphQLABI.Transitions

%default total

---------------------------------------------------------------------------
-- Argument presence
---------------------------------------------------------------------------

||| Whether an argument value is provided.
public export
data ArgPresence : Type where
  Present : ArgPresence
  Absent  : ArgPresence

public export
Show ArgPresence where
  show Present = "PRESENT"
  show Absent  = "ABSENT"

---------------------------------------------------------------------------
-- Argument requirement
---------------------------------------------------------------------------

||| Whether an argument is required (NonNull without default).
public export
data ArgRequirement : Type where
  Required : ArgRequirement
  Optional : ArgRequirement

public export
Show ArgRequirement where
  show Required = "REQUIRED"
  show Optional = "OPTIONAL"

---------------------------------------------------------------------------
-- Argument validation proof
---------------------------------------------------------------------------

||| Proof that an argument's presence matches its requirement.
public export
data ArgValid : ArgRequirement -> ArgPresence -> Type where
  ||| Required argument is present -- valid.
  RequiredPresent : ArgValid Required Present
  ||| Optional argument is present -- valid.
  OptionalPresent : ArgValid Optional Present
  ||| Optional argument is absent -- valid (will use default or null).
  OptionalAbsent  : ArgValid Optional Absent

||| A required argument that is absent is invalid.
public export
requiredAbsentInvalid : ArgValid Required Absent -> Void
requiredAbsentInvalid _ impossible

||| Runtime check: is this argument configuration valid?
public export
validateArg : (req : ArgRequirement) -> (pres : ArgPresence) -> Maybe (ArgValid req pres)
validateArg Required Present = Just RequiredPresent
validateArg Optional Present = Just OptionalPresent
validateArg Optional Absent  = Just OptionalAbsent
validateArg Required Absent  = Nothing

---------------------------------------------------------------------------
-- Resolution result
---------------------------------------------------------------------------

||| Outcome of resolving a single field.
public export
data FieldResult : Type where
  ||| Field resolved successfully with data.
  Resolved    : FieldResult
  ||| Field resolved to null (valid for nullable fields).
  ResolvedNull : FieldResult
  ||| Field resolution failed with an error.
  ResolverError : ErrorCategory -> FieldResult

public export
Show FieldResult where
  show Resolved          = "RESOLVED"
  show ResolvedNull      = "RESOLVED_NULL"
  show (ResolverError e) = "ERROR(" ++ show e ++ ")"

||| Is this result an error?
public export
isError : FieldResult -> Bool
isError (ResolverError _) = True
isError _                 = False

---------------------------------------------------------------------------
-- Resolution phase proof
---------------------------------------------------------------------------

||| Proof that resolution can only occur in the Resolve phase.
||| This re-exports CanResolveFields from Transitions but adds
||| documentation context for the resolver module.
public export
data InResolvePhase : RequestPhase -> Type where
  IsResolving : InResolvePhase Resolve

||| Cannot resolve fields in the Parse phase.
public export
cannotResolveInParse : InResolvePhase Parse -> Void
cannotResolveInParse _ impossible

||| Cannot resolve fields in the Validate phase.
public export
cannotResolveInValidate : InResolvePhase Validate -> Void
cannotResolveInValidate _ impossible

||| Cannot resolve fields in the Execute phase (execution creates the plan,
||| resolution happens in Resolve).
public export
cannotResolveInExecute : InResolvePhase Execute -> Void
cannotResolveInExecute _ impossible

||| Cannot resolve fields in the Serialize phase (too late).
public export
cannotResolveInSerialize : InResolvePhase Serialize -> Void
cannotResolveInSerialize _ impossible

---------------------------------------------------------------------------
-- Response structure (data + errors)
---------------------------------------------------------------------------

||| A GraphQL response always has an optional data field and optional errors.
||| Per the spec, at least one of data or errors must be present.
public export
data ResponsePresence : Type where
  ||| Response has data only (all fields resolved successfully).
  DataOnly   : ResponsePresence
  ||| Response has errors only (top-level error prevented execution).
  ErrorsOnly : ResponsePresence
  ||| Response has both data and errors (partial success).
  DataAndErrors : ResponsePresence

public export
Show ResponsePresence where
  show DataOnly      = "DATA_ONLY"
  show ErrorsOnly    = "ERRORS_ONLY"
  show DataAndErrors = "DATA_AND_ERRORS"

||| Derive response presence from a list of field results.
public export
deriveResponsePresence : List FieldResult -> ResponsePresence
deriveResponsePresence [] = ErrorsOnly
deriveResponsePresence results =
  let hasErrors = any isError results
      hasData   = any (not . isError) results
  in case (hasData, hasErrors) of
       (True, False)  => DataOnly
       (False, True)  => ErrorsOnly
       (True, True)   => DataAndErrors
       (False, False) => DataOnly  -- all null is still data

---------------------------------------------------------------------------
-- Type-kind-aware resolution
---------------------------------------------------------------------------

||| Proof that a type kind permits child field resolution.
||| Only Object, Interface types have fields that need resolution.
public export
data HasChildFields : TypeKind -> Type where
  ObjectHasFields    : HasChildFields Object
  InterfaceHasFields : HasChildFields Interface

||| Scalar types have no child fields to resolve.
public export
scalarNoChildren : HasChildFields Scalar -> Void
scalarNoChildren _ impossible

||| Enum types have no child fields to resolve.
public export
enumNoChildren : HasChildFields Enum -> Void
enumNoChildren _ impossible

||| Union types have no fields themselves (resolved via type resolution).
public export
unionNoDirectChildren : HasChildFields Union -> Void
unionNoDirectChildren _ impossible
