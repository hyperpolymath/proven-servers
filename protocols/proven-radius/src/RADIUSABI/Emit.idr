-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- RADIUSABI.Emit: the ABI tag-manifest emitter (single source of truth).
--
-- Prints a neutral manifest (`KIND NAME DECIMAL` lines, `LAYOUT NAME DECIMAL`
-- for sizes, and `ABI_VERSION n`) computed DIRECTLY from the proven encoders in
-- RADIUSABI.Layout / RADIUSABI.Transitions and the version in RADIUSABI.Foreign.
-- tools/gen-abi.sh renders this into the C header and the Zig constants so those
-- artifacts are definitionally the proven encoding -- not a hand-synced copy.

module RADIUSABI.Emit

import RADIUS.Types
import RADIUSABI.Layout
import RADIUSABI.Transitions
import RADIUSABI.Foreign

%default total

||| One enum-tag manifest line: `<KIND> <NAME> <DECIMAL>`.
line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

||| One layout-constant manifest line: `LAYOUT <NAME> <DECIMAL>`.
lineNat : String -> Nat -> String
lineNat name val = "LAYOUT " ++ name ++ " " ++ show val

||| The canonical manifest, derived from the proven `*ToTag` encoders and the
||| layout constants. The constructor lists are the only hand-written part;
||| because the encoders are total, adding a constructor forces a clause there
||| and a matching entry here.
manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "PACKET" "ACCESS_REQUEST"      (packetTypeToTag AccessRequest)
  , line "PACKET" "ACCESS_ACCEPT"       (packetTypeToTag AccessAccept)
  , line "PACKET" "ACCESS_REJECT"       (packetTypeToTag AccessReject)
  , line "PACKET" "ACCOUNTING_REQUEST"  (packetTypeToTag AccountingRequest)
  , line "PACKET" "ACCOUNTING_RESPONSE" (packetTypeToTag AccountingResponse)
  , line "PACKET" "ACCESS_CHALLENGE"    (packetTypeToTag AccessChallenge)
  , line "ATTR"   "USER_NAME"           (attributeTypeToTag UserName)
  , line "ATTR"   "USER_PASSWORD"       (attributeTypeToTag UserPassword)
  , line "ATTR"   "NAS_IP_ADDRESS"      (attributeTypeToTag NASIPAddress)
  , line "ATTR"   "NAS_PORT"            (attributeTypeToTag NASPort)
  , line "ATTR"   "SERVICE_TYPE"        (attributeTypeToTag ServiceTy)
  , line "ATTR"   "FRAMED_PROTOCOL"     (attributeTypeToTag FramedProtocol)
  , line "ATTR"   "FRAMED_IP_ADDRESS"   (attributeTypeToTag FramedIPAddr)
  , line "ATTR"   "REPLY_MESSAGE"       (attributeTypeToTag ReplyMessage)
  , line "ATTR"   "SESSION_TIMEOUT"     (attributeTypeToTag SessionTimeout)
  , line "SVC"    "LOGIN"               (serviceTypeToTag Login)
  , line "SVC"    "FRAMED"              (serviceTypeToTag Framed)
  , line "SVC"    "CALLBACK_LOGIN"      (serviceTypeToTag CallbackLogin)
  , line "SVC"    "CALLBACK_FRAMED"     (serviceTypeToTag CallbackFramed)
  , line "SVC"    "OUTBOUND"            (serviceTypeToTag Outbound)
  , line "SVC"    "ADMINISTRATIVE"      (serviceTypeToTag Administrative)
  , line "AUTH"   "PAP"                 (authMethodToTag PAP)
  , line "AUTH"   "CHAP"                (authMethodToTag CHAP)
  , line "AUTH"   "MSCHAP"              (authMethodToTag MSCHAP)
  , line "AUTH"   "MSCHAPV2"            (authMethodToTag MSCHAPv2)
  , line "AUTH"   "EAP"                 (authMethodToTag EAP)
  , line "STATE"  "IDLE"               (sessionStateToTag Idle)
  , line "STATE"  "AUTHENTICATING"     (sessionStateToTag Authenticating)
  , line "STATE"  "AUTHORIZED"         (sessionStateToTag Authorized)
  , line "STATE"  "REJECTED"           (sessionStateToTag Rejected)
  , line "STATE"  "CHALLENGED"         (sessionStateToTag Challenged)
  , line "STATE"  "ACCOUNTING"         (sessionStateToTag Accounting)
  , line "STATE"  "COMPLETE"           (sessionStateToTag Complete)
  , line "RESULT" "OK"                  (radiusResultToTag ROk)
  , line "RESULT" "ERR"                 (radiusResultToTag RError)
  , line "RESULT" "INVALID_PARAM"       (radiusResultToTag RInvalidParam)
  , line "RESULT" "POOL_EXHAUSTED"      (radiusResultToTag RPoolExhausted)
  , line "RESULT" "BAD_SECRET"          (radiusResultToTag RBadSecret)
  , lineNat "PACKET_HEADER_SIZE"     packetHeaderSize
  , lineNat "MAX_PACKET_SIZE"        maxPacketSize
  , lineNat "ATTRIBUTE_HEADER_SIZE"  attributeHeaderSize
  , lineNat "MAX_ATTRIBUTE_VALUE_LEN" maxAttributeValueLen
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
