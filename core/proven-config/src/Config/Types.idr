-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Config.Types: Core type definitions for configuration validation.
-- Closed sum types representing config sources, validation results,
-- security policies, override levels, and config errors. These types
-- prevent defeating security defaults — e.g., a config cannot set
-- port=23 if TLS is required.

module Config.Types

%default total

---------------------------------------------------------------------------
-- Config source — where a configuration value originated.
---------------------------------------------------------------------------

||| The source of a configuration value, ordered by precedence.
public export
data ConfigSource : Type where
  ||| Loaded from a configuration file.
  File        : ConfigSource
  ||| Read from an environment variable.
  Environment : ConfigSource
  ||| Supplied on the command line.
  CommandLine : ConfigSource
  ||| A built-in default value.
  Default     : ConfigSource
  ||| Fetched from a remote configuration service.
  Remote      : ConfigSource

public export
Show ConfigSource where
  show File        = "File"
  show Environment = "Environment"
  show CommandLine = "CommandLine"
  show Default     = "Default"
  show Remote      = "Remote"

---------------------------------------------------------------------------
-- Validation result — the outcome of validating a config value.
---------------------------------------------------------------------------

||| The result of validating a configuration value.
public export
data ValidationResult : Type where
  ||| The value is valid.
  Valid             : ValidationResult
  ||| The value is invalid for its expected type or format.
  InvalidValue      : ValidationResult
  ||| A required configuration key is missing.
  MissingRequired   : ValidationResult
  ||| The value violates a security policy.
  SecurityViolation : ValidationResult
  ||| The value type does not match the schema.
  TypeMismatch      : ValidationResult
  ||| The value is outside the allowed range.
  OutOfRange        : ValidationResult

public export
Show ValidationResult where
  show Valid             = "Valid"
  show InvalidValue      = "InvalidValue"
  show MissingRequired   = "MissingRequired"
  show SecurityViolation = "SecurityViolation"
  show TypeMismatch      = "TypeMismatch"
  show OutOfRange        = "OutOfRange"

---------------------------------------------------------------------------
-- Security policy — required security properties.
---------------------------------------------------------------------------

||| Security policies that constrain configuration values.
public export
data SecurityPolicy : Type where
  ||| TLS must be enabled; plaintext is forbidden.
  RequireTLS        : SecurityPolicy
  ||| Authentication must be enabled.
  RequireAuth       : SecurityPolicy
  ||| All data must be encrypted.
  RequireEncryption : SecurityPolicy
  ||| Plaintext connections are allowed (security downgrade).
  AllowPlaintext    : SecurityPolicy
  ||| Anonymous / unauthenticated access is allowed.
  AllowAnonymous    : SecurityPolicy

public export
Show SecurityPolicy where
  show RequireTLS        = "RequireTLS"
  show RequireAuth       = "RequireAuth"
  show RequireEncryption = "RequireEncryption"
  show AllowPlaintext    = "AllowPlaintext"
  show AllowAnonymous    = "AllowAnonymous"

---------------------------------------------------------------------------
-- Override level — the privilege level of a config override.
---------------------------------------------------------------------------

||| The privilege level at which a configuration override was applied.
public export
data OverrideLevel : Type where
  ||| The built-in default value (lowest precedence).
  Default   : OverrideLevel
  ||| A user-level override.
  User      : OverrideLevel
  ||| An administrator-level override.
  Admin     : OverrideLevel
  ||| An emergency override (highest precedence, bypasses guards).
  Emergency : OverrideLevel

public export
Show OverrideLevel where
  show Default   = "Default"
  show User      = "User"
  show Admin     = "Admin"
  show Emergency = "Emergency"

---------------------------------------------------------------------------
-- Config error — errors that arise during configuration processing.
---------------------------------------------------------------------------

||| Errors that can arise during configuration loading and validation.
public export
data ConfigError : Type where
  ||| The configuration file or value could not be parsed.
  ParseError        : ConfigError
  ||| The configuration violates its schema.
  SchemaViolation   : ConfigError
  ||| The configuration would downgrade security from the current level.
  SecurityDowngrade : ConfigError
  ||| Two configuration values conflict with each other.
  ConflictingValues : ConfigError
  ||| An unrecognised configuration key was encountered.
  UnknownKey        : ConfigError

public export
Show ConfigError where
  show ParseError        = "ParseError"
  show SchemaViolation   = "SchemaViolation"
  show SecurityDowngrade = "SecurityDowngrade"
  show ConflictingValues = "ConflictingValues"
  show UnknownKey        = "UnknownKey"
