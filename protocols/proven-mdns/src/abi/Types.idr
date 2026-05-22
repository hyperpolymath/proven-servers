-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- abi.Types: C-ABI-compatible numeric representations of mDNS types.
--
-- Maps every constructor of the core mDNS sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/mdns.zig)
-- exactly.
--
-- Types covered:
--   RecordType     (5 constructors, tags 0-4)
--   QueryType      (3 constructors, tags 0-2)
--   ConflictAction (3 constructors, tags 0-2)
--   ServiceFlag    (2 constructors, tags 0-1)
--   ResponderState (5 constructors, tags 0-4)

module abi.Types

import MDNS.Types

%default total

---------------------------------------------------------------------------
-- RecordType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
recordTypeToTag : RecordType -> Bits8
recordTypeToTag A    = 0
recordTypeToTag AAAA = 1
recordTypeToTag PTR  = 2
recordTypeToTag SRV  = 3
recordTypeToTag TXT  = 4

public export
tagToRecordType : Bits8 -> Maybe RecordType
tagToRecordType 0 = Just A
tagToRecordType 1 = Just AAAA
tagToRecordType 2 = Just PTR
tagToRecordType 3 = Just SRV
tagToRecordType 4 = Just TXT
tagToRecordType _ = Nothing

public export
recordTypeRoundtrip : (r : RecordType) -> tagToRecordType (recordTypeToTag r) = Just r
recordTypeRoundtrip A    = Refl
recordTypeRoundtrip AAAA = Refl
recordTypeRoundtrip PTR  = Refl
recordTypeRoundtrip SRV  = Refl
recordTypeRoundtrip TXT  = Refl

---------------------------------------------------------------------------
-- QueryType (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
queryTypeToTag : QueryType -> Bits8
queryTypeToTag Standard   = 0
queryTypeToTag OneShot    = 1
queryTypeToTag Continuous = 2

public export
tagToQueryType : Bits8 -> Maybe QueryType
tagToQueryType 0 = Just Standard
tagToQueryType 1 = Just OneShot
tagToQueryType 2 = Just Continuous
tagToQueryType _ = Nothing

public export
queryTypeRoundtrip : (q : QueryType) -> tagToQueryType (queryTypeToTag q) = Just q
queryTypeRoundtrip Standard   = Refl
queryTypeRoundtrip OneShot    = Refl
queryTypeRoundtrip Continuous = Refl

---------------------------------------------------------------------------
-- ConflictAction (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
conflictActionToTag : ConflictAction -> Bits8
conflictActionToTag Probe    = 0
conflictActionToTag Defend   = 1
conflictActionToTag Withdraw = 2

public export
tagToConflictAction : Bits8 -> Maybe ConflictAction
tagToConflictAction 0 = Just Probe
tagToConflictAction 1 = Just Defend
tagToConflictAction 2 = Just Withdraw
tagToConflictAction _ = Nothing

public export
conflictActionRoundtrip : (c : ConflictAction) -> tagToConflictAction (conflictActionToTag c) = Just c
conflictActionRoundtrip Probe    = Refl
conflictActionRoundtrip Defend   = Refl
conflictActionRoundtrip Withdraw = Refl

---------------------------------------------------------------------------
-- ServiceFlag (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
serviceFlagToTag : ServiceFlag -> Bits8
serviceFlagToTag Unique = 0
serviceFlagToTag Shared = 1

public export
tagToServiceFlag : Bits8 -> Maybe ServiceFlag
tagToServiceFlag 0 = Just Unique
tagToServiceFlag 1 = Just Shared
tagToServiceFlag _ = Nothing

public export
serviceFlagRoundtrip : (f : ServiceFlag) -> tagToServiceFlag (serviceFlagToTag f) = Just f
serviceFlagRoundtrip Unique = Refl
serviceFlagRoundtrip Shared = Refl

---------------------------------------------------------------------------
-- ResponderState (5 constructors, tags 0-4)
-- Composite lifecycle state used by the FFI for simplified management.
---------------------------------------------------------------------------

||| mDNS responder lifecycle states.
||| Used by the FFI layer for the C ABI.
public export
data ResponderState : Type where
  ||| No responder active. Initial and terminal state.
  RSIdle        : ResponderState
  ||| Responder is probing for name uniqueness (RFC 6762 Section 8).
  RSProbing     : ResponderState
  ||| Responder is announcing its records (RFC 6762 Section 8.3).
  RSAnnouncing  : ResponderState
  ||| Responder is running and answering queries.
  RSRunning     : ResponderState
  ||| Responder is shutting down, sending goodbye packets (TTL=0).
  RSShuttingDown : ResponderState

public export
Eq ResponderState where
  RSIdle        == RSIdle        = True
  RSProbing     == RSProbing     = True
  RSAnnouncing  == RSAnnouncing  = True
  RSRunning     == RSRunning     = True
  RSShuttingDown == RSShuttingDown = True
  _             == _             = False

public export
Show ResponderState where
  show RSIdle        = "Idle"
  show RSProbing     = "Probing"
  show RSAnnouncing  = "Announcing"
  show RSRunning     = "Running"
  show RSShuttingDown = "ShuttingDown"

public export
responderStateToTag : ResponderState -> Bits8
responderStateToTag RSIdle        = 0
responderStateToTag RSProbing     = 1
responderStateToTag RSAnnouncing  = 2
responderStateToTag RSRunning     = 3
responderStateToTag RSShuttingDown = 4

public export
tagToResponderState : Bits8 -> Maybe ResponderState
tagToResponderState 0 = Just RSIdle
tagToResponderState 1 = Just RSProbing
tagToResponderState 2 = Just RSAnnouncing
tagToResponderState 3 = Just RSRunning
tagToResponderState 4 = Just RSShuttingDown
tagToResponderState _ = Nothing

public export
responderStateRoundtrip : (s : ResponderState) -> tagToResponderState (responderStateToTag s) = Just s
responderStateRoundtrip RSIdle        = Refl
responderStateRoundtrip RSProbing     = Refl
responderStateRoundtrip RSAnnouncing  = Refl
responderStateRoundtrip RSRunning     = Refl
responderStateRoundtrip RSShuttingDown = Refl
