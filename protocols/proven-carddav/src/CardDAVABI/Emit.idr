-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CardDAVABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into carddav_abi_gen.zig for the comptime guard.

module CardDAVABI.Emit

import CardDAV.Types
import CardDAVABI.Types
import CardDAVABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "PROP" "FN"     (propertyTypeToTag PropFN)
  , line "PROP" "N"      (propertyTypeToTag PropN)
  , line "PROP" "EMAIL"  (propertyTypeToTag PropEmail)
  , line "PROP" "TEL"    (propertyTypeToTag PropTel)
  , line "PROP" "ADR"    (propertyTypeToTag PropAdr)
  , line "PROP" "ORG"    (propertyTypeToTag PropOrg)
  , line "PROP" "PHOTO"  (propertyTypeToTag PropPhoto)
  , line "PROP" "URL"    (propertyTypeToTag PropUrl)
  , line "PROP" "NOTE"   (propertyTypeToTag PropNote)
  , line "METHOD" "GET"       (cardMethodToTag CardGet)
  , line "METHOD" "PUT"       (cardMethodToTag CardPut)
  , line "METHOD" "DELETE"    (cardMethodToTag CardDelete)
  , line "METHOD" "PROPFIND"  (cardMethodToTag CardPropfind)
  , line "METHOD" "PROPPATCH" (cardMethodToTag CardProppatch)
  , line "METHOD" "REPORT"    (cardMethodToTag CardReport)
  , line "METHOD" "MKCOL"     (cardMethodToTag CardMkcol)
  , line "VER" "VCARD3" (vcardVersionToTag VCard3)
  , line "VER" "VCARD4" (vcardVersionToTag VCard4)
  , line "ERR" "VALID_ADDRESS_DATA"     (cardErrorToTag ValidAddressData)
  , line "ERR" "NO_RESOURCE_TYPE"       (cardErrorToTag NoResourceType)
  , line "ERR" "MAX_RESOURCE_SIZE"      (cardErrorToTag MaxResourceSize)
  , line "ERR" "UID_CONFLICT"           (cardErrorToTag UIDConflict)
  , line "ERR" "SUPPORTED_ADDRESS_DATA" (cardErrorToTag SupportedAddressData)
  , line "ERR" "PRECONDITION_FAILED"    (cardErrorToTag PreconditionFailed)
  , line "STATE" "IDLE"     (serverStateToTag SSIdle)
  , line "STATE" "BOUND"    (serverStateToTag SSBound)
  , line "STATE" "SERVING"  (serverStateToTag SSServing)
  , line "STATE" "SHUTDOWN" (serverStateToTag SSShutdown)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
