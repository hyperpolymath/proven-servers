-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- AuthserverABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into authserver_abi_gen.zig for the comptime guard.

module AuthserverABI.Emit

import Authserver.Types
import AuthserverABI.Types
import AuthserverABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "AUTHM" "PASSWORD"            (authMethodToTag Password)
  , line "AUTHM" "CERTIFICATE"         (authMethodToTag Certificate)
  , line "AUTHM" "OAUTH2"              (authMethodToTag OAuth2)
  , line "AUTHM" "SAML"               (authMethodToTag SAML)
  , line "AUTHM" "FIDO2"              (authMethodToTag FIDO2)
  , line "AUTHM" "KERBEROS"           (authMethodToTag Kerberos)
  , line "AUTHM" "LDAP"               (authMethodToTag LDAP)
  , line "AUTHM" "RADIUS"             (authMethodToTag RADIUS)
  , line "TOKEN" "ACCESS"             (tokenTypeToTag Access)
  , line "TOKEN" "REFRESH"            (tokenTypeToTag Refresh)
  , line "TOKEN" "ID"                 (tokenTypeToTag ID)
  , line "TOKEN" "API"                (tokenTypeToTag API)
  , line "RESULT" "SUCCESS"             (authResultToTag Success)
  , line "RESULT" "INVALID_CREDENTIALS" (authResultToTag InvalidCredentials)
  , line "RESULT" "ACCOUNT_LOCKED"      (authResultToTag AccountLocked)
  , line "RESULT" "ACCOUNT_EXPIRED"     (authResultToTag AccountExpired)
  , line "RESULT" "MFA_REQUIRED"        (authResultToTag MFARequired)
  , line "RESULT" "IP_BLOCKED"          (authResultToTag IPBlocked)
  , line "MFA" "TOTP"                 (mfaMethodToTag TOTP)
  , line "MFA" "SMS"                  (mfaMethodToTag SMS)
  , line "MFA" "PUSH"                 (mfaMethodToTag Push)
  , line "MFA" "FIDO2_MFA"            (mfaMethodToTag FIDO2_MFA)
  , line "MFA" "EMAIL"                (mfaMethodToTag Email)
  , line "SESSION" "ACTIVE"             (sessionStateToTag Active)
  , line "SESSION" "EXPIRED"            (sessionStateToTag Expired)
  , line "SESSION" "REVOKED"            (sessionStateToTag Revoked)
  , line "SESSION" "LOCKED"             (sessionStateToTag Locked)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
