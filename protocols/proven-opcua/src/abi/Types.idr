-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- OPCUAABI.Types: C-ABI-compatible numeric representations of OPC UA types.
--
-- Maps every constructor of the OPCUA sum types (from OPCUA.Types) to
-- fixed Bits8 values for C interop. Each type gets a total encoder,
-- partial decoder, and roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/opcua.zig)
-- exactly.
--
-- Types covered:
--   ServiceType    (11 constructors, tags 0-10)
--   NodeClass      (8 constructors, tags 0-7)
--   StatusCode     (12 constructors, tags 0-11)
--   SecurityMode   (3 constructors, tags 0-2)
--   SessionState   (6 constructors, tags 0-5)

module OPCUAABI.Types

import OPCUA.Types

%default total

---------------------------------------------------------------------------
-- ServiceType (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
serviceTypeSize : Nat
serviceTypeSize = 1

public export
serviceTypeToTag : ServiceType -> Bits8
serviceTypeToTag Read               = 0
serviceTypeToTag Write              = 1
serviceTypeToTag Browse             = 2
serviceTypeToTag Subscribe          = 3
serviceTypeToTag Publish            = 4
serviceTypeToTag Call               = 5
serviceTypeToTag CreateSession      = 6
serviceTypeToTag ActivateSession    = 7
serviceTypeToTag CloseSession       = 8
serviceTypeToTag CreateSubscription = 9
serviceTypeToTag DeleteSubscription = 10

public export
tagToServiceType : Bits8 -> Maybe ServiceType
tagToServiceType 0  = Just Read
tagToServiceType 1  = Just Write
tagToServiceType 2  = Just Browse
tagToServiceType 3  = Just Subscribe
tagToServiceType 4  = Just Publish
tagToServiceType 5  = Just Call
tagToServiceType 6  = Just CreateSession
tagToServiceType 7  = Just ActivateSession
tagToServiceType 8  = Just CloseSession
tagToServiceType 9  = Just CreateSubscription
tagToServiceType 10 = Just DeleteSubscription
tagToServiceType _  = Nothing

public export
serviceTypeRoundtrip : (s : ServiceType) -> tagToServiceType (serviceTypeToTag s) = Just s
serviceTypeRoundtrip Read               = Refl
serviceTypeRoundtrip Write              = Refl
serviceTypeRoundtrip Browse             = Refl
serviceTypeRoundtrip Subscribe          = Refl
serviceTypeRoundtrip Publish            = Refl
serviceTypeRoundtrip Call               = Refl
serviceTypeRoundtrip CreateSession      = Refl
serviceTypeRoundtrip ActivateSession    = Refl
serviceTypeRoundtrip CloseSession       = Refl
serviceTypeRoundtrip CreateSubscription = Refl
serviceTypeRoundtrip DeleteSubscription = Refl

---------------------------------------------------------------------------
-- NodeClass (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
nodeClassSize : Nat
nodeClassSize = 1

public export
nodeClassToTag : NodeClass -> Bits8
nodeClassToTag Object        = 0
nodeClassToTag Variable      = 1
nodeClassToTag Method        = 2
nodeClassToTag ObjectType    = 3
nodeClassToTag VariableType  = 4
nodeClassToTag ReferenceType = 5
nodeClassToTag DataType      = 6
nodeClassToTag View          = 7

public export
tagToNodeClass : Bits8 -> Maybe NodeClass
tagToNodeClass 0 = Just Object
tagToNodeClass 1 = Just Variable
tagToNodeClass 2 = Just Method
tagToNodeClass 3 = Just ObjectType
tagToNodeClass 4 = Just VariableType
tagToNodeClass 5 = Just ReferenceType
tagToNodeClass 6 = Just DataType
tagToNodeClass 7 = Just View
tagToNodeClass _ = Nothing

public export
nodeClassRoundtrip : (n : NodeClass) -> tagToNodeClass (nodeClassToTag n) = Just n
nodeClassRoundtrip Object        = Refl
nodeClassRoundtrip Variable      = Refl
nodeClassRoundtrip Method        = Refl
nodeClassRoundtrip ObjectType    = Refl
nodeClassRoundtrip VariableType  = Refl
nodeClassRoundtrip ReferenceType = Refl
nodeClassRoundtrip DataType      = Refl
nodeClassRoundtrip View          = Refl

---------------------------------------------------------------------------
-- StatusCode (12 constructors, tags 0-11)
---------------------------------------------------------------------------

public export
statusCodeSize : Nat
statusCodeSize = 1

public export
statusCodeToTag : StatusCode -> Bits8
statusCodeToTag Good                       = 0
statusCodeToTag Uncertain                  = 1
statusCodeToTag Bad                        = 2
statusCodeToTag BadNodeIdUnknown           = 3
statusCodeToTag BadAttributeIdInvalid      = 4
statusCodeToTag BadNotReadable             = 5
statusCodeToTag BadNotWritable             = 6
statusCodeToTag BadOutOfRange              = 7
statusCodeToTag BadTypeMismatch            = 8
statusCodeToTag BadSessionIdInvalid        = 9
statusCodeToTag BadSubscriptionIdInvalid   = 10
statusCodeToTag BadTimeout                 = 11

public export
tagToStatusCode : Bits8 -> Maybe StatusCode
tagToStatusCode 0  = Just Good
tagToStatusCode 1  = Just Uncertain
tagToStatusCode 2  = Just Bad
tagToStatusCode 3  = Just BadNodeIdUnknown
tagToStatusCode 4  = Just BadAttributeIdInvalid
tagToStatusCode 5  = Just BadNotReadable
tagToStatusCode 6  = Just BadNotWritable
tagToStatusCode 7  = Just BadOutOfRange
tagToStatusCode 8  = Just BadTypeMismatch
tagToStatusCode 9  = Just BadSessionIdInvalid
tagToStatusCode 10 = Just BadSubscriptionIdInvalid
tagToStatusCode 11 = Just BadTimeout
tagToStatusCode _  = Nothing

public export
statusCodeRoundtrip : (s : StatusCode) -> tagToStatusCode (statusCodeToTag s) = Just s
statusCodeRoundtrip Good                       = Refl
statusCodeRoundtrip Uncertain                  = Refl
statusCodeRoundtrip Bad                        = Refl
statusCodeRoundtrip BadNodeIdUnknown           = Refl
statusCodeRoundtrip BadAttributeIdInvalid      = Refl
statusCodeRoundtrip BadNotReadable             = Refl
statusCodeRoundtrip BadNotWritable             = Refl
statusCodeRoundtrip BadOutOfRange              = Refl
statusCodeRoundtrip BadTypeMismatch            = Refl
statusCodeRoundtrip BadSessionIdInvalid        = Refl
statusCodeRoundtrip BadSubscriptionIdInvalid   = Refl
statusCodeRoundtrip BadTimeout                 = Refl

---------------------------------------------------------------------------
-- SecurityMode (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
securityModeSize : Nat
securityModeSize = 1

public export
securityModeToTag : SecurityMode -> Bits8
securityModeToTag None          = 0
securityModeToTag Sign          = 1
securityModeToTag SignAndEncrypt = 2

public export
tagToSecurityMode : Bits8 -> Maybe SecurityMode
tagToSecurityMode 0 = Just None
tagToSecurityMode 1 = Just Sign
tagToSecurityMode 2 = Just SignAndEncrypt
tagToSecurityMode _ = Nothing

public export
securityModeRoundtrip : (m : SecurityMode) -> tagToSecurityMode (securityModeToTag m) = Just m
securityModeRoundtrip None          = Refl
securityModeRoundtrip Sign          = Refl
securityModeRoundtrip SignAndEncrypt = Refl

---------------------------------------------------------------------------
-- SessionState (6 constructors, tags 0-5)
-- Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| OPC UA session lifecycle states for the FFI layer.
public export
data SessionState : Type where
  ||| No session. Initial and terminal state.
  SSIdle        : SessionState
  ||| Secure channel established.
  SSConnected   : SessionState
  ||| Session created, awaiting activation.
  SSCreated     : SessionState
  ||| Session activated, ready for service requests.
  SSActivated   : SessionState
  ||| Subscription active, monitoring nodes.
  SSMonitoring  : SessionState
  ||| Session closing.
  SSClosing     : SessionState

public export
Eq SessionState where
  SSIdle       == SSIdle       = True
  SSConnected  == SSConnected  = True
  SSCreated    == SSCreated    = True
  SSActivated  == SSActivated  = True
  SSMonitoring == SSMonitoring = True
  SSClosing    == SSClosing    = True
  _            == _            = False

public export
Show SessionState where
  show SSIdle       = "Idle"
  show SSConnected  = "Connected"
  show SSCreated    = "Created"
  show SSActivated  = "Activated"
  show SSMonitoring = "Monitoring"
  show SSClosing    = "Closing"

public export
sessionStateSize : Nat
sessionStateSize = 1

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag SSIdle       = 0
sessionStateToTag SSConnected  = 1
sessionStateToTag SSCreated    = 2
sessionStateToTag SSActivated  = 3
sessionStateToTag SSMonitoring = 4
sessionStateToTag SSClosing    = 5

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just SSIdle
tagToSessionState 1 = Just SSConnected
tagToSessionState 2 = Just SSCreated
tagToSessionState 3 = Just SSActivated
tagToSessionState 4 = Just SSMonitoring
tagToSessionState 5 = Just SSClosing
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip SSIdle       = Refl
sessionStateRoundtrip SSConnected  = Refl
sessionStateRoundtrip SSCreated    = Refl
sessionStateRoundtrip SSActivated  = Refl
sessionStateRoundtrip SSMonitoring = Refl
sessionStateRoundtrip SSClosing    = Refl
