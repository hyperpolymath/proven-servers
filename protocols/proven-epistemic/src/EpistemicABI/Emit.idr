-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- EpistemicABI.Emit: the ABI tag-manifest emitter (single source of truth).
--
-- Prints a neutral manifest (`KIND NAME DECIMAL` lines, plus `ABI_VERSION n`)
-- computed DIRECTLY from the proven encoders in EpistemicABI.Types and the
-- version in EpistemicABI.Foreign. tools/gen-abi.sh renders this manifest into
-- both the C header and the Zig constants file, so those artifacts are
-- definitionally the proven encoding -- not a hand-synced copy.
--
-- The only hand-written part is the constructor enumeration lists; because the
-- `*ToTag` functions are total, adding a constructor forces a new clause there
-- and a matching list entry here.

module EpistemicABI.Emit

import Epistemic.Types
import EpistemicABI.Types
import EpistemicABI.Foreign

%default total

||| One manifest line: `<KIND> <NAME> <DECIMAL>`.
line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

||| The canonical manifest, derived from the proven `*ToTag` encoders.
manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "TIER"    "BAND"                   (tierToTag Band)
  , line "TIER"    "RELATIONAL"             (tierToTag Relational)
  , line "TIER"    "FULL"                   (tierToTag Full)
  , line "REVEAL"  "INNOCUOUS"              (revealingnessToTag Innocuous)
  , line "REVEAL"  "CONTEXTUAL"             (revealingnessToTag Contextual)
  , line "REVEAL"  "SENSITIVE"              (revealingnessToTag Sensitive)
  , line "PURPOSE" "IDENTIFICATION"         (purposeToTag Identification)
  , line "PURPOSE" "ELIGIBILITY"            (purposeToTag Eligibility)
  , line "PURPOSE" "COMPATIBILITY"          (purposeToTag Compatibility)
  , line "PURPOSE" "CONTRACTUAL"            (purposeToTag Contractual)
  , line "PURPOSE" "AUDIT"                  (purposeToTag Audit)
  , line "PHASE"   "INITIATED"              (phaseToTag Initiated)
  , line "PHASE"   "TIERS_AGREED"           (phaseToTag TiersAgreed)
  , line "PHASE"   "DISCLOSING"             (phaseToTag Disclosing)
  , line "PHASE"   "CLOSED"                 (phaseToTag Closed)
  , line "ERR"     "TIER_EXCEEDED"          (errorToTag TierExceeded)
  , line "ERR"     "UNKNOWN_FIELD"          (errorToTag UnknownField)
  , line "ERR"     "NO_ACTIVE_SESSION"      (errorToTag NoActiveSession)
  , line "ERR"     "SESSION_ALREADY_CLOSED" (errorToTag SessionAlreadyClosed)
  , line "ERR"     "ILL_GOVERNED"           (errorToTag IllGoverned)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
