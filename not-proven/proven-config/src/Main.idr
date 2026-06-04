-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-config.
-- Prints the primitive name and shows all type constructors.

module Main

import Config

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-config type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-config — Configuration validation"
  putStrLn ""
  showConstructors "ConfigSource"
    [ show File, show Environment, show CommandLine
    , show Default, show Remote ]
  showConstructors "ValidationResult"
    [ show Valid, show InvalidValue, show MissingRequired
    , show SecurityViolation, show TypeMismatch, show OutOfRange ]
  showConstructors "SecurityPolicy"
    [ show RequireTLS, show RequireAuth, show RequireEncryption
    , show AllowPlaintext, show AllowAnonymous ]
  showConstructors "OverrideLevel"
    [ show Default, show User, show Admin, show Emergency ]
  showConstructors "ConfigError"
    [ show ParseError, show SchemaViolation, show SecurityDowngrade
    , show ConflictingValues, show UnknownKey ]
  putStrLn ""
  putStrLn $ "  maxConfigSize = " ++ show maxConfigSize
