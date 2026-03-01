-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-authconn.
-- Prints the connector name and shows all type constructors.

module Main

import AuthConn

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-authconn type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-authconn — Authentication provider connector interface types"
  putStrLn ""
  showConstructors "AuthMethod"
    [ show PasswordHash, show Certificate, show Token, show MFA
    , show Kerberos, show SAML, show OIDC ]
  showConstructors "AuthState"
    [ show Unauthenticated, show Challenging, show Authenticated
    , show Expired, show Revoked, show Locked ]
  showConstructors "TokenState"
    [ show Valid, show Expired, show Revoked, show Refreshing ]
  showConstructors "CredentialType"
    [ show Opaque, show Hashed, show Encrypted, show Delegated ]
  showConstructors "AuthError"
    [ show InvalidCredentials, show AccountLocked, show TokenExpired
    , show MFARequired, show ProviderUnavailable, show InsufficientScope
    , show SessionExpired ]
  putStrLn ""
  putStrLn $ "  maxTokenLifetime   = " ++ show maxTokenLifetime
  putStrLn $ "  maxRefreshLifetime = " ++ show maxRefreshLifetime
  putStrLn $ "  maxLoginAttempts   = " ++ show maxLoginAttempts
  putStrLn $ "  lockoutDuration    = " ++ show lockoutDuration
