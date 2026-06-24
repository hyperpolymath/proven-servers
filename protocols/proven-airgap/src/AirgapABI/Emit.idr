-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- AirgapABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into airgap_abi_gen.zig for the comptime guard.

module AirgapABI.Emit

import Airgap.Types
import AirgapABI.Types
import AirgapABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "DIR" "IMPORT" (transferDirectionToTag Import)
  , line "DIR" "EXPORT" (transferDirectionToTag Export)
  , line "MEDIA" "USB"            (mediaTypeToTag USB)
  , line "MEDIA" "OPTICAL_DISC"   (mediaTypeToTag OpticalDisc)
  , line "MEDIA" "TAPE_CARTRIDGE" (mediaTypeToTag TapeCartridge)
  , line "MEDIA" "DIODE_LINK"     (mediaTypeToTag DiodeLink)
  , line "SCAN" "CLEAN"       (scanResultToTag Clean)
  , line "SCAN" "SUSPICIOUS"  (scanResultToTag Suspicious)
  , line "SCAN" "MALICIOUS"   (scanResultToTag Malicious)
  , line "SCAN" "UNSCANNABLE" (scanResultToTag Unscannable)
  , line "STATE" "PENDING"     (transferStateToTag Pending)
  , line "STATE" "SCANNING"    (transferStateToTag Scanning)
  , line "STATE" "APPROVED"    (transferStateToTag Approved)
  , line "STATE" "REJECTED"    (transferStateToTag Rejected)
  , line "STATE" "IN_PROGRESS" (transferStateToTag InProgress)
  , line "STATE" "COMPLETE"    (transferStateToTag Complete)
  , line "STATE" "FAILED"      (transferStateToTag Failed)
  , line "CHECK" "HASH_VERIFY"        (validationCheckToTag HashVerify)
  , line "CHECK" "SIGNATURE_VERIFY"   (validationCheckToTag SignatureVerify)
  , line "CHECK" "FORMAT_CHECK"       (validationCheckToTag FormatCheck)
  , line "CHECK" "CONTENT_INSPECTION" (validationCheckToTag ContentInspection)
  , line "CHECK" "MALWARE_SCAN"       (validationCheckToTag MalwareScan)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
