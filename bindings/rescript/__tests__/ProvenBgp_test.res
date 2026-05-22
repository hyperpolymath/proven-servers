// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenBgp protocol bindings.

open ProvenBgp

let test_bgpState_roundtrip = () => {
  assert(bgpStateFromTag(0) == Some(Idle))
  assert(bgpStateFromTag(1) == Some(Connect))
  assert(bgpStateFromTag(2) == Some(Active))
  assert(bgpStateFromTag(3) == Some(OpenSent))
  assert(bgpStateFromTag(4) == Some(OpenConfirm))
  assert(bgpStateFromTag(5) == Some(Established))
  assert(bgpStateFromTag(6) == None)
}

let test_bgpState_toTag = () => {
  assert(bgpStateToTag(Idle) == 0)
  assert(bgpStateToTag(Connect) == 1)
  assert(bgpStateToTag(Active) == 2)
  assert(bgpStateToTag(OpenSent) == 3)
  assert(bgpStateToTag(OpenConfirm) == 4)
  assert(bgpStateToTag(Established) == 5)
}

let test_bgpEvent_roundtrip = () => {
  assert(bgpEventFromTag(0) == Some(ManualStart))
  assert(bgpEventFromTag(1) == Some(ManualStop))
  assert(bgpEventFromTag(2) == Some(AutomaticStart))
  assert(bgpEventFromTag(3) == Some(ConnectRetryTimerExpires))
  assert(bgpEventFromTag(4) == Some(HoldTimerExpires))
  assert(bgpEventFromTag(5) == Some(KeepaliveTimerExpires))
  assert(bgpEventFromTag(6) == Some(DelayOpenTimerExpires))
  assert(bgpEventFromTag(7) == Some(TcpConnectionValid))
  assert(bgpEventFromTag(8) == Some(TcpCrAcked))
  assert(bgpEventFromTag(9) == Some(TcpConnectionConfirmed))
  assert(bgpEventFromTag(10) == Some(TcpConnectionFails))
  assert(bgpEventFromTag(11) == Some(BgpOpenReceived))
  assert(bgpEventFromTag(12) == Some(BgpHeaderErr))
  assert(bgpEventFromTag(13) == Some(BgpOpenMsgErr))
  assert(bgpEventFromTag(14) == Some(NotifMsgVerErr))
  assert(bgpEventFromTag(15) == Some(NotifMsg))
  assert(bgpEventFromTag(16) == Some(KeepaliveMsg))
  assert(bgpEventFromTag(17) == Some(UpdateMsg))
  assert(bgpEventFromTag(18) == Some(UpdateMsgErr))
  assert(bgpEventFromTag(19) == None)
}

let test_bgpEvent_toTag = () => {
  assert(bgpEventToTag(ManualStart) == 0)
  assert(bgpEventToTag(ManualStop) == 1)
  assert(bgpEventToTag(AutomaticStart) == 2)
  assert(bgpEventToTag(ConnectRetryTimerExpires) == 3)
  assert(bgpEventToTag(HoldTimerExpires) == 4)
  assert(bgpEventToTag(KeepaliveTimerExpires) == 5)
  assert(bgpEventToTag(DelayOpenTimerExpires) == 6)
  assert(bgpEventToTag(TcpConnectionValid) == 7)
  assert(bgpEventToTag(TcpCrAcked) == 8)
  assert(bgpEventToTag(TcpConnectionConfirmed) == 9)
  assert(bgpEventToTag(TcpConnectionFails) == 10)
  assert(bgpEventToTag(BgpOpenReceived) == 11)
  assert(bgpEventToTag(BgpHeaderErr) == 12)
  assert(bgpEventToTag(BgpOpenMsgErr) == 13)
  assert(bgpEventToTag(NotifMsgVerErr) == 14)
  assert(bgpEventToTag(NotifMsg) == 15)
  assert(bgpEventToTag(KeepaliveMsg) == 16)
  assert(bgpEventToTag(UpdateMsg) == 17)
  assert(bgpEventToTag(UpdateMsgErr) == 18)
}

