-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DiodeABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into diode_abi_gen.zig for the comptime guard.

module DiodeABI.Emit

import Diode.Types
import DiodeABI.Types
import DiodeABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "DIR" "HIGH_TO_LOW" (directionToTag HighToLow)
  , line "DIR" "LOW_TO_HIGH" (directionToTag LowToHigh)
  , line "PROTO" "UDP"           (protocolToTag UDP)
  , line "PROTO" "TCP"           (protocolToTag TCP)
  , line "PROTO" "FILE_TRANSFER" (protocolToTag FileTransfer)
  , line "PROTO" "SYSLOG"        (protocolToTag Syslog)
  , line "PROTO" "SNMP"          (protocolToTag SNMP)
  , line "XFER" "QUEUED"     (transferStateToTag Queued)
  , line "XFER" "SENDING"    (transferStateToTag Sending)
  , line "XFER" "CONFIRMING" (transferStateToTag Confirming)
  , line "XFER" "COMPLETE"   (transferStateToTag Complete)
  , line "XFER" "FAILED"     (transferStateToTag Failed)
  , line "VALID" "PASSED"         (validationResultToTag Passed)
  , line "VALID" "FORMAT_ERROR"   (validationResultToTag FormatError)
  , line "VALID" "SIZE_EXCEEDED"  (validationResultToTag SizeExceeded)
  , line "VALID" "POLICY_BLOCKED" (validationResultToTag PolicyBlocked)
  , line "INTEG" "CRC32"  (integrityCheckToTag CRC32)
  , line "INTEG" "SHA256" (integrityCheckToTag SHA256)
  , line "INTEG" "HMAC"   (integrityCheckToTag HMAC)
  , line "GW" "IDLE"         (gatewayStateToTag GSIdle)
  , line "GW" "CONFIGURED"   (gatewayStateToTag GSConfigured)
  , line "GW" "TRANSFERRING" (gatewayStateToTag GSTransferring)
  , line "GW" "VALIDATING"   (gatewayStateToTag GSValidating)
  , line "GW" "SHUTDOWN"     (gatewayStateToTag GSShutdown)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
