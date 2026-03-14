-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AuditABI.Layout: C-ABI-compatible numeric representations of audit types.
--
-- Maps every constructor of the five core sum types (AuditLevel,
-- EventCategory, Integrity, RetentionPolicy, AuditError) to fixed Bits8
-- values for C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- The roundtrip proofs are formal verification: they guarantee at compile time
-- that encoding/decoding never loses information.  These proofs compile away
-- to zero runtime overhead thanks to Idris2's erasure.
--
-- Tag values here MUST match the C header (generated/abi/audit.h) and the
-- Zig FFI enums (ffi/zig/src/audit.zig) exactly.

module AuditABI.Layout

import Audit.Types

%default total

---------------------------------------------------------------------------
-- AuditLevel (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for AuditLevel (1 byte).
public export
auditLevelSize : Nat
auditLevelSize = 1

||| Map AuditLevel to its C-ABI byte value.
|||
||| Tag assignments:
|||   None     = 0
|||   Minimal  = 1
|||   Standard = 2
|||   Verbose  = 3
|||   Full     = 4
public export
auditLevelToTag : AuditLevel -> Bits8
auditLevelToTag None     = 0
auditLevelToTag Minimal  = 1
auditLevelToTag Standard = 2
auditLevelToTag Verbose  = 3
auditLevelToTag Full     = 4

||| Recover AuditLevel from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-4.
public export
tagToAuditLevel : Bits8 -> Maybe AuditLevel
tagToAuditLevel 0 = Just None
tagToAuditLevel 1 = Just Minimal
tagToAuditLevel 2 = Just Standard
tagToAuditLevel 3 = Just Verbose
tagToAuditLevel 4 = Just Full
tagToAuditLevel _ = Nothing

||| Proof: encoding then decoding AuditLevel is the identity.
public export
auditLevelRoundtrip : (l : AuditLevel) -> tagToAuditLevel (auditLevelToTag l) = Just l
auditLevelRoundtrip None     = Refl
auditLevelRoundtrip Minimal  = Refl
auditLevelRoundtrip Standard = Refl
auditLevelRoundtrip Verbose  = Refl
auditLevelRoundtrip Full     = Refl

---------------------------------------------------------------------------
-- EventCategory (8 constructors, tags 0-7)
---------------------------------------------------------------------------

||| C-ABI representation size for EventCategory (1 byte).
public export
eventCategorySize : Nat
eventCategorySize = 1

||| Map EventCategory to its C-ABI byte value.
|||
||| Tag assignments:
|||   StateTransition = 0
|||   Authentication  = 1
|||   Authorization   = 2
|||   DataAccess      = 3
|||   Configuration   = 4
|||   Error           = 5
|||   Security        = 6
|||   Lifecycle       = 7
public export
eventCategoryToTag : EventCategory -> Bits8
eventCategoryToTag StateTransition = 0
eventCategoryToTag Authentication  = 1
eventCategoryToTag Authorization   = 2
eventCategoryToTag DataAccess      = 3
eventCategoryToTag Configuration   = 4
eventCategoryToTag Error           = 5
eventCategoryToTag Security        = 6
eventCategoryToTag Lifecycle       = 7

||| Recover EventCategory from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-7.
public export
tagToEventCategory : Bits8 -> Maybe EventCategory
tagToEventCategory 0 = Just StateTransition
tagToEventCategory 1 = Just Authentication
tagToEventCategory 2 = Just Authorization
tagToEventCategory 3 = Just DataAccess
tagToEventCategory 4 = Just Configuration
tagToEventCategory 5 = Just Error
tagToEventCategory 6 = Just Security
tagToEventCategory 7 = Just Lifecycle
tagToEventCategory _ = Nothing

||| Proof: encoding then decoding EventCategory is the identity.
public export
eventCategoryRoundtrip : (c : EventCategory) -> tagToEventCategory (eventCategoryToTag c) = Just c
eventCategoryRoundtrip StateTransition = Refl
eventCategoryRoundtrip Authentication  = Refl
eventCategoryRoundtrip Authorization   = Refl
eventCategoryRoundtrip DataAccess      = Refl
eventCategoryRoundtrip Configuration   = Refl
eventCategoryRoundtrip Error           = Refl
eventCategoryRoundtrip Security        = Refl
eventCategoryRoundtrip Lifecycle       = Refl

---------------------------------------------------------------------------
-- Integrity (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for Integrity (1 byte).
public export
integritySize : Nat
integritySize = 1

||| Map Integrity to its C-ABI byte value.
|||
||| Tag assignments:
|||   Unsigned    = 0
|||   HMAC        = 1
|||   Signed      = 2
|||   Chained     = 3
|||   MerkleProof = 4
public export
integrityToTag : Integrity -> Bits8
integrityToTag Unsigned    = 0
integrityToTag HMAC        = 1
integrityToTag Signed      = 2
integrityToTag Chained     = 3
integrityToTag MerkleProof = 4

||| Recover Integrity from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-4.
public export
tagToIntegrity : Bits8 -> Maybe Integrity
tagToIntegrity 0 = Just Unsigned
tagToIntegrity 1 = Just HMAC
tagToIntegrity 2 = Just Signed
tagToIntegrity 3 = Just Chained
tagToIntegrity 4 = Just MerkleProof
tagToIntegrity _ = Nothing

||| Proof: encoding then decoding Integrity is the identity.
public export
integrityRoundtrip : (i : Integrity) -> tagToIntegrity (integrityToTag i) = Just i
integrityRoundtrip Unsigned    = Refl
integrityRoundtrip HMAC        = Refl
integrityRoundtrip Signed      = Refl
integrityRoundtrip Chained     = Refl
integrityRoundtrip MerkleProof = Refl

---------------------------------------------------------------------------
-- RetentionPolicy (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for RetentionPolicy (1 byte).
public export
retentionPolicySize : Nat
retentionPolicySize = 1

||| Map RetentionPolicy to its C-ABI byte value.
|||
||| Tag assignments:
|||   Ephemeral  = 0
|||   Session    = 1
|||   Daily      = 2
|||   Indefinite = 3
|||   Regulatory = 4
public export
retentionPolicyToTag : RetentionPolicy -> Bits8
retentionPolicyToTag Ephemeral  = 0
retentionPolicyToTag Session    = 1
retentionPolicyToTag Daily      = 2
retentionPolicyToTag Indefinite = 3
retentionPolicyToTag Regulatory = 4

||| Recover RetentionPolicy from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-4.
public export
tagToRetentionPolicy : Bits8 -> Maybe RetentionPolicy
tagToRetentionPolicy 0 = Just Ephemeral
tagToRetentionPolicy 1 = Just Session
tagToRetentionPolicy 2 = Just Daily
tagToRetentionPolicy 3 = Just Indefinite
tagToRetentionPolicy 4 = Just Regulatory
tagToRetentionPolicy _ = Nothing

||| Proof: encoding then decoding RetentionPolicy is the identity.
public export
retentionPolicyRoundtrip : (p : RetentionPolicy) -> tagToRetentionPolicy (retentionPolicyToTag p) = Just p
retentionPolicyRoundtrip Ephemeral  = Refl
retentionPolicyRoundtrip Session    = Refl
retentionPolicyRoundtrip Daily      = Refl
retentionPolicyRoundtrip Indefinite = Refl
retentionPolicyRoundtrip Regulatory = Refl

---------------------------------------------------------------------------
-- AuditError (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for AuditError (1 byte).
public export
auditErrorSize : Nat
auditErrorSize = 1

||| Map AuditError to its C-ABI byte value.
|||
||| Tag assignments:
|||   StorageFull        = 0
|||   WriteFailure       = 1
|||   IntegrityViolation = 2
|||   TimestampError     = 3
|||   ChainBroken        = 4
public export
auditErrorToTag : AuditError -> Bits8
auditErrorToTag StorageFull        = 0
auditErrorToTag WriteFailure       = 1
auditErrorToTag IntegrityViolation = 2
auditErrorToTag TimestampError     = 3
auditErrorToTag ChainBroken        = 4

||| Recover AuditError from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-4.
public export
tagToAuditError : Bits8 -> Maybe AuditError
tagToAuditError 0 = Just StorageFull
tagToAuditError 1 = Just WriteFailure
tagToAuditError 2 = Just IntegrityViolation
tagToAuditError 3 = Just TimestampError
tagToAuditError 4 = Just ChainBroken
tagToAuditError _ = Nothing

||| Proof: encoding then decoding AuditError is the identity.
public export
auditErrorRoundtrip : (e : AuditError) -> tagToAuditError (auditErrorToTag e) = Just e
auditErrorRoundtrip StorageFull        = Refl
auditErrorRoundtrip WriteFailure       = Refl
auditErrorRoundtrip IntegrityViolation = Refl
auditErrorRoundtrip TimestampError     = Refl
auditErrorRoundtrip ChainBroken        = Refl
