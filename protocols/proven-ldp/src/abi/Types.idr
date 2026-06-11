-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- LdpABI.Types: C-ABI-compatible numeric representations of Ldp types.
--
-- Maps every constructor of the core Ldp sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/ldp.zig) exactly.
--
-- Types covered:
--   ContainerType             (3 constructors, tags 0-2)
--   ResourceType              (3 constructors, tags 0-2)
--   Preference                (5 constructors, tags 0-4)
--   InteractionModel          (5 constructors, tags 0-4)
--   ConstraintViolation       (4 constructors, tags 0-3)
--   LdpError                  (7 constructors, tags 0-6)

module LdpABI.Types

%default total

---------------------------------------------------------------------------
-- ContainerType (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
container_typeSize : Nat
container_typeSize = 1

||| ContainerType sum type for ABI encoding.
public export
data ContainerType : Type where
  Basic : ContainerType
  Direct : ContainerType
  Indirect : ContainerType

||| Encode a ContainerType to its ABI tag value.
public export
container_typeToTag : ContainerType -> Bits8
container_typeToTag Basic = 0
container_typeToTag Direct = 1
container_typeToTag Indirect = 2

||| Decode an ABI tag to a ContainerType.
public export
tagToContainerType : Bits8 -> Maybe ContainerType
tagToContainerType 0 = Just Basic
tagToContainerType 1 = Just Direct
tagToContainerType 2 = Just Indirect
tagToContainerType _ = Nothing

||| Roundtrip proof: decoding an encoded ContainerType yields the original.
public export
container_typeRoundtrip : (x : ContainerType) -> tagToContainerType (container_typeToTag x) = Just x
container_typeRoundtrip Basic = Refl
container_typeRoundtrip Direct = Refl
container_typeRoundtrip Indirect = Refl

---------------------------------------------------------------------------
-- ResourceType (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
resource_typeSize : Nat
resource_typeSize = 1

||| ResourceType sum type for ABI encoding.
public export
data ResourceType : Type where
  RdfSource : ResourceType
  NonRdfSource : ResourceType
  Container : ResourceType

||| Encode a ResourceType to its ABI tag value.
public export
resource_typeToTag : ResourceType -> Bits8
resource_typeToTag RdfSource = 0
resource_typeToTag NonRdfSource = 1
resource_typeToTag Container = 2

||| Decode an ABI tag to a ResourceType.
public export
tagToResourceType : Bits8 -> Maybe ResourceType
tagToResourceType 0 = Just RdfSource
tagToResourceType 1 = Just NonRdfSource
tagToResourceType 2 = Just Container
tagToResourceType _ = Nothing

||| Roundtrip proof: decoding an encoded ResourceType yields the original.
public export
resource_typeRoundtrip : (x : ResourceType) -> tagToResourceType (resource_typeToTag x) = Just x
resource_typeRoundtrip RdfSource = Refl
resource_typeRoundtrip NonRdfSource = Refl
resource_typeRoundtrip Container = Refl

---------------------------------------------------------------------------
-- Preference (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
preferenceSize : Nat
preferenceSize = 1

||| Preference sum type for ABI encoding.
public export
data Preference : Type where
  MinimalContainer : Preference
  IncludeContainment : Preference
  IncludeMembership : Preference
  OmitContainment : Preference
  OmitMembership : Preference

||| Encode a Preference to its ABI tag value.
public export
preferenceToTag : Preference -> Bits8
preferenceToTag MinimalContainer = 0
preferenceToTag IncludeContainment = 1
preferenceToTag IncludeMembership = 2
preferenceToTag OmitContainment = 3
preferenceToTag OmitMembership = 4

||| Decode an ABI tag to a Preference.
public export
tagToPreference : Bits8 -> Maybe Preference
tagToPreference 0 = Just MinimalContainer
tagToPreference 1 = Just IncludeContainment
tagToPreference 2 = Just IncludeMembership
tagToPreference 3 = Just OmitContainment
tagToPreference 4 = Just OmitMembership
tagToPreference _ = Nothing

||| Roundtrip proof: decoding an encoded Preference yields the original.
public export
preferenceRoundtrip : (x : Preference) -> tagToPreference (preferenceToTag x) = Just x
preferenceRoundtrip MinimalContainer = Refl
preferenceRoundtrip IncludeContainment = Refl
preferenceRoundtrip IncludeMembership = Refl
preferenceRoundtrip OmitContainment = Refl
preferenceRoundtrip OmitMembership = Refl

---------------------------------------------------------------------------
-- InteractionModel (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
interaction_modelSize : Nat
interaction_modelSize = 1

||| InteractionModel sum type for ABI encoding.
public export
data InteractionModel : Type where
  Ldpr : InteractionModel
  Ldpc : InteractionModel
  LdpBasicContainer : InteractionModel
  LdpDirectContainer : InteractionModel
  LdpIndirectContainer : InteractionModel

||| Encode a InteractionModel to its ABI tag value.
public export
interaction_modelToTag : InteractionModel -> Bits8
interaction_modelToTag Ldpr = 0
interaction_modelToTag Ldpc = 1
interaction_modelToTag LdpBasicContainer = 2
interaction_modelToTag LdpDirectContainer = 3
interaction_modelToTag LdpIndirectContainer = 4

||| Decode an ABI tag to a InteractionModel.
public export
tagToInteractionModel : Bits8 -> Maybe InteractionModel
tagToInteractionModel 0 = Just Ldpr
tagToInteractionModel 1 = Just Ldpc
tagToInteractionModel 2 = Just LdpBasicContainer
tagToInteractionModel 3 = Just LdpDirectContainer
tagToInteractionModel 4 = Just LdpIndirectContainer
tagToInteractionModel _ = Nothing

||| Roundtrip proof: decoding an encoded InteractionModel yields the original.
public export
interaction_modelRoundtrip : (x : InteractionModel) -> tagToInteractionModel (interaction_modelToTag x) = Just x
interaction_modelRoundtrip Ldpr = Refl
interaction_modelRoundtrip Ldpc = Refl
interaction_modelRoundtrip LdpBasicContainer = Refl
interaction_modelRoundtrip LdpDirectContainer = Refl
interaction_modelRoundtrip LdpIndirectContainer = Refl

---------------------------------------------------------------------------
-- ConstraintViolation (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
constraint_violationSize : Nat
constraint_violationSize = 1

||| ConstraintViolation sum type for ABI encoding.
public export
data ConstraintViolation : Type where
  MembershipConstant : ConstraintViolation
  ContainsTriplesModified : ConstraintViolation
  ServerManaged : ConstraintViolation
  TypeConflict : ConstraintViolation

||| Encode a ConstraintViolation to its ABI tag value.
public export
constraint_violationToTag : ConstraintViolation -> Bits8
constraint_violationToTag MembershipConstant = 0
constraint_violationToTag ContainsTriplesModified = 1
constraint_violationToTag ServerManaged = 2
constraint_violationToTag TypeConflict = 3

||| Decode an ABI tag to a ConstraintViolation.
public export
tagToConstraintViolation : Bits8 -> Maybe ConstraintViolation
tagToConstraintViolation 0 = Just MembershipConstant
tagToConstraintViolation 1 = Just ContainsTriplesModified
tagToConstraintViolation 2 = Just ServerManaged
tagToConstraintViolation 3 = Just TypeConflict
tagToConstraintViolation _ = Nothing

||| Roundtrip proof: decoding an encoded ConstraintViolation yields the original.
public export
constraint_violationRoundtrip : (x : ConstraintViolation) -> tagToConstraintViolation (constraint_violationToTag x) = Just x
constraint_violationRoundtrip MembershipConstant = Refl
constraint_violationRoundtrip ContainsTriplesModified = Refl
constraint_violationRoundtrip ServerManaged = Refl
constraint_violationRoundtrip TypeConflict = Refl

---------------------------------------------------------------------------
-- LdpError (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
ldp_errorSize : Nat
ldp_errorSize = 1

||| LdpError sum type for ABI encoding.
public export
data LdpError : Type where
  Ok : LdpError
  InvalidSlot : LdpError
  NotActive : LdpError
  ConstraintViolation : LdpError
  TypeConflict : LdpError
  CapacityExhausted : LdpError
  InvalidPreference : LdpError

||| Encode a LdpError to its ABI tag value.
public export
ldp_errorToTag : LdpError -> Bits8
ldp_errorToTag Ok = 0
ldp_errorToTag InvalidSlot = 1
ldp_errorToTag NotActive = 2
ldp_errorToTag ConstraintViolation = 3
ldp_errorToTag TypeConflict = 4
ldp_errorToTag CapacityExhausted = 5
ldp_errorToTag InvalidPreference = 6

||| Decode an ABI tag to a LdpError.
public export
tagToLdpError : Bits8 -> Maybe LdpError
tagToLdpError 0 = Just Ok
tagToLdpError 1 = Just InvalidSlot
tagToLdpError 2 = Just NotActive
tagToLdpError 3 = Just ConstraintViolation
tagToLdpError 4 = Just TypeConflict
tagToLdpError 5 = Just CapacityExhausted
tagToLdpError 6 = Just InvalidPreference
tagToLdpError _ = Nothing

||| Roundtrip proof: decoding an encoded LdpError yields the original.
public export
ldp_errorRoundtrip : (x : LdpError) -> tagToLdpError (ldp_errorToTag x) = Just x
ldp_errorRoundtrip Ok = Refl
ldp_errorRoundtrip InvalidSlot = Refl
ldp_errorRoundtrip NotActive = Refl
ldp_errorRoundtrip ConstraintViolation = Refl
ldp_errorRoundtrip TypeConflict = Refl
ldp_errorRoundtrip CapacityExhausted = Refl
ldp_errorRoundtrip InvalidPreference = Refl
