-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ConfigABI.Layout: C-ABI-compatible numeric representations of config types.
--
-- Maps every constructor of the five core sum types (ConfigSource,
-- ValidationResult, SecurityPolicy, OverrideLevel, ConfigError) to fixed
-- Bits8 values for C interop. Each type gets a total encoder, partial
-- decoder, and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/config.h) and the
-- Zig FFI enums (ffi/zig/src/config.zig) exactly.

module ConfigABI.Layout

import Config.Types

%default total

---------------------------------------------------------------------------
-- ConfigSource (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
configSourceSize : Nat
configSourceSize = 1

public export
configSourceToTag : ConfigSource -> Bits8
configSourceToTag File        = 0
configSourceToTag Environment = 1
configSourceToTag CommandLine = 2
configSourceToTag Default     = 3
configSourceToTag Remote      = 4

public export
tagToConfigSource : Bits8 -> Maybe ConfigSource
tagToConfigSource 0 = Just File
tagToConfigSource 1 = Just Environment
tagToConfigSource 2 = Just CommandLine
tagToConfigSource 3 = Just Default
tagToConfigSource 4 = Just Remote
tagToConfigSource _ = Nothing

public export
configSourceRoundtrip : (s : ConfigSource) -> tagToConfigSource (configSourceToTag s) = Just s
configSourceRoundtrip File        = Refl
configSourceRoundtrip Environment = Refl
configSourceRoundtrip CommandLine = Refl
configSourceRoundtrip Default     = Refl
configSourceRoundtrip Remote      = Refl

---------------------------------------------------------------------------
-- ValidationResult (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
validationResultSize : Nat
validationResultSize = 1

public export
validationResultToTag : ValidationResult -> Bits8
validationResultToTag Valid             = 0
validationResultToTag InvalidValue      = 1
validationResultToTag MissingRequired   = 2
validationResultToTag SecurityViolation = 3
validationResultToTag TypeMismatch      = 4
validationResultToTag OutOfRange        = 5

public export
tagToValidationResult : Bits8 -> Maybe ValidationResult
tagToValidationResult 0 = Just Valid
tagToValidationResult 1 = Just InvalidValue
tagToValidationResult 2 = Just MissingRequired
tagToValidationResult 3 = Just SecurityViolation
tagToValidationResult 4 = Just TypeMismatch
tagToValidationResult 5 = Just OutOfRange
tagToValidationResult _ = Nothing

public export
validationResultRoundtrip : (v : ValidationResult) -> tagToValidationResult (validationResultToTag v) = Just v
validationResultRoundtrip Valid             = Refl
validationResultRoundtrip InvalidValue      = Refl
validationResultRoundtrip MissingRequired   = Refl
validationResultRoundtrip SecurityViolation = Refl
validationResultRoundtrip TypeMismatch      = Refl
validationResultRoundtrip OutOfRange        = Refl

---------------------------------------------------------------------------
-- SecurityPolicy (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
securityPolicySize : Nat
securityPolicySize = 1

public export
securityPolicyToTag : SecurityPolicy -> Bits8
securityPolicyToTag RequireTLS        = 0
securityPolicyToTag RequireAuth       = 1
securityPolicyToTag RequireEncryption = 2
securityPolicyToTag AllowPlaintext    = 3
securityPolicyToTag AllowAnonymous    = 4

public export
tagToSecurityPolicy : Bits8 -> Maybe SecurityPolicy
tagToSecurityPolicy 0 = Just RequireTLS
tagToSecurityPolicy 1 = Just RequireAuth
tagToSecurityPolicy 2 = Just RequireEncryption
tagToSecurityPolicy 3 = Just AllowPlaintext
tagToSecurityPolicy 4 = Just AllowAnonymous
tagToSecurityPolicy _ = Nothing

public export
securityPolicyRoundtrip : (p : SecurityPolicy) -> tagToSecurityPolicy (securityPolicyToTag p) = Just p
securityPolicyRoundtrip RequireTLS        = Refl
securityPolicyRoundtrip RequireAuth       = Refl
securityPolicyRoundtrip RequireEncryption = Refl
securityPolicyRoundtrip AllowPlaintext    = Refl
securityPolicyRoundtrip AllowAnonymous    = Refl

---------------------------------------------------------------------------
-- OverrideLevel (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
overrideLevelSize : Nat
overrideLevelSize = 1

public export
overrideLevelToTag : OverrideLevel -> Bits8
overrideLevelToTag Default   = 0
overrideLevelToTag User      = 1
overrideLevelToTag Admin     = 2
overrideLevelToTag Emergency = 3

public export
tagToOverrideLevel : Bits8 -> Maybe OverrideLevel
tagToOverrideLevel 0 = Just Default
tagToOverrideLevel 1 = Just User
tagToOverrideLevel 2 = Just Admin
tagToOverrideLevel 3 = Just Emergency
tagToOverrideLevel _ = Nothing

public export
overrideLevelRoundtrip : (l : OverrideLevel) -> tagToOverrideLevel (overrideLevelToTag l) = Just l
overrideLevelRoundtrip Default   = Refl
overrideLevelRoundtrip User      = Refl
overrideLevelRoundtrip Admin     = Refl
overrideLevelRoundtrip Emergency = Refl

---------------------------------------------------------------------------
-- ConfigError (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
configErrorSize : Nat
configErrorSize = 1

public export
configErrorToTag : ConfigError -> Bits8
configErrorToTag ParseError        = 0
configErrorToTag SchemaViolation   = 1
configErrorToTag SecurityDowngrade = 2
configErrorToTag ConflictingValues = 3
configErrorToTag UnknownKey        = 4

public export
tagToConfigError : Bits8 -> Maybe ConfigError
tagToConfigError 0 = Just ParseError
tagToConfigError 1 = Just SchemaViolation
tagToConfigError 2 = Just SecurityDowngrade
tagToConfigError 3 = Just ConflictingValues
tagToConfigError 4 = Just UnknownKey
tagToConfigError _ = Nothing

public export
configErrorRoundtrip : (e : ConfigError) -> tagToConfigError (configErrorToTag e) = Just e
configErrorRoundtrip ParseError        = Refl
configErrorRoundtrip SchemaViolation   = Refl
configErrorRoundtrip SecurityDowngrade = Refl
configErrorRoundtrip ConflictingValues = Refl
configErrorRoundtrip UnknownKey        = Refl

---------------------------------------------------------------------------
-- Override precedence comparison
---------------------------------------------------------------------------

||| Whether override level a has higher precedence than override level b.
||| Emergency > Admin > User > Default.
public export
overridePrecedence : OverrideLevel -> Nat
overridePrecedence Default   = 0
overridePrecedence User      = 1
overridePrecedence Admin     = 2
overridePrecedence Emergency = 3

||| Whether the first override level dominates the second.
public export
overrideDominates : OverrideLevel -> OverrideLevel -> Bool
overrideDominates a b = overridePrecedence a > overridePrecedence b

---------------------------------------------------------------------------
-- Security policy compatibility
---------------------------------------------------------------------------

||| Whether a security policy is restrictive (requires something).
public export
isRestrictive : SecurityPolicy -> Bool
isRestrictive RequireTLS        = True
isRestrictive RequireAuth       = True
isRestrictive RequireEncryption = True
isRestrictive AllowPlaintext    = False
isRestrictive AllowAnonymous    = False

||| Whether a security policy is permissive (allows something).
public export
isPermissive : SecurityPolicy -> Bool
isPermissive p = not (isRestrictive p)
