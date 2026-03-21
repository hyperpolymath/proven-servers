-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SDNABI.Types: C-ABI-compatible numeric representations of SDN types.
--
-- Maps every constructor of the core SDN sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/sdn.zig) exactly.
--
-- Types covered:
--   MessageType  (12 constructors, tags 0-11)
--   FlowAction   (7 constructors, tags 0-6)
--   MatchField   (11 constructors, tags 0-10)
--   PortState    (3 constructors, tags 0-2)

module SDNABI.Types

import SDN.Types

%default total

---------------------------------------------------------------------------
-- MessageType (12 constructors, tags 0-11)
---------------------------------------------------------------------------

public export
messageTypeSize : Nat
messageTypeSize = 1

||| Encode a MessageType to its ABI tag value.
public export
messageTypeToTag : MessageType -> Bits8
messageTypeToTag Hello           = 0
messageTypeToTag Error           = 1
messageTypeToTag EchoRequest     = 2
messageTypeToTag EchoReply       = 3
messageTypeToTag FeaturesRequest = 4
messageTypeToTag FeaturesReply   = 5
messageTypeToTag FlowMod         = 6
messageTypeToTag PacketIn        = 7
messageTypeToTag PacketOut       = 8
messageTypeToTag PortStatus      = 9
messageTypeToTag BarrierRequest  = 10
messageTypeToTag BarrierReply    = 11

||| Decode an ABI tag value to a MessageType.
public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0  = Just Hello
tagToMessageType 1  = Just Error
tagToMessageType 2  = Just EchoRequest
tagToMessageType 3  = Just EchoReply
tagToMessageType 4  = Just FeaturesRequest
tagToMessageType 5  = Just FeaturesReply
tagToMessageType 6  = Just FlowMod
tagToMessageType 7  = Just PacketIn
tagToMessageType 8  = Just PacketOut
tagToMessageType 9  = Just PortStatus
tagToMessageType 10 = Just BarrierRequest
tagToMessageType 11 = Just BarrierReply
tagToMessageType _  = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
messageTypeRoundtrip : (m : MessageType) -> tagToMessageType (messageTypeToTag m) = Just m
messageTypeRoundtrip Hello           = Refl
messageTypeRoundtrip Error           = Refl
messageTypeRoundtrip EchoRequest     = Refl
messageTypeRoundtrip EchoReply       = Refl
messageTypeRoundtrip FeaturesRequest = Refl
messageTypeRoundtrip FeaturesReply   = Refl
messageTypeRoundtrip FlowMod         = Refl
messageTypeRoundtrip PacketIn        = Refl
messageTypeRoundtrip PacketOut       = Refl
messageTypeRoundtrip PortStatus      = Refl
messageTypeRoundtrip BarrierRequest  = Refl
messageTypeRoundtrip BarrierReply    = Refl

---------------------------------------------------------------------------
-- FlowAction (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
flowActionSize : Nat
flowActionSize = 1

||| Encode a FlowAction to its ABI tag value.
public export
flowActionToTag : FlowAction -> Bits8
flowActionToTag Output   = 0
flowActionToTag SetField = 1
flowActionToTag Drop     = 2
flowActionToTag PushVLAN = 3
flowActionToTag PopVLAN  = 4
flowActionToTag SetQueue = 5
flowActionToTag Group    = 6

||| Decode an ABI tag value to a FlowAction.
public export
tagToFlowAction : Bits8 -> Maybe FlowAction
tagToFlowAction 0 = Just Output
tagToFlowAction 1 = Just SetField
tagToFlowAction 2 = Just Drop
tagToFlowAction 3 = Just PushVLAN
tagToFlowAction 4 = Just PopVLAN
tagToFlowAction 5 = Just SetQueue
tagToFlowAction 6 = Just Group
tagToFlowAction _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
flowActionRoundtrip : (a : FlowAction) -> tagToFlowAction (flowActionToTag a) = Just a
flowActionRoundtrip Output   = Refl
flowActionRoundtrip SetField = Refl
flowActionRoundtrip Drop     = Refl
flowActionRoundtrip PushVLAN = Refl
flowActionRoundtrip PopVLAN  = Refl
flowActionRoundtrip SetQueue = Refl
flowActionRoundtrip Group    = Refl

---------------------------------------------------------------------------
-- MatchField (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
matchFieldSize : Nat
matchFieldSize = 1

||| Encode a MatchField to its ABI tag value.
public export
matchFieldToTag : MatchField -> Bits8
matchFieldToTag InPort  = 0
matchFieldToTag EthDst  = 1
matchFieldToTag EthSrc  = 2
matchFieldToTag EthType = 3
matchFieldToTag VLANID  = 4
matchFieldToTag IPSrc   = 5
matchFieldToTag IPDst   = 6
matchFieldToTag TCPSrc  = 7
matchFieldToTag TCPDst  = 8
matchFieldToTag UDPSrc  = 9
matchFieldToTag UDPDst  = 10

||| Decode an ABI tag value to a MatchField.
public export
tagToMatchField : Bits8 -> Maybe MatchField
tagToMatchField 0  = Just InPort
tagToMatchField 1  = Just EthDst
tagToMatchField 2  = Just EthSrc
tagToMatchField 3  = Just EthType
tagToMatchField 4  = Just VLANID
tagToMatchField 5  = Just IPSrc
tagToMatchField 6  = Just IPDst
tagToMatchField 7  = Just TCPSrc
tagToMatchField 8  = Just TCPDst
tagToMatchField 9  = Just UDPSrc
tagToMatchField 10 = Just UDPDst
tagToMatchField _  = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
matchFieldRoundtrip : (f : MatchField) -> tagToMatchField (matchFieldToTag f) = Just f
matchFieldRoundtrip InPort  = Refl
matchFieldRoundtrip EthDst  = Refl
matchFieldRoundtrip EthSrc  = Refl
matchFieldRoundtrip EthType = Refl
matchFieldRoundtrip VLANID  = Refl
matchFieldRoundtrip IPSrc   = Refl
matchFieldRoundtrip IPDst   = Refl
matchFieldRoundtrip TCPSrc  = Refl
matchFieldRoundtrip TCPDst  = Refl
matchFieldRoundtrip UDPSrc  = Refl
matchFieldRoundtrip UDPDst  = Refl

---------------------------------------------------------------------------
-- PortState (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
portStateSize : Nat
portStateSize = 1

||| Encode a PortState to its ABI tag value.
public export
portStateToTag : PortState -> Bits8
portStateToTag Up      = 0
portStateToTag Down    = 1
portStateToTag Blocked = 2

||| Decode an ABI tag value to a PortState.
public export
tagToPortState : Bits8 -> Maybe PortState
tagToPortState 0 = Just Up
tagToPortState 1 = Just Down
tagToPortState 2 = Just Blocked
tagToPortState _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
portStateRoundtrip : (s : PortState) -> tagToPortState (portStateToTag s) = Just s
portStateRoundtrip Up      = Refl
portStateRoundtrip Down    = Refl
portStateRoundtrip Blocked = Refl
