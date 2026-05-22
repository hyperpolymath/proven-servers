// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenChat protocol bindings.

open ProvenChat

let test_messageType_roundtrip = () => {
  assert(messageTypeFromTag(0) == Some(Text))
  assert(messageTypeFromTag(1) == Some(Image))
  assert(messageTypeFromTag(2) == Some(File))
  assert(messageTypeFromTag(3) == Some(System))
  assert(messageTypeFromTag(4) == Some(Reaction))
  assert(messageTypeFromTag(5) == Some(Edit))
  assert(messageTypeFromTag(6) == Some(Delete))
  assert(messageTypeFromTag(7) == Some(Reply))
  assert(messageTypeFromTag(8) == Some(Thread))
  assert(messageTypeFromTag(9) == None)
}

let test_messageType_toTag = () => {
  assert(messageTypeToTag(Text) == 0)
  assert(messageTypeToTag(Image) == 1)
  assert(messageTypeToTag(File) == 2)
  assert(messageTypeToTag(System) == 3)
  assert(messageTypeToTag(Reaction) == 4)
  assert(messageTypeToTag(Edit) == 5)
  assert(messageTypeToTag(Delete) == 6)
  assert(messageTypeToTag(Reply) == 7)
  assert(messageTypeToTag(Thread) == 8)
}

let test_presenceStatus_roundtrip = () => {
  assert(presenceStatusFromTag(0) == Some(Online))
  assert(presenceStatusFromTag(1) == Some(Away))
  assert(presenceStatusFromTag(2) == Some(Dnd))
  assert(presenceStatusFromTag(3) == Some(Invisible))
  assert(presenceStatusFromTag(4) == Some(Offline))
  assert(presenceStatusFromTag(5) == None)
}

let test_presenceStatus_toTag = () => {
  assert(presenceStatusToTag(Online) == 0)
  assert(presenceStatusToTag(Away) == 1)
  assert(presenceStatusToTag(Dnd) == 2)
  assert(presenceStatusToTag(Invisible) == 3)
  assert(presenceStatusToTag(Offline) == 4)
}

let test_roomType_roundtrip = () => {
  assert(roomTypeFromTag(0) == Some(Direct))
  assert(roomTypeFromTag(1) == Some(Group))
  assert(roomTypeFromTag(2) == Some(Channel))
  assert(roomTypeFromTag(3) == Some(Broadcast))
  assert(roomTypeFromTag(4) == None)
}

let test_roomType_toTag = () => {
  assert(roomTypeToTag(Direct) == 0)
  assert(roomTypeToTag(Group) == 1)
  assert(roomTypeToTag(Channel) == 2)
  assert(roomTypeToTag(Broadcast) == 3)
}

let test_permission_roundtrip = () => {
  assert(permissionFromTag(0) == Some(Read))
  assert(permissionFromTag(1) == Some(Write))
  assert(permissionFromTag(2) == Some(Admin))
  assert(permissionFromTag(3) == Some(Invite))
  assert(permissionFromTag(4) == Some(Kick))
  assert(permissionFromTag(5) == Some(Ban))
  assert(permissionFromTag(6) == Some(Pin))
  assert(permissionFromTag(7) == Some(DeleteOthers))
  assert(permissionFromTag(8) == None)
}

let test_permission_toTag = () => {
  assert(permissionToTag(Read) == 0)
  assert(permissionToTag(Write) == 1)
  assert(permissionToTag(Admin) == 2)
  assert(permissionToTag(Invite) == 3)
  assert(permissionToTag(Kick) == 4)
  assert(permissionToTag(Ban) == 5)
  assert(permissionToTag(Pin) == 6)
  assert(permissionToTag(DeleteOthers) == 7)
}

let test_event_roundtrip = () => {
  assert(eventFromTag(0) == Some(MessageSent))
  assert(eventFromTag(1) == Some(MessageDelivered))
  assert(eventFromTag(2) == Some(MessageRead))
  assert(eventFromTag(3) == Some(UserJoined))
  assert(eventFromTag(4) == Some(UserLeft))
  assert(eventFromTag(5) == Some(Typing))
  assert(eventFromTag(6) == Some(RoomCreated))
  assert(eventFromTag(7) == None)
}

let test_event_toTag = () => {
  assert(eventToTag(MessageSent) == 0)
  assert(eventToTag(MessageDelivered) == 1)
  assert(eventToTag(MessageRead) == 2)
  assert(eventToTag(UserJoined) == 3)
  assert(eventToTag(UserLeft) == 4)
  assert(eventToTag(Typing) == 5)
  assert(eventToTag(RoomCreated) == 6)
}

// Run all tests
test_messageType_roundtrip()
test_messageType_toTag()
test_presenceStatus_roundtrip()
test_presenceStatus_toTag()
test_roomType_roundtrip()
test_roomType_toTag()
test_permission_roundtrip()
test_permission_toTag()
test_event_roundtrip()
test_event_toTag()
