-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DoHABI.Types: C-ABI-compatible numeric representations of DoH types.
--
-- Maps every constructor of the core DoH sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/doh.h) and the
-- Zig FFI enums (ffi/zig/src/doh.zig) exactly.
--
-- Types covered:
--   ContentType   (2 constructors, tags 0-1)
--   RequestMethod (2 constructors, tags 0-1)
--   WireFormat    (2 constructors, tags 0-1)
--   ErrorReason   (5 constructors, tags 0-4)
--   SessionState  (5 constructors, tags 0-4)

module DoHABI.Types

import DoH.Types

%default total

---------------------------------------------------------------------------
-- ContentType (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
contentTypeToTag : ContentType -> Bits8
contentTypeToTag DNSMessage = 0
contentTypeToTag DNSJson    = 1

public export
tagToContentType : Bits8 -> Maybe ContentType
tagToContentType 0 = Just DNSMessage
tagToContentType 1 = Just DNSJson
tagToContentType _ = Nothing

public export
contentTypeRoundtrip : (c : ContentType) -> tagToContentType (contentTypeToTag c) = Just c
contentTypeRoundtrip DNSMessage = Refl
contentTypeRoundtrip DNSJson    = Refl

---------------------------------------------------------------------------
-- RequestMethod (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
requestMethodToTag : RequestMethod -> Bits8
requestMethodToTag Get  = 0
requestMethodToTag Post = 1

public export
tagToRequestMethod : Bits8 -> Maybe RequestMethod
tagToRequestMethod 0 = Just Get
tagToRequestMethod 1 = Just Post
tagToRequestMethod _ = Nothing

public export
requestMethodRoundtrip : (r : RequestMethod) -> tagToRequestMethod (requestMethodToTag r) = Just r
requestMethodRoundtrip Get  = Refl
requestMethodRoundtrip Post = Refl

---------------------------------------------------------------------------
-- WireFormat (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
wireFormatToTag : WireFormat -> Bits8
wireFormatToTag Binary = 0
wireFormatToTag Json   = 1

public export
tagToWireFormat : Bits8 -> Maybe WireFormat
tagToWireFormat 0 = Just Binary
tagToWireFormat 1 = Just Json
tagToWireFormat _ = Nothing

public export
wireFormatRoundtrip : (w : WireFormat) -> tagToWireFormat (wireFormatToTag w) = Just w
wireFormatRoundtrip Binary = Refl
wireFormatRoundtrip Json   = Refl

---------------------------------------------------------------------------
-- ErrorReason (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
errorReasonToTag : ErrorReason -> Bits8
errorReasonToTag BadContentType  = 0
errorReasonToTag BadMethod       = 1
errorReasonToTag PayloadTooLarge = 2
errorReasonToTag UpstreamTimeout = 3
errorReasonToTag UpstreamError   = 4

public export
tagToErrorReason : Bits8 -> Maybe ErrorReason
tagToErrorReason 0 = Just BadContentType
tagToErrorReason 1 = Just BadMethod
tagToErrorReason 2 = Just PayloadTooLarge
tagToErrorReason 3 = Just UpstreamTimeout
tagToErrorReason 4 = Just UpstreamError
tagToErrorReason _ = Nothing

public export
errorReasonRoundtrip : (e : ErrorReason) -> tagToErrorReason (errorReasonToTag e) = Just e
errorReasonRoundtrip BadContentType  = Refl
errorReasonRoundtrip BadMethod       = Refl
errorReasonRoundtrip PayloadTooLarge = Refl
errorReasonRoundtrip UpstreamTimeout = Refl
errorReasonRoundtrip UpstreamError   = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
-- DoH proxy server lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| DoH proxy server lifecycle states.
public export
data SessionState : Type where
  ||| No proxy active. Initial and terminal state.
  SSIdle      : SessionState
  ||| Proxy bound to listening address.
  SSBound     : SessionState
  ||| Actively serving DoH requests.
  SSServing   : SessionState
  ||| Processing upstream DNS resolution.
  SSResolving : SessionState
  ||| Shutting down, draining connections.
  SSShutdown  : SessionState

public export
Eq SessionState where
  SSIdle      == SSIdle      = True
  SSBound     == SSBound     = True
  SSServing   == SSServing   = True
  SSResolving == SSResolving = True
  SSShutdown  == SSShutdown  = True
  _           == _           = False

public export
Show SessionState where
  show SSIdle      = "Idle"
  show SSBound     = "Bound"
  show SSServing   = "Serving"
  show SSResolving = "Resolving"
  show SSShutdown  = "Shutdown"

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag SSIdle      = 0
sessionStateToTag SSBound     = 1
sessionStateToTag SSServing   = 2
sessionStateToTag SSResolving = 3
sessionStateToTag SSShutdown  = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just SSIdle
tagToSessionState 1 = Just SSBound
tagToSessionState 2 = Just SSServing
tagToSessionState 3 = Just SSResolving
tagToSessionState 4 = Just SSShutdown
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip SSIdle      = Refl
sessionStateRoundtrip SSBound     = Refl
sessionStateRoundtrip SSServing   = Refl
sessionStateRoundtrip SSResolving = Refl
sessionStateRoundtrip SSShutdown  = Refl
