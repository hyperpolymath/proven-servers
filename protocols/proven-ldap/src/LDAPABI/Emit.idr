-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- LDAPABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into ldap_abi_gen.zig for the comptime guard.

module LDAPABI.Emit

import LDAP.Types
import LDAPABI.Layout
import LDAPABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "SESSION" "ANONYMOUS" (sessionStateToTag Anonymous)
  , line "SESSION" "BOUND"     (sessionStateToTag Bound)
  , line "SESSION" "CLOSED"    (sessionStateToTag Closed)
  , line "SESSION" "BINDING"   (sessionStateToTag Binding)
  , line "OP" "BIND"     (operationToTag Bind)
  , line "OP" "UNBIND"   (operationToTag Unbind)
  , line "OP" "SEARCH"   (operationToTag Search)
  , line "OP" "MODIFY"   (operationToTag Modify)
  , line "OP" "ADD"      (operationToTag Add)
  , line "OP" "DELETE"   (operationToTag Delete)
  , line "OP" "MOD_DN"   (operationToTag ModDN)
  , line "OP" "COMPARE"  (operationToTag Compare)
  , line "OP" "ABANDON"  (operationToTag Abandon)
  , line "OP" "EXTENDED" (operationToTag Extended)
  , line "SCOPE" "BASE_OBJECT"   (searchScopeToTag BaseObject)
  , line "SCOPE" "SINGLE_LEVEL"  (searchScopeToTag SingleLevel)
  , line "SCOPE" "WHOLE_SUBTREE" (searchScopeToTag WholeSubtree)
  , line "RESULT" "SUCCESS"                    (resultCodeToTag Success)
  , line "RESULT" "OPERATIONS_ERROR"           (resultCodeToTag OperationsError)
  , line "RESULT" "PROTOCOL_ERROR"             (resultCodeToTag ProtocolError)
  , line "RESULT" "TIME_LIMIT_EXCEEDED"        (resultCodeToTag TimeLimitExceeded)
  , line "RESULT" "SIZE_LIMIT_EXCEEDED"        (resultCodeToTag SizeLimitExceeded)
  , line "RESULT" "AUTH_METHOD_NOT_SUPPORTED"  (resultCodeToTag AuthMethodNotSupported)
  , line "RESULT" "NO_SUCH_OBJECT"             (resultCodeToTag NoSuchObject)
  , line "RESULT" "INVALID_CREDENTIALS"        (resultCodeToTag InvalidCredentials)
  , line "RESULT" "INSUFFICIENT_ACCESS_RIGHTS" (resultCodeToTag InsufficientAccessRights)
  , line "RESULT" "BUSY"                        (resultCodeToTag Busy)
  , line "RESULT" "UNAVAILABLE"                 (resultCodeToTag Unavailable)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
