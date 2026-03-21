-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LdpABI.Layout: C-ABI-compatible numeric representations of LDP types.
--
-- Maps every constructor of the LDP domain types (ContainerType,
-- ResourceType, Preference, InteractionModel, ConstraintViolation)
-- to fixed Bits8 values for C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- Tag values here MUST match the C header (generated/abi/ldp.h) and the
-- Zig FFI enums (ffi/zig/src/ldp.zig) exactly.

module LdpABI.Layout

import Ldp.Types

%default total

---------------------------------------------------------------------------
-- ContainerType (3 constructors, tags 0-2)
---------------------------------------------------------------------------

||| C-ABI representation size for ContainerType (1 byte).
public export
containerTypeSize : Nat
containerTypeSize = 1

||| Map ContainerType to its C-ABI byte value.
public export
containerTypeToTag : ContainerType -> Bits8
containerTypeToTag Basic    = 0
containerTypeToTag Direct   = 1
containerTypeToTag Indirect = 2

||| Recover ContainerType from its C-ABI byte value.
public export
tagToContainerType : Bits8 -> Maybe ContainerType
tagToContainerType 0 = Just Basic
tagToContainerType 1 = Just Direct
tagToContainerType 2 = Just Indirect
tagToContainerType _ = Nothing

||| Proof: encoding then decoding ContainerType is the identity.
public export
containerTypeRoundtrip : (c : ContainerType) -> tagToContainerType (containerTypeToTag c) = Just c
containerTypeRoundtrip Basic    = Refl
containerTypeRoundtrip Direct   = Refl
containerTypeRoundtrip Indirect = Refl

---------------------------------------------------------------------------
-- ResourceType (3 constructors, tags 0-2)
---------------------------------------------------------------------------

||| C-ABI representation size for ResourceType (1 byte).
public export
resourceTypeSize : Nat
resourceTypeSize = 1

||| Map ResourceType to its C-ABI byte value.
public export
resourceTypeToTag : ResourceType -> Bits8
resourceTypeToTag RDFSource    = 0
resourceTypeToTag NonRDFSource = 1
resourceTypeToTag Container    = 2

||| Recover ResourceType from its C-ABI byte value.
public export
tagToResourceType : Bits8 -> Maybe ResourceType
tagToResourceType 0 = Just RDFSource
tagToResourceType 1 = Just NonRDFSource
tagToResourceType 2 = Just Container
tagToResourceType _ = Nothing

||| Proof: encoding then decoding ResourceType is the identity.
public export
resourceTypeRoundtrip : (r : ResourceType) -> tagToResourceType (resourceTypeToTag r) = Just r
resourceTypeRoundtrip RDFSource    = Refl
resourceTypeRoundtrip NonRDFSource = Refl
resourceTypeRoundtrip Container    = Refl

