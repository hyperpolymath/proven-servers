-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CTLogABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into ctlog_abi_gen.zig for the comptime guard.

module CTLogABI.Emit

import CTLog.Types
import CTLogABI.Types
import CTLogABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "ENTRY" "X509_ENTRY"             (logEntryTypeToTag X509Entry)
  , line "ENTRY" "PRECERT_ENTRY"          (logEntryTypeToTag PrecertEntry)
  , line "SIG" "CERTIFICATE_TIMESTAMP"    (signatureTypeToTag CertificateTimestamp)
  , line "SIG" "TREE_HASH"                (signatureTypeToTag TreeHash)
  , line "LEAF" "TIMESTAMPED_ENTRY"       (merkleLeafTypeToTag TimestampedEntry)
  , line "SUBMIT" "ACCEPTED"              (submissionStatusToTag Accepted)
  , line "SUBMIT" "DUPLICATE"             (submissionStatusToTag Duplicate)
  , line "SUBMIT" "RATE_LIMITED"          (submissionStatusToTag RateLimited)
  , line "SUBMIT" "REJECTED"              (submissionStatusToTag Rejected)
  , line "SUBMIT" "INVALID_CHAIN"         (submissionStatusToTag InvalidChain)
  , line "SUBMIT" "UNKNOWN_ANCHOR"        (submissionStatusToTag UnknownAnchor)
  , line "VERIFY" "VALID_PROOF"           (verificationResultToTag ValidProof)
  , line "VERIFY" "INVALID_PROOF"         (verificationResultToTag InvalidProof)
  , line "VERIFY" "INCONSISTENT_TREE"     (verificationResultToTag InconsistentTree)
  , line "VERIFY" "STALE_STH"             (verificationResultToTag StaleSTH)
  , line "STATE" "IDLE"                   (serverStateToTag SSIdle)
  , line "STATE" "ACTIVE"                 (serverStateToTag SSActive)
  , line "STATE" "MERGING"                (serverStateToTag SSMerging)
  , line "STATE" "SIGNING"                (serverStateToTag SSSigning)
  , line "STATE" "SHUTDOWN"               (serverStateToTag SSShutdown)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
