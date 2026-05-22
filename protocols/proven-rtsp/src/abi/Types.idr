-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- RTSPABI.Types: C-ABI-compatible numeric representations of RTSP types.
--
-- Maps every constructor of the RTSP domain types (Method, TransportProtocol,
-- SessionState, StatusCode) to fixed Bits8 values for C interop.
-- Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/rtsp.zig) exactly.

module RTSPABI.Types

import RTSP.Types

%default total

---------------------------------------------------------------------------
-- Method (11 constructors, tags 0-10)
---------------------------------------------------------------------------

||| C-ABI representation size for Method (1 byte).
public export
methodSize : Nat
methodSize = 1

||| Map Method to its C-ABI byte value.
|||
||| Tag assignments:
|||   Describe     = 0    Setup        = 1    Play    = 2
|||   Pause        = 3    Teardown     = 4    GetParameter = 5
|||   SetParameter = 6    Options      = 7    Announce = 8
|||   Record       = 9    Redirect     = 10
public export
methodToTag : Method -> Bits8
methodToTag Describe     = 0
methodToTag Setup        = 1
methodToTag Play         = 2
methodToTag Pause        = 3
methodToTag Teardown     = 4
methodToTag GetParameter = 5
methodToTag SetParameter = 6
methodToTag Options      = 7
methodToTag Announce     = 8
methodToTag Record       = 9
methodToTag Redirect     = 10

||| Recover Method from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-10.
public export
tagToMethod : Bits8 -> Maybe Method
tagToMethod 0  = Just Describe
tagToMethod 1  = Just Setup
tagToMethod 2  = Just Play
tagToMethod 3  = Just Pause
tagToMethod 4  = Just Teardown
tagToMethod 5  = Just GetParameter
tagToMethod 6  = Just SetParameter
tagToMethod 7  = Just Options
tagToMethod 8  = Just Announce
tagToMethod 9  = Just Record
tagToMethod 10 = Just Redirect
tagToMethod _  = Nothing

||| Proof: encoding then decoding Method is the identity.
public export
methodRoundtrip : (m : Method) -> tagToMethod (methodToTag m) = Just m
methodRoundtrip Describe     = Refl
methodRoundtrip Setup        = Refl
methodRoundtrip Play         = Refl
methodRoundtrip Pause        = Refl
methodRoundtrip Teardown     = Refl
methodRoundtrip GetParameter = Refl
methodRoundtrip SetParameter = Refl
methodRoundtrip Options      = Refl
methodRoundtrip Announce     = Refl
methodRoundtrip Record       = Refl
methodRoundtrip Redirect     = Refl

---------------------------------------------------------------------------
-- TransportProtocol (3 constructors, tags 0-2)
---------------------------------------------------------------------------

||| C-ABI representation size for TransportProtocol (1 byte).
public export
transportProtocolSize : Nat
transportProtocolSize = 1

||| Map TransportProtocol to its C-ABI byte value.
|||
||| Tag assignments:
|||   RTP_AVP_UDP           = 0
|||   RTP_AVP_TCP           = 1
|||   RTP_AVP_UDP_Multicast = 2
public export
transportProtocolToTag : TransportProtocol -> Bits8
transportProtocolToTag RTP_AVP_UDP           = 0
transportProtocolToTag RTP_AVP_TCP           = 1
transportProtocolToTag RTP_AVP_UDP_Multicast = 2

||| Recover TransportProtocol from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-2.
public export
tagToTransportProtocol : Bits8 -> Maybe TransportProtocol
tagToTransportProtocol 0 = Just RTP_AVP_UDP
tagToTransportProtocol 1 = Just RTP_AVP_TCP
tagToTransportProtocol 2 = Just RTP_AVP_UDP_Multicast
tagToTransportProtocol _ = Nothing

||| Proof: encoding then decoding TransportProtocol is the identity.
public export
transportProtocolRoundtrip : (t : TransportProtocol) -> tagToTransportProtocol (transportProtocolToTag t) = Just t
transportProtocolRoundtrip RTP_AVP_UDP           = Refl
transportProtocolRoundtrip RTP_AVP_TCP           = Refl
transportProtocolRoundtrip RTP_AVP_UDP_Multicast = Refl

---------------------------------------------------------------------------
-- SessionState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for SessionState (1 byte).
public export
sessionStateSize : Nat
sessionStateSize = 1

||| Map SessionState to its C-ABI byte value.
|||
||| Tag assignments:
|||   Init      = 0
|||   Ready     = 1
|||   Playing   = 2
|||   Recording = 3
public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag Init      = 0
sessionStateToTag Ready     = 1
sessionStateToTag Playing   = 2
sessionStateToTag Recording = 3

||| Recover SessionState from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Init
tagToSessionState 1 = Just Ready
tagToSessionState 2 = Just Playing
tagToSessionState 3 = Just Recording
tagToSessionState _ = Nothing

||| Proof: encoding then decoding SessionState is the identity.
public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip Init      = Refl
sessionStateRoundtrip Ready     = Refl
sessionStateRoundtrip Playing   = Refl
sessionStateRoundtrip Recording = Refl

---------------------------------------------------------------------------
-- StatusCode (12 constructors, tags 0-11)
---------------------------------------------------------------------------

||| C-ABI representation size for StatusCode (1 byte).
public export
statusCodeSize : Nat
statusCodeSize = 1

