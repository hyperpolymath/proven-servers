// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// IRC protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Command represents the Command type (Idris2 ABI tags).
type Command uint8

const (
	CommandNick Command = iota
	CommandUser
	CommandJoin
	CommandPart
	CommandPrivmsg
	CommandNotice
	CommandQuit
	CommandPing
	CommandPong
	CommandMode
	CommandKick
	CommandTopic
	CommandInvite
	CommandNames
	CommandList
	CommandWho
	CommandWhois
)

// NumericReply represents the NumericReply type (Idris2 ABI tags).
type NumericReply uint8

const (
	NumericReplyWelcome NumericReply = iota
	NumericReplyYourHost
	NumericReplyCreated
	NumericReplyMyInfo
	NumericReplyBounce
	NumericReplyNickInUse
	NumericReplyNoSuchNick
	NumericReplyNoSuchChannel
	NumericReplyChannelIsFull
	NumericReplyInviteOnlyChan
	NumericReplyBannedFromChan
)

// ChannelMode represents the ChannelMode type (Idris2 ABI tags).
type ChannelMode uint8

const (
	ChannelModeOp ChannelMode = iota
	ChannelModeVoice
	ChannelModeBan
	ChannelModeLimit
	ChannelModeInviteOnly
	ChannelModeModerated
	ChannelModeNoExternalMsgs
	ChannelModeTopicLock
	ChannelModeSecret
	ChannelModePrivate
)

// State represents the State type (Idris2 ABI tags).
type State uint8

const (
	StateDisconnected State = iota
	StateConnecting
	StateRegistered
	StateInChannel
	StateQuitting
)

// IrcError represents the IrcError type (Idris2 ABI tags).
type IrcError uint8

const (
	IrcErrorNone IrcError = iota
	IrcErrorNickInUse
	IrcErrorChannelFull
	IrcErrorInviteOnly
	IrcErrorBanned
	IrcErrorNotRegistered
)
