-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- BgpABI.Types: C-ABI-compatible numeric representations of Bgp types.
--
-- Maps every constructor of the core Bgp sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/bgp.zig) exactly.
--
-- Types covered:
--   BGPState                  (6 constructors, tags 0-5)
--   BGPEvent                  (19 constructors, tags 0-18)
--   MessageType               (4 constructors, tags 0-3)
--   ErrorCode                 (6 constructors, tags 0-5)
--   Origin                    (3 constructors, tags 0-2)
--   ASPathSegmentType         (2 constructors, tags 0-1)
--   PathAttrType              (8 constructors, tags 0-7)

module BgpABI.Types

%default total

---------------------------------------------------------------------------
-- BGPState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
b_g_p_stateSize : Nat
b_g_p_stateSize = 1

||| BGPState sum type for ABI encoding.
public export
data BGPState : Type where
  Idle : BGPState
  Connect : BGPState
  Active : BGPState
  OpenSent : BGPState
  OpenConfirm : BGPState
  Established : BGPState

||| Encode a BGPState to its ABI tag value.
public export
b_g_p_stateToTag : BGPState -> Bits8
b_g_p_stateToTag Idle = 0
b_g_p_stateToTag Connect = 1
b_g_p_stateToTag Active = 2
b_g_p_stateToTag OpenSent = 3
b_g_p_stateToTag OpenConfirm = 4
b_g_p_stateToTag Established = 5

||| Decode an ABI tag to a BGPState.
public export
tagToBGPState : Bits8 -> Maybe BGPState
tagToBGPState 0 = Just Idle
tagToBGPState 1 = Just Connect
tagToBGPState 2 = Just Active
tagToBGPState 3 = Just OpenSent
tagToBGPState 4 = Just OpenConfirm
tagToBGPState 5 = Just Established
tagToBGPState _ = Nothing

||| Roundtrip proof: decoding an encoded BGPState yields the original.
public export
b_g_p_stateRoundtrip : (x : BGPState) -> tagToBGPState (b_g_p_stateToTag x) = Just x
b_g_p_stateRoundtrip Idle = Refl
b_g_p_stateRoundtrip Connect = Refl
b_g_p_stateRoundtrip Active = Refl
b_g_p_stateRoundtrip OpenSent = Refl
b_g_p_stateRoundtrip OpenConfirm = Refl
b_g_p_stateRoundtrip Established = Refl

---------------------------------------------------------------------------
-- BGPEvent (19 constructors, tags 0-18)
---------------------------------------------------------------------------

public export
b_g_p_eventSize : Nat
b_g_p_eventSize = 1

||| BGPEvent sum type for ABI encoding.
public export
data BGPEvent : Type where
  ManualStart : BGPEvent
  ManualStop : BGPEvent
  AutomaticStart : BGPEvent
  ConnectRetryTimerExpires : BGPEvent
  HoldTimerExpires : BGPEvent
  KeepaliveTimerExpires : BGPEvent
  DelayOpenTimerExpires : BGPEvent
  TcpConnectionValid : BGPEvent
  TcpCrAcked : BGPEvent
  TcpConnectionConfirmed : BGPEvent
  TcpConnectionFails : BGPEvent
  BgpOpenReceived : BGPEvent
  BgpHeaderErr : BGPEvent
  BgpOpenMsgErr : BGPEvent
  NotifMsgVerErr : BGPEvent
  NotifMsg : BGPEvent
  KeepaliveMsg : BGPEvent
  UpdateMsg : BGPEvent
  UpdateMsgErr : BGPEvent

||| Encode a BGPEvent to its ABI tag value.
public export
b_g_p_eventToTag : BGPEvent -> Bits8
b_g_p_eventToTag ManualStart = 0
b_g_p_eventToTag ManualStop = 1
b_g_p_eventToTag AutomaticStart = 2
b_g_p_eventToTag ConnectRetryTimerExpires = 3
b_g_p_eventToTag HoldTimerExpires = 4
b_g_p_eventToTag KeepaliveTimerExpires = 5
b_g_p_eventToTag DelayOpenTimerExpires = 6
b_g_p_eventToTag TcpConnectionValid = 7
b_g_p_eventToTag TcpCrAcked = 8
b_g_p_eventToTag TcpConnectionConfirmed = 9
b_g_p_eventToTag TcpConnectionFails = 10
b_g_p_eventToTag BgpOpenReceived = 11
b_g_p_eventToTag BgpHeaderErr = 12
b_g_p_eventToTag BgpOpenMsgErr = 13
b_g_p_eventToTag NotifMsgVerErr = 14
b_g_p_eventToTag NotifMsg = 15
b_g_p_eventToTag KeepaliveMsg = 16
b_g_p_eventToTag UpdateMsg = 17
b_g_p_eventToTag UpdateMsgErr = 18