let test_messageType_roundtrip = () => {
  assert(messageTypeFromTag(0) == Some(Open))
  assert(messageTypeFromTag(1) == Some(Update))
  assert(messageTypeFromTag(2) == Some(Notification))
  assert(messageTypeFromTag(3) == Some(Keepalive))
  assert(messageTypeFromTag(4) == None)
}

let test_messageType_toTag = () => {
  assert(messageTypeToTag(Open) == 0)
  assert(messageTypeToTag(Update) == 1)
  assert(messageTypeToTag(Notification) == 2)
  assert(messageTypeToTag(Keepalive) == 3)
}

let test_errorCode_roundtrip = () => {
  assert(errorCodeFromTag(0) == Some(MessageHeaderError))
  assert(errorCodeFromTag(1) == Some(OpenMessageError))
  assert(errorCodeFromTag(2) == Some(UpdateMessageError))
  assert(errorCodeFromTag(3) == Some(HoldTimerExpired))
  assert(errorCodeFromTag(4) == Some(FsmError))
  assert(errorCodeFromTag(5) == Some(Cease))
  assert(errorCodeFromTag(6) == None)
}

let test_errorCode_toTag = () => {
  assert(errorCodeToTag(MessageHeaderError) == 0)
  assert(errorCodeToTag(OpenMessageError) == 1)
  assert(errorCodeToTag(UpdateMessageError) == 2)
  assert(errorCodeToTag(HoldTimerExpired) == 3)
  assert(errorCodeToTag(FsmError) == 4)
  assert(errorCodeToTag(Cease) == 5)
}

let test_origin_roundtrip = () => {
  assert(originFromTag(0) == Some(Igp))
  assert(originFromTag(1) == Some(Egp))
  assert(originFromTag(2) == Some(Incomplete))
  assert(originFromTag(3) == None)
}

let test_origin_toTag = () => {
  assert(originToTag(Igp) == 0)
  assert(originToTag(Egp) == 1)
  assert(originToTag(Incomplete) == 2)
}

let test_asPathSegmentType_roundtrip = () => {
  assert(asPathSegmentTypeFromTag(0) == Some(AsSet))
  assert(asPathSegmentTypeFromTag(1) == Some(AsSequence))
  assert(asPathSegmentTypeFromTag(2) == None)
}

let test_asPathSegmentType_toTag = () => {
  assert(asPathSegmentTypeToTag(AsSet) == 0)
  assert(asPathSegmentTypeToTag(AsSequence) == 1)
}

let test_pathAttrType_roundtrip = () => {
  assert(pathAttrTypeFromTag(0) == Some(Origin))
  assert(pathAttrTypeFromTag(1) == Some(AsPath))
  assert(pathAttrTypeFromTag(2) == Some(NextHop))
  assert(pathAttrTypeFromTag(3) == Some(Med))
  assert(pathAttrTypeFromTag(4) == Some(LocalPref))
  assert(pathAttrTypeFromTag(5) == Some(AtomicAggr))
  assert(pathAttrTypeFromTag(6) == Some(Aggregator))
  assert(pathAttrTypeFromTag(7) == Some(Unknown))
  assert(pathAttrTypeFromTag(8) == None)
}

let test_pathAttrType_toTag = () => {
  assert(pathAttrTypeToTag(Origin) == 0)
  assert(pathAttrTypeToTag(AsPath) == 1)
  assert(pathAttrTypeToTag(NextHop) == 2)
  assert(pathAttrTypeToTag(Med) == 3)
  assert(pathAttrTypeToTag(LocalPref) == 4)
  assert(pathAttrTypeToTag(AtomicAggr) == 5)
  assert(pathAttrTypeToTag(Aggregator) == 6)
  assert(pathAttrTypeToTag(Unknown) == 7)
}

// Run all tests
test_bgpState_roundtrip()
test_bgpState_toTag()
test_bgpEvent_roundtrip()
test_bgpEvent_toTag()
test_messageType_roundtrip()
test_messageType_toTag()
test_errorCode_roundtrip()
test_errorCode_toTag()
test_origin_roundtrip()
test_origin_toTag()
test_asPathSegmentType_roundtrip()
test_asPathSegmentType_toTag()
test_pathAttrType_roundtrip()
test_pathAttrType_toTag()