||| Map StatusCode to its C-ABI byte value.
|||
||| Tag assignments:
|||   OK                  = 0     MovedPermanently  = 1
|||   MovedTemporarily    = 2     BadRequest        = 3
|||   Unauthorized        = 4     NotFound          = 5
|||   MethodNotAllowed    = 6     NotAcceptable     = 7
|||   SessionNotFound     = 8     InternalServerError = 9
|||   NotImplemented      = 10    ServiceUnavailable  = 11
public export
statusCodeToTag : StatusCode -> Bits8
statusCodeToTag OK                  = 0
statusCodeToTag MovedPermanently    = 1
statusCodeToTag MovedTemporarily    = 2
statusCodeToTag BadRequest          = 3
statusCodeToTag Unauthorized        = 4
statusCodeToTag NotFound            = 5
statusCodeToTag MethodNotAllowed    = 6
statusCodeToTag NotAcceptable       = 7
statusCodeToTag SessionNotFound     = 8
statusCodeToTag InternalServerError = 9
statusCodeToTag NotImplemented      = 10
statusCodeToTag ServiceUnavailable  = 11

||| Recover StatusCode from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-11.
public export
tagToStatusCode : Bits8 -> Maybe StatusCode
tagToStatusCode 0  = Just OK
tagToStatusCode 1  = Just MovedPermanently
tagToStatusCode 2  = Just MovedTemporarily
tagToStatusCode 3  = Just BadRequest
tagToStatusCode 4  = Just Unauthorized
tagToStatusCode 5  = Just NotFound
tagToStatusCode 6  = Just MethodNotAllowed
tagToStatusCode 7  = Just NotAcceptable
tagToStatusCode 8  = Just SessionNotFound
tagToStatusCode 9  = Just InternalServerError
tagToStatusCode 10 = Just NotImplemented
tagToStatusCode 11 = Just ServiceUnavailable
tagToStatusCode _  = Nothing

||| Proof: encoding then decoding StatusCode is the identity.
public export
statusCodeRoundtrip : (s : StatusCode) -> tagToStatusCode (statusCodeToTag s) = Just s
statusCodeRoundtrip OK                  = Refl
statusCodeRoundtrip MovedPermanently    = Refl
statusCodeRoundtrip MovedTemporarily    = Refl
statusCodeRoundtrip BadRequest          = Refl
statusCodeRoundtrip Unauthorized        = Refl
statusCodeRoundtrip NotFound            = Refl
statusCodeRoundtrip MethodNotAllowed    = Refl
statusCodeRoundtrip NotAcceptable       = Refl
statusCodeRoundtrip SessionNotFound     = Refl
statusCodeRoundtrip InternalServerError = Refl
statusCodeRoundtrip NotImplemented      = Refl
statusCodeRoundtrip ServiceUnavailable  = Refl

---------------------------------------------------------------------------
-- RTSPError (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| Error codes for RTSP FFI operations.
public export
data RTSPError : Type where
  ||| No error.
  RtspOk                : RTSPError
  ||| Invalid slot index.
  RtspInvalidSlot       : RTSPError
  ||| Session not active.
  RtspNotActive         : RTSPError
  ||| Invalid session state transition.
  RtspInvalidTransition : RTSPError
  ||| Method not allowed in current state.
  RtspMethodNotAllowed  : RTSPError
  ||| Transport setup failed.
  RtspTransportError    : RTSPError
  ||| Session expired.
  RtspSessionExpired    : RTSPError

public export
Show RTSPError where
  show RtspOk                = "Ok"
  show RtspInvalidSlot       = "InvalidSlot"
  show RtspNotActive         = "NotActive"
  show RtspInvalidTransition = "InvalidTransition"
  show RtspMethodNotAllowed  = "MethodNotAllowed"
  show RtspTransportError    = "TransportError"
  show RtspSessionExpired    = "SessionExpired"

||| C-ABI representation size for RTSPError (1 byte).
public export
rtspErrorSize : Nat
rtspErrorSize = 1

||| Map RTSPError to its C-ABI byte value.
public export
rtspErrorToTag : RTSPError -> Bits8
rtspErrorToTag RtspOk                = 0
rtspErrorToTag RtspInvalidSlot       = 1
rtspErrorToTag RtspNotActive         = 2
rtspErrorToTag RtspInvalidTransition = 3
rtspErrorToTag RtspMethodNotAllowed  = 4
rtspErrorToTag RtspTransportError    = 5
rtspErrorToTag RtspSessionExpired    = 6

||| Recover RTSPError from its C-ABI byte value.
public export
tagToRTSPError : Bits8 -> Maybe RTSPError
tagToRTSPError 0 = Just RtspOk
tagToRTSPError 1 = Just RtspInvalidSlot
tagToRTSPError 2 = Just RtspNotActive
tagToRTSPError 3 = Just RtspInvalidTransition
tagToRTSPError 4 = Just RtspMethodNotAllowed
tagToRTSPError 5 = Just RtspTransportError
tagToRTSPError 6 = Just RtspSessionExpired
tagToRTSPError _ = Nothing

||| Proof: encoding then decoding RTSPError is the identity.
public export
rtspErrorRoundtrip : (e : RTSPError) -> tagToRTSPError (rtspErrorToTag e) = Just e
rtspErrorRoundtrip RtspOk                = Refl
rtspErrorRoundtrip RtspInvalidSlot       = Refl
rtspErrorRoundtrip RtspNotActive         = Refl
rtspErrorRoundtrip RtspInvalidTransition = Refl
rtspErrorRoundtrip RtspMethodNotAllowed  = Refl
rtspErrorRoundtrip RtspTransportError    = Refl
rtspErrorRoundtrip RtspSessionExpired    = Refl