||| Decode an ABI tag to a BGPEvent.
public export
tagToBGPEvent : Bits8 -> Maybe BGPEvent
tagToBGPEvent 0 = Just ManualStart
tagToBGPEvent 1 = Just ManualStop
tagToBGPEvent 2 = Just AutomaticStart
tagToBGPEvent 3 = Just ConnectRetryTimerExpires
tagToBGPEvent 4 = Just HoldTimerExpires
tagToBGPEvent 5 = Just KeepaliveTimerExpires
tagToBGPEvent 6 = Just DelayOpenTimerExpires
tagToBGPEvent 7 = Just TcpConnectionValid
tagToBGPEvent 8 = Just TcpCrAcked
tagToBGPEvent 9 = Just TcpConnectionConfirmed
tagToBGPEvent 10 = Just TcpConnectionFails
tagToBGPEvent 11 = Just BgpOpenReceived
tagToBGPEvent 12 = Just BgpHeaderErr
tagToBGPEvent 13 = Just BgpOpenMsgErr
tagToBGPEvent 14 = Just NotifMsgVerErr
tagToBGPEvent 15 = Just NotifMsg
tagToBGPEvent 16 = Just KeepaliveMsg
tagToBGPEvent 17 = Just UpdateMsg
tagToBGPEvent 18 = Just UpdateMsgErr
tagToBGPEvent _ = Nothing

||| Roundtrip proof: decoding an encoded BGPEvent yields the original.
public export
b_g_p_eventRoundtrip : (x : BGPEvent) -> tagToBGPEvent (b_g_p_eventToTag x) = Just x
b_g_p_eventRoundtrip ManualStart = Refl
b_g_p_eventRoundtrip ManualStop = Refl
b_g_p_eventRoundtrip AutomaticStart = Refl
b_g_p_eventRoundtrip ConnectRetryTimerExpires = Refl
b_g_p_eventRoundtrip HoldTimerExpires = Refl
b_g_p_eventRoundtrip KeepaliveTimerExpires = Refl
b_g_p_eventRoundtrip DelayOpenTimerExpires = Refl
b_g_p_eventRoundtrip TcpConnectionValid = Refl
b_g_p_eventRoundtrip TcpCrAcked = Refl
b_g_p_eventRoundtrip TcpConnectionConfirmed = Refl
b_g_p_eventRoundtrip TcpConnectionFails = Refl
b_g_p_eventRoundtrip BgpOpenReceived = Refl
b_g_p_eventRoundtrip BgpHeaderErr = Refl
b_g_p_eventRoundtrip BgpOpenMsgErr = Refl
b_g_p_eventRoundtrip NotifMsgVerErr = Refl
b_g_p_eventRoundtrip NotifMsg = Refl
b_g_p_eventRoundtrip KeepaliveMsg = Refl
b_g_p_eventRoundtrip UpdateMsg = Refl
b_g_p_eventRoundtrip UpdateMsgErr = Refl

---------------------------------------------------------------------------
-- MessageType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
message_typeSize : Nat
message_typeSize = 1

||| MessageType sum type for ABI encoding.
public export
data MessageType : Type where
  Open : MessageType
  Update : MessageType
  Notification : MessageType
  Keepalive : MessageType

||| Encode a MessageType to its ABI tag value.
public export
message_typeToTag : MessageType -> Bits8
message_typeToTag Open = 0
message_typeToTag Update = 1
message_typeToTag Notification = 2
message_typeToTag Keepalive = 3

||| Decode an ABI tag to a MessageType.
public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0 = Just Open
tagToMessageType 1 = Just Update
tagToMessageType 2 = Just Notification
tagToMessageType 3 = Just Keepalive
tagToMessageType _ = Nothing

||| Roundtrip proof: decoding an encoded MessageType yields the original.
public export
message_typeRoundtrip : (x : MessageType) -> tagToMessageType (message_typeToTag x) = Just x
message_typeRoundtrip Open = Refl
message_typeRoundtrip Update = Refl
message_typeRoundtrip Notification = Refl
message_typeRoundtrip Keepalive = Refl

