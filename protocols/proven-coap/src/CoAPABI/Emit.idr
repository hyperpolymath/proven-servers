-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CoAPABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into coap_abi_gen.zig for the comptime guard.

module CoAPABI.Emit

import CoAP.Types
import CoAPABI.Types
import CoAPABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "METHOD" "GET"    (methodToTag Get)
  , line "METHOD" "POST"   (methodToTag Post)
  , line "METHOD" "PUT"    (methodToTag Put)
  , line "METHOD" "DELETE" (methodToTag Delete)
  , line "MSGTYPE" "CONFIRMABLE"     (messageTypeToTag Confirmable)
  , line "MSGTYPE" "NON_CONFIRMABLE" (messageTypeToTag NonConfirmable)
  , line "MSGTYPE" "ACKNOWLEDGEMENT" (messageTypeToTag Acknowledgement)
  , line "MSGTYPE" "RESET"           (messageTypeToTag Reset)
  , line "FORMAT" "TEXT_PLAIN"   (contentFormatToTag TextPlain)
  , line "FORMAT" "LINK_FORMAT"  (contentFormatToTag LinkFormat)
  , line "FORMAT" "XML"          (contentFormatToTag XML)
  , line "FORMAT" "OCTET_STREAM" (contentFormatToTag OctetStream)
  , line "FORMAT" "EXI"          (contentFormatToTag EXI)
  , line "FORMAT" "JSON"         (contentFormatToTag JSON)
  , line "FORMAT" "CBOR"         (contentFormatToTag CBOR)
  , line "RESPCLASS" "SUCCESS"      (responseClassToTag Success)
  , line "RESPCLASS" "CLIENT_ERROR" (responseClassToTag ClientError)
  , line "RESPCLASS" "SERVER_ERROR" (responseClassToTag ServerError)
  , line "RESPCLASS" "SIGNALING"    (responseClassToTag Signaling)
  , line "RESPCLASS" "EMPTY"        (responseClassToTag Empty)
  , line "STATE" "IDLE"      (sessionStateToTag SSIdle)
  , line "STATE" "BOUND"     (sessionStateToTag SSBound)
  , line "STATE" "SERVING"   (sessionStateToTag SSServing)
  , line "STATE" "OBSERVING" (sessionStateToTag SSObserving)
  , line "STATE" "SHUTDOWN"  (sessionStateToTag SSShutdown)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