---------------------------------------------------------------------------
-- Preference (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for Preference (1 byte).
public export
preferenceSize : Nat
preferenceSize = 1

||| Map Preference to its C-ABI byte value.
public export
preferenceToTag : Preference -> Bits8
preferenceToTag MinimalContainer   = 0
preferenceToTag IncludeContainment = 1
preferenceToTag IncludeMembership  = 2
preferenceToTag OmitContainment    = 3
preferenceToTag OmitMembership     = 4

||| Recover Preference from its C-ABI byte value.
public export
tagToPreference : Bits8 -> Maybe Preference
tagToPreference 0 = Just MinimalContainer
tagToPreference 1 = Just IncludeContainment
tagToPreference 2 = Just IncludeMembership
tagToPreference 3 = Just OmitContainment
tagToPreference 4 = Just OmitMembership
tagToPreference _ = Nothing

||| Proof: encoding then decoding Preference is the identity.
public export
preferenceRoundtrip : (p : Preference) -> tagToPreference (preferenceToTag p) = Just p
preferenceRoundtrip MinimalContainer   = Refl
preferenceRoundtrip IncludeContainment = Refl
preferenceRoundtrip IncludeMembership  = Refl
preferenceRoundtrip OmitContainment    = Refl
preferenceRoundtrip OmitMembership     = Refl

---------------------------------------------------------------------------
-- InteractionModel (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for InteractionModel (1 byte).
public export
interactionModelSize : Nat
interactionModelSize = 1

||| Map InteractionModel to its C-ABI byte value.
public export
interactionModelToTag : InteractionModel -> Bits8
interactionModelToTag LDPR                 = 0
interactionModelToTag LDPC                 = 1
interactionModelToTag LDPBasicContainer    = 2
interactionModelToTag LDPDirectContainer   = 3
interactionModelToTag LDPIndirectContainer = 4

||| Recover InteractionModel from its C-ABI byte value.
public export
tagToInteractionModel : Bits8 -> Maybe InteractionModel
tagToInteractionModel 0 = Just LDPR
tagToInteractionModel 1 = Just LDPC
tagToInteractionModel 2 = Just LDPBasicContainer
tagToInteractionModel 3 = Just LDPDirectContainer
tagToInteractionModel 4 = Just LDPIndirectContainer
tagToInteractionModel _ = Nothing

||| Proof: encoding then decoding InteractionModel is the identity.
public export
interactionModelRoundtrip : (m : InteractionModel) -> tagToInteractionModel (interactionModelToTag m) = Just m
interactionModelRoundtrip LDPR                 = Refl
interactionModelRoundtrip LDPC                 = Refl
interactionModelRoundtrip LDPBasicContainer    = Refl
interactionModelRoundtrip LDPDirectContainer   = Refl
interactionModelRoundtrip LDPIndirectContainer = Refl

---------------------------------------------------------------------------
-- ConstraintViolation (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for ConstraintViolation (1 byte).
public export
constraintViolationSize : Nat
constraintViolationSize = 1

||| Map ConstraintViolation to its C-ABI byte value.
public export
constraintViolationToTag : ConstraintViolation -> Bits8
constraintViolationToTag MembershipConstant      = 0
constraintViolationToTag ContainsTriplesModified = 1
constraintViolationToTag ServerManaged           = 2
constraintViolationToTag TypeConflict            = 3

||| Recover ConstraintViolation from its C-ABI byte value.
public export
tagToConstraintViolation : Bits8 -> Maybe ConstraintViolation
tagToConstraintViolation 0 = Just MembershipConstant
tagToConstraintViolation 1 = Just ContainsTriplesModified
tagToConstraintViolation 2 = Just ServerManaged
tagToConstraintViolation 3 = Just TypeConflict
tagToConstraintViolation _ = Nothing

||| Proof: encoding then decoding ConstraintViolation is the identity.
public export
constraintViolationRoundtrip : (v : ConstraintViolation) -> tagToConstraintViolation (constraintViolationToTag v) = Just v
constraintViolationRoundtrip MembershipConstant      = Refl
constraintViolationRoundtrip ContainsTriplesModified = Refl
constraintViolationRoundtrip ServerManaged           = Refl
constraintViolationRoundtrip TypeConflict            = Refl

---------------------------------------------------------------------------
-- LdpError (7 constructors, tags 0-6)
-- Error codes returned by LDP FFI operations.
---------------------------------------------------------------------------

||| Error codes for LDP FFI operations.
public export
data LdpError : Type where
  ||| No error.
  LdpOk                  : LdpError
  ||| Invalid slot index.
  LdpInvalidSlot         : LdpError
  ||| Resource not active.
  LdpNotActive           : LdpError
  ||| Constraint violation detected.
  LdpConstraintViolation : LdpError
  ||| Resource type conflict.
  LdpTypeConflict        : LdpError
  ||| Container capacity exhausted.
  LdpCapacityExhausted   : LdpError
  ||| Invalid preference combination.
  LdpInvalidPreference   : LdpError

public export
Eq LdpError where
  LdpOk                  == LdpOk                  = True
  LdpInvalidSlot         == LdpInvalidSlot         = True
  LdpNotActive           == LdpNotActive           = True
  LdpConstraintViolation == LdpConstraintViolation = True
  LdpTypeConflict        == LdpTypeConflict        = True
  LdpCapacityExhausted   == LdpCapacityExhausted   = True
  LdpInvalidPreference   == LdpInvalidPreference   = True
  _                      == _                      = False

public export
Show LdpError where
  show LdpOk                  = "Ok"
  show LdpInvalidSlot         = "InvalidSlot"
  show LdpNotActive           = "NotActive"
  show LdpConstraintViolation = "ConstraintViolation"
  show LdpTypeConflict        = "TypeConflict"
  show LdpCapacityExhausted   = "CapacityExhausted"
  show LdpInvalidPreference   = "InvalidPreference"

||| C-ABI representation size for LdpError (1 byte).
public export
ldpErrorSize : Nat
ldpErrorSize = 1

||| Map LdpError to its C-ABI byte value.
public export
ldpErrorToTag : LdpError -> Bits8
ldpErrorToTag LdpOk                  = 0
ldpErrorToTag LdpInvalidSlot         = 1
ldpErrorToTag LdpNotActive           = 2
ldpErrorToTag LdpConstraintViolation = 3
ldpErrorToTag LdpTypeConflict        = 4
ldpErrorToTag LdpCapacityExhausted   = 5
ldpErrorToTag LdpInvalidPreference   = 6

||| Recover LdpError from its C-ABI byte value.
public export
tagToLdpError : Bits8 -> Maybe LdpError
tagToLdpError 0 = Just LdpOk
tagToLdpError 1 = Just LdpInvalidSlot
tagToLdpError 2 = Just LdpNotActive
tagToLdpError 3 = Just LdpConstraintViolation
tagToLdpError 4 = Just LdpTypeConflict
tagToLdpError 5 = Just LdpCapacityExhausted
tagToLdpError 6 = Just LdpInvalidPreference
tagToLdpError _ = Nothing

||| Proof: encoding then decoding LdpError is the identity.
public export
ldpErrorRoundtrip : (e : LdpError) -> tagToLdpError (ldpErrorToTag e) = Just e
ldpErrorRoundtrip LdpOk                  = Refl
ldpErrorRoundtrip LdpInvalidSlot         = Refl
ldpErrorRoundtrip LdpNotActive           = Refl
ldpErrorRoundtrip LdpConstraintViolation = Refl
ldpErrorRoundtrip LdpTypeConflict        = Refl
ldpErrorRoundtrip LdpCapacityExhausted   = Refl
ldpErrorRoundtrip LdpInvalidPreference   = Refl