---------------------------------------------------------------------------
-- ErrorCode (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
error_codeSize : Nat
error_codeSize = 1

||| ErrorCode sum type for ABI encoding.
public export
data ErrorCode : Type where
  MessageHeaderError : ErrorCode
  OpenMessageError : ErrorCode
  UpdateMessageError : ErrorCode
  HoldTimerExpired : ErrorCode
  FsmError : ErrorCode
  Cease : ErrorCode

||| Encode a ErrorCode to its ABI tag value.
public export
error_codeToTag : ErrorCode -> Bits8
error_codeToTag MessageHeaderError = 0
error_codeToTag OpenMessageError = 1
error_codeToTag UpdateMessageError = 2
error_codeToTag HoldTimerExpired = 3
error_codeToTag FsmError = 4
error_codeToTag Cease = 5

||| Decode an ABI tag to a ErrorCode.
public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just MessageHeaderError
tagToErrorCode 1 = Just OpenMessageError
tagToErrorCode 2 = Just UpdateMessageError
tagToErrorCode 3 = Just HoldTimerExpired
tagToErrorCode 4 = Just FsmError
tagToErrorCode 5 = Just Cease
tagToErrorCode _ = Nothing

||| Roundtrip proof: decoding an encoded ErrorCode yields the original.
public export
error_codeRoundtrip : (x : ErrorCode) -> tagToErrorCode (error_codeToTag x) = Just x
error_codeRoundtrip MessageHeaderError = Refl
error_codeRoundtrip OpenMessageError = Refl
error_codeRoundtrip UpdateMessageError = Refl
error_codeRoundtrip HoldTimerExpired = Refl
error_codeRoundtrip FsmError = Refl
error_codeRoundtrip Cease = Refl

---------------------------------------------------------------------------
-- Origin (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
originSize : Nat
originSize = 1

||| Origin sum type for ABI encoding.
public export
data Origin : Type where
  Igp : Origin
  Egp : Origin
  Incomplete : Origin

||| Encode a Origin to its ABI tag value.
public export
originToTag : Origin -> Bits8
originToTag Igp = 0
originToTag Egp = 1
originToTag Incomplete = 2

||| Decode an ABI tag to a Origin.
public export
tagToOrigin : Bits8 -> Maybe Origin
tagToOrigin 0 = Just Igp
tagToOrigin 1 = Just Egp
tagToOrigin 2 = Just Incomplete
tagToOrigin _ = Nothing

||| Roundtrip proof: decoding an encoded Origin yields the original.
public export
originRoundtrip : (x : Origin) -> tagToOrigin (originToTag x) = Just x
originRoundtrip Igp = Refl
originRoundtrip Egp = Refl
originRoundtrip Incomplete = Refl

---------------------------------------------------------------------------
-- ASPathSegmentType (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
a_s_path_segment_typeSize : Nat
a_s_path_segment_typeSize = 1

||| ASPathSegmentType sum type for ABI encoding.
public export
data ASPathSegmentType : Type where
  AsSet : ASPathSegmentType
  AsSequence : ASPathSegmentType

||| Encode a ASPathSegmentType to its ABI tag value.
public export
a_s_path_segment_typeToTag : ASPathSegmentType -> Bits8
a_s_path_segment_typeToTag AsSet = 0
a_s_path_segment_typeToTag AsSequence = 1

||| Decode an ABI tag to a ASPathSegmentType.
public export
tagToASPathSegmentType : Bits8 -> Maybe ASPathSegmentType
tagToASPathSegmentType 0 = Just AsSet
tagToASPathSegmentType 1 = Just AsSequence
tagToASPathSegmentType _ = Nothing

||| Roundtrip proof: decoding an encoded ASPathSegmentType yields the original.
public export
a_s_path_segment_typeRoundtrip : (x : ASPathSegmentType) -> tagToASPathSegmentType (a_s_path_segment_typeToTag x) = Just x
a_s_path_segment_typeRoundtrip AsSet = Refl
a_s_path_segment_typeRoundtrip AsSequence = Refl

---------------------------------------------------------------------------
-- PathAttrType (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
path_attr_typeSize : Nat
path_attr_typeSize = 1

||| PathAttrType sum type for ABI encoding.
public export
data PathAttrType : Type where
  Origin : PathAttrType
  AsPath : PathAttrType
  NextHop : PathAttrType
  Med : PathAttrType
  LocalPref : PathAttrType
  AtomicAggr : PathAttrType
  Aggregator : PathAttrType
  Unknown : PathAttrType

||| Encode a PathAttrType to its ABI tag value.
public export
path_attr_typeToTag : PathAttrType -> Bits8
path_attr_typeToTag Origin = 0
path_attr_typeToTag AsPath = 1
path_attr_typeToTag NextHop = 2
path_attr_typeToTag Med = 3
path_attr_typeToTag LocalPref = 4
path_attr_typeToTag AtomicAggr = 5
path_attr_typeToTag Aggregator = 6
path_attr_typeToTag Unknown = 7

||| Decode an ABI tag to a PathAttrType.
public export
tagToPathAttrType : Bits8 -> Maybe PathAttrType
tagToPathAttrType 0 = Just Origin
tagToPathAttrType 1 = Just AsPath
tagToPathAttrType 2 = Just NextHop
tagToPathAttrType 3 = Just Med
tagToPathAttrType 4 = Just LocalPref
tagToPathAttrType 5 = Just AtomicAggr
tagToPathAttrType 6 = Just Aggregator
tagToPathAttrType 7 = Just Unknown
tagToPathAttrType _ = Nothing

||| Roundtrip proof: decoding an encoded PathAttrType yields the original.
public export
path_attr_typeRoundtrip : (x : PathAttrType) -> tagToPathAttrType (path_attr_typeToTag x) = Just x
path_attr_typeRoundtrip Origin = Refl
path_attr_typeRoundtrip AsPath = Refl
path_attr_typeRoundtrip NextHop = Refl
path_attr_typeRoundtrip Med = Refl
path_attr_typeRoundtrip LocalPref = Refl
path_attr_typeRoundtrip AtomicAggr = Refl
path_attr_typeRoundtrip Aggregator = Refl
path_attr_typeRoundtrip Unknown = Refl
