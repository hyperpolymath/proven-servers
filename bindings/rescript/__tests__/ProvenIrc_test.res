// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenIrc protocol bindings.

open ProvenIrc

let test_command_roundtrip = () => {
  assert(commandFromTag(0) == Some(Nick))
  assert(commandFromTag(1) == Some(User))
  assert(commandFromTag(2) == Some(Join))
  assert(commandFromTag(3) == Some(Part))
  assert(commandFromTag(4) == Some(Privmsg))
  assert(commandFromTag(5) == Some(Notice))
  assert(commandFromTag(6) == Some(Quit))
  assert(commandFromTag(7) == Some(Ping))
  assert(commandFromTag(8) == Some(Pong))
  assert(commandFromTag(9) == Some(Mode))
  assert(commandFromTag(10) == Some(Kick))
  assert(commandFromTag(11) == Some(Topic))
  assert(commandFromTag(12) == Some(Invite))
  assert(commandFromTag(13) == Some(Names))
  assert(commandFromTag(14) == Some(List))
  assert(commandFromTag(15) == Some(Who))
  assert(commandFromTag(16) == Some(Whois))
  assert(commandFromTag(17) == None)
}

let test_command_toTag = () => {
  assert(commandToTag(Nick) == 0)
  assert(commandToTag(User) == 1)
  assert(commandToTag(Join) == 2)
  assert(commandToTag(Part) == 3)
  assert(commandToTag(Privmsg) == 4)
  assert(commandToTag(Notice) == 5)
  assert(commandToTag(Quit) == 6)
  assert(commandToTag(Ping) == 7)
  assert(commandToTag(Pong) == 8)
  assert(commandToTag(Mode) == 9)
  assert(commandToTag(Kick) == 10)
  assert(commandToTag(Topic) == 11)
  assert(commandToTag(Invite) == 12)
  assert(commandToTag(Names) == 13)
  assert(commandToTag(List) == 14)
  assert(commandToTag(Who) == 15)
  assert(commandToTag(Whois) == 16)
}

let test_numericReply_roundtrip = () => {
  assert(numericReplyFromTag(0) == Some(Welcome))
  assert(numericReplyFromTag(1) == Some(YourHost))
  assert(numericReplyFromTag(2) == Some(Created))
  assert(numericReplyFromTag(3) == Some(MyInfo))
  assert(numericReplyFromTag(4) == Some(Bounce))
  assert(numericReplyFromTag(5) == Some(NickInUse))
  assert(numericReplyFromTag(6) == Some(NoSuchNick))
  assert(numericReplyFromTag(7) == Some(NoSuchChannel))
  assert(numericReplyFromTag(8) == Some(ChannelIsFull))
  assert(numericReplyFromTag(9) == Some(InviteOnlyChan))
  assert(numericReplyFromTag(10) == Some(BannedFromChan))
  assert(numericReplyFromTag(11) == None)
}

let test_numericReply_toTag = () => {
  assert(numericReplyToTag(Welcome) == 0)
  assert(numericReplyToTag(YourHost) == 1)
  assert(numericReplyToTag(Created) == 2)
  assert(numericReplyToTag(MyInfo) == 3)
  assert(numericReplyToTag(Bounce) == 4)
  assert(numericReplyToTag(NickInUse) == 5)
  assert(numericReplyToTag(NoSuchNick) == 6)
  assert(numericReplyToTag(NoSuchChannel) == 7)
  assert(numericReplyToTag(ChannelIsFull) == 8)
  assert(numericReplyToTag(InviteOnlyChan) == 9)
  assert(numericReplyToTag(BannedFromChan) == 10)
}

let test_channelMode_roundtrip = () => {
  assert(channelModeFromTag(0) == Some(Op))
  assert(channelModeFromTag(1) == Some(Voice))
  assert(channelModeFromTag(2) == Some(Ban))
  assert(channelModeFromTag(3) == Some(Limit))
  assert(channelModeFromTag(4) == Some(InviteOnly))
  assert(channelModeFromTag(5) == Some(Moderated))
  assert(channelModeFromTag(6) == Some(NoExternalMsgs))
  assert(channelModeFromTag(7) == Some(TopicLock))
  assert(channelModeFromTag(8) == Some(Secret))
  assert(channelModeFromTag(9) == Some(Private))
  assert(channelModeFromTag(10) == None)
}

let test_channelMode_toTag = () => {
  assert(channelModeToTag(Op) == 0)
  assert(channelModeToTag(Voice) == 1)
  assert(channelModeToTag(Ban) == 2)
  assert(channelModeToTag(Limit) == 3)
  assert(channelModeToTag(InviteOnly) == 4)
  assert(channelModeToTag(Moderated) == 5)
  assert(channelModeToTag(NoExternalMsgs) == 6)
  assert(channelModeToTag(TopicLock) == 7)
  assert(channelModeToTag(Secret) == 8)
  assert(channelModeToTag(Private) == 9)
}

let test_state_roundtrip = () => {
  assert(stateFromTag(0) == Some(Disconnected))
  assert(stateFromTag(1) == Some(Connecting))
  assert(stateFromTag(2) == Some(Registered))
  assert(stateFromTag(3) == Some(InChannel))
  assert(stateFromTag(4) == Some(Quitting))
  assert(stateFromTag(5) == None)
}

let test_state_toTag = () => {
  assert(stateToTag(Disconnected) == 0)
  assert(stateToTag(Connecting) == 1)
  assert(stateToTag(Registered) == 2)
  assert(stateToTag(InChannel) == 3)
  assert(stateToTag(Quitting) == 4)
}

let test_ircError_roundtrip = () => {
  assert(ircErrorFromTag(0) == Some(None))
  assert(ircErrorFromTag(1) == Some(NickInUse))
  assert(ircErrorFromTag(2) == Some(ChannelFull))
  assert(ircErrorFromTag(3) == Some(InviteOnly))
  assert(ircErrorFromTag(4) == Some(Banned))
  assert(ircErrorFromTag(5) == Some(NotRegistered))
  assert(ircErrorFromTag(6) == None)
}

let test_ircError_toTag = () => {
  assert(ircErrorToTag(None) == 0)
  assert(ircErrorToTag(NickInUse) == 1)
  assert(ircErrorToTag(ChannelFull) == 2)
  assert(ircErrorToTag(InviteOnly) == 3)
  assert(ircErrorToTag(Banned) == 4)
  assert(ircErrorToTag(NotRegistered) == 5)
}

// Run all tests
test_command_roundtrip()
test_command_toTag()
test_numericReply_roundtrip()
test_numericReply_toTag()
test_channelMode_roundtrip()
test_channelMode_toTag()
test_state_roundtrip()
test_state_toTag()
test_ircError_roundtrip()
test_ircError_toTag()
