-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- OCSPABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into ocsp_abi_gen.zig for the comptime guard.

module OCSPABI.Emit

import OCSP.Types
import OCSPABI.Types
import OCSPABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "CERT" "GOOD"    (certStatusToTag Good)
  , line "CERT" "REVOKED" (certStatusToTag Revoked)
  , line "CERT" "UNKNOWN" (certStatusToTag Unknown)
  , line "RESPONSE" "SUCCESSFUL"        (responseStatusToTag Successful)
  , line "RESPONSE" "MALFORMED_REQUEST" (responseStatusToTag MalformedRequest)
  , line "RESPONSE" "INTERNAL_ERROR"    (responseStatusToTag InternalError)
  , line "RESPONSE" "TRY_LATER"         (responseStatusToTag TryLater)
  , line "RESPONSE" "SIG_REQUIRED"      (responseStatusToTag SigRequired)
  , line "RESPONSE" "UNAUTHORIZED"      (responseStatusToTag Unauthorized)
  , line "HASH" "SHA1"   (hashAlgorithmToTag SHA1)
  , line "HASH" "SHA256" (hashAlgorithmToTag SHA256)
  , line "HASH" "SHA384" (hashAlgorithmToTag SHA384)
  , line "HASH" "SHA512" (hashAlgorithmToTag SHA512)
  , line "STATE" "IDLE"       (responderStateToTag RSIdle)
  , line "STATE" "READY"      (responderStateToTag RSReady)
  , line "STATE" "PROCESSING" (responderStateToTag RSProcessing)
  , line "STATE" "SIGNING"    (responderStateToTag RSSigning)
  , line "STATE" "CLOSING"    (responderStateToTag RSClosing)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
