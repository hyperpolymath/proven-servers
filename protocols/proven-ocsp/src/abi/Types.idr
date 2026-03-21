-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- OCSPABI.Types: C-ABI-compatible numeric representations of OCSP types.
--
-- Maps every constructor of the OCSP sum types (from OCSP.Types) to
-- fixed Bits8 values for C interop. Each type gets a total encoder,
-- partial decoder, and roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/ocsp.zig)
-- exactly.
--
-- Types covered:
--   CertStatus      (3 constructors, tags 0-2)
--   ResponseStatus  (6 constructors, tags 0-5)
--   HashAlgorithm   (4 constructors, tags 0-3)
--   ResponderState  (5 constructors, tags 0-4)

module OCSPABI.Types

import OCSP.Types

%default total

---------------------------------------------------------------------------
-- CertStatus (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
certStatusSize : Nat
certStatusSize = 1

public export
certStatusToTag : CertStatus -> Bits8
certStatusToTag Good    = 0
certStatusToTag Revoked = 1
certStatusToTag Unknown = 2

public export
tagToCertStatus : Bits8 -> Maybe CertStatus
tagToCertStatus 0 = Just Good
tagToCertStatus 1 = Just Revoked
tagToCertStatus 2 = Just Unknown
tagToCertStatus _ = Nothing

public export
certStatusRoundtrip : (c : CertStatus) -> tagToCertStatus (certStatusToTag c) = Just c
certStatusRoundtrip Good    = Refl
certStatusRoundtrip Revoked = Refl
certStatusRoundtrip Unknown = Refl

---------------------------------------------------------------------------
-- ResponseStatus (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
responseStatusSize : Nat
responseStatusSize = 1

public export
responseStatusToTag : ResponseStatus -> Bits8
responseStatusToTag Successful       = 0
responseStatusToTag MalformedRequest = 1
responseStatusToTag InternalError    = 2
responseStatusToTag TryLater         = 3
responseStatusToTag SigRequired      = 4
responseStatusToTag Unauthorized     = 5

public export
tagToResponseStatus : Bits8 -> Maybe ResponseStatus
tagToResponseStatus 0 = Just Successful
tagToResponseStatus 1 = Just MalformedRequest
tagToResponseStatus 2 = Just InternalError
tagToResponseStatus 3 = Just TryLater
tagToResponseStatus 4 = Just SigRequired
tagToResponseStatus 5 = Just Unauthorized
tagToResponseStatus _ = Nothing

public export
responseStatusRoundtrip : (r : ResponseStatus) -> tagToResponseStatus (responseStatusToTag r) = Just r
responseStatusRoundtrip Successful       = Refl
responseStatusRoundtrip MalformedRequest = Refl
responseStatusRoundtrip InternalError    = Refl
responseStatusRoundtrip TryLater         = Refl
responseStatusRoundtrip SigRequired      = Refl
responseStatusRoundtrip Unauthorized     = Refl

---------------------------------------------------------------------------
-- HashAlgorithm (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
hashAlgorithmSize : Nat
hashAlgorithmSize = 1

public export
hashAlgorithmToTag : HashAlgorithm -> Bits8
hashAlgorithmToTag SHA1   = 0
hashAlgorithmToTag SHA256 = 1
hashAlgorithmToTag SHA384 = 2
hashAlgorithmToTag SHA512 = 3

public export
tagToHashAlgorithm : Bits8 -> Maybe HashAlgorithm
tagToHashAlgorithm 0 = Just SHA1
tagToHashAlgorithm 1 = Just SHA256
tagToHashAlgorithm 2 = Just SHA384
tagToHashAlgorithm 3 = Just SHA512
tagToHashAlgorithm _ = Nothing

public export
hashAlgorithmRoundtrip : (h : HashAlgorithm) -> tagToHashAlgorithm (hashAlgorithmToTag h) = Just h
hashAlgorithmRoundtrip SHA1   = Refl
hashAlgorithmRoundtrip SHA256 = Refl
hashAlgorithmRoundtrip SHA384 = Refl
hashAlgorithmRoundtrip SHA512 = Refl

---------------------------------------------------------------------------
-- ResponderState (5 constructors, tags 0-4)
-- Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| OCSP responder lifecycle states for the FFI layer.
public export
data ResponderState : Type where
  ||| No responder active. Initial and terminal state.
  RSIdle       : ResponderState
  ||| Responder initialized, CA certificate loaded.
  RSReady      : ResponderState
  ||| Processing an OCSP request.
  RSProcessing : ResponderState
  ||| Signing an OCSP response.
  RSSigning    : ResponderState
  ||| Responder shutting down.
  RSClosing    : ResponderState

public export
Eq ResponderState where
  RSIdle       == RSIdle       = True
  RSReady      == RSReady      = True
  RSProcessing == RSProcessing = True
  RSSigning    == RSSigning    = True
  RSClosing    == RSClosing    = True
  _            == _            = False

public export
Show ResponderState where
  show RSIdle       = "Idle"
  show RSReady      = "Ready"
  show RSProcessing = "Processing"
  show RSSigning    = "Signing"
  show RSClosing    = "Closing"

public export
responderStateSize : Nat
responderStateSize = 1

public export
responderStateToTag : ResponderState -> Bits8
responderStateToTag RSIdle       = 0
responderStateToTag RSReady      = 1
responderStateToTag RSProcessing = 2
responderStateToTag RSSigning    = 3
responderStateToTag RSClosing    = 4

public export
tagToResponderState : Bits8 -> Maybe ResponderState
tagToResponderState 0 = Just RSIdle
tagToResponderState 1 = Just RSReady
tagToResponderState 2 = Just RSProcessing
tagToResponderState 3 = Just RSSigning
tagToResponderState 4 = Just RSClosing
tagToResponderState _ = Nothing

public export
responderStateRoundtrip : (s : ResponderState) -> tagToResponderState (responderStateToTag s) = Just s
responderStateRoundtrip RSIdle       = Refl
responderStateRoundtrip RSReady      = Refl
responderStateRoundtrip RSProcessing = Refl
responderStateRoundtrip RSSigning    = Refl
responderStateRoundtrip RSClosing    = Refl
