// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! IRC protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `IrcABI.Types` and its type definitions:
//! - `Command`      — IRC commands (17 constructors, tags 0-16)
//! - `NumericReply`  — Selected numeric replies (11 constructors, tags 0-10)
//! - `ChannelMode`   — Channel mode flags (10 constructors, tags 0-9)
//! - `State`         — IRC connection lifecycle (5 constructors, tags 0-4)
//! - `IrcError`      — IRC error categories (6 constructors, tags 0-5)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// IRC Constants
// ===========================================================================

/// Standard IRC port (RFC 2812).
pub const IRC_PORT: u16 = 6667;

/// Standard IRC over TLS port.
pub const IRCS_PORT: u16 = 6697;

// ===========================================================================
// Command (tags 0-16)
// ===========================================================================

/// IRC protocol commands (RFC 2812).
///
/// Matches `Command` in `IrcABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Command {
    /// NICK — set or change nickname (tag 0).
    Nick = 0,
    /// USER — specify username and realname (tag 1).
    User = 1,
    /// JOIN — join a channel (tag 2).
    Join = 2,
    /// PART — leave a channel (tag 3).
    Part = 3,
    /// PRIVMSG — send a message to a user or channel (tag 4).
    Privmsg = 4,
    /// NOTICE — send a notice (no auto-reply) (tag 5).
    Notice = 5,
    /// QUIT — disconnect from server (tag 6).
    Quit = 6,
    /// PING — test connection liveness (tag 7).
    Ping = 7,
    /// PONG — reply to PING (tag 8).
    Pong = 8,
    /// MODE — set user or channel modes (tag 9).
    Mode = 9,
    /// KICK — remove a user from a channel (tag 10).
    Kick = 10,
    /// TOPIC — set or view channel topic (tag 11).
    Topic = 11,
    /// INVITE — invite a user to a channel (tag 12).
    Invite = 12,
    /// NAMES — list users in a channel (tag 13).
    Names = 13,
    /// LIST — list channels (tag 14).
    List = 14,
    /// WHO — query user information (tag 15).
    Who = 15,
    /// WHOIS — query detailed user information (tag 16).
    Whois = 16,
}

impl Command {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Nick),
            1 => Some(Self::User),
            2 => Some(Self::Join),
            3 => Some(Self::Part),
            4 => Some(Self::Privmsg),
            5 => Some(Self::Notice),
            6 => Some(Self::Quit),
            7 => Some(Self::Ping),
            8 => Some(Self::Pong),
            9 => Some(Self::Mode),
            10 => Some(Self::Kick),
            11 => Some(Self::Topic),
            12 => Some(Self::Invite),
            13 => Some(Self::Names),
            14 => Some(Self::List),
            15 => Some(Self::Who),
            16 => Some(Self::Whois),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The IRC command name string.
    pub fn name(self) -> &'static str {
        match self {
            Self::Nick => "NICK",
            Self::User => "USER",
            Self::Join => "JOIN",
            Self::Part => "PART",
            Self::Privmsg => "PRIVMSG",
            Self::Notice => "NOTICE",
            Self::Quit => "QUIT",
            Self::Ping => "PING",
            Self::Pong => "PONG",
            Self::Mode => "MODE",
            Self::Kick => "KICK",
            Self::Topic => "TOPIC",
            Self::Invite => "INVITE",
            Self::Names => "NAMES",
            Self::List => "LIST",
            Self::Who => "WHO",
            Self::Whois => "WHOIS",
        }
    }

    /// Whether this command requires channel operator privileges.
    pub fn requires_op(self) -> bool {
        matches!(self, Self::Kick | Self::Mode)
    }

    /// Whether this command requires registered status.
    pub fn requires_registration(self) -> bool {
        !matches!(self, Self::Nick | Self::User | Self::Ping | Self::Pong | Self::Quit)
    }

    /// All supported commands.
    pub const ALL: [Command; 17] = [
        Self::Nick, Self::User, Self::Join, Self::Part, Self::Privmsg,
        Self::Notice, Self::Quit, Self::Ping, Self::Pong, Self::Mode,
        Self::Kick, Self::Topic, Self::Invite, Self::Names, Self::List,
        Self::Who, Self::Whois,
    ];
}

impl fmt::Display for Command {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.name())
    }
}

// ===========================================================================
// NumericReply (tags 0-10)
// ===========================================================================

/// Selected IRC numeric reply codes (RFC 2812).
///
/// Matches `NumericReply` in `IrcABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NumericReply {
    /// RPL_WELCOME (001) — welcome to IRC (tag 0).
    Welcome = 0,
    /// RPL_YOURHOST (002) — your host info (tag 1).
    YourHost = 1,
    /// RPL_CREATED (003) — server creation date (tag 2).
    Created = 2,
    /// RPL_MYINFO (004) — server info (tag 3).
    MyInfo = 3,
    /// RPL_BOUNCE (005) — server redirect or capabilities (tag 4).
    Bounce = 4,
    /// ERR_NICKNAMEINUSE (433) — nick already taken (tag 5).
    NickInUse = 5,
    /// ERR_NOSUCHNICK (401) — no such nick (tag 6).
    NoSuchNick = 6,
    /// ERR_NOSUCHCHANNEL (403) — no such channel (tag 7).
    NoSuchChannel = 7,
    /// ERR_CHANNELISFULL (471) — channel is full (tag 8).
    ChannelIsFull = 8,
    /// ERR_INVITEONLYCHAN (473) — invite-only channel (tag 9).
    InviteOnlyChan = 9,
    /// ERR_BANNEDFROMCHAN (474) — banned from channel (tag 10).
    BannedFromChan = 10,
}

impl NumericReply {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Welcome),
            1 => Some(Self::YourHost),
            2 => Some(Self::Created),
            3 => Some(Self::MyInfo),
            4 => Some(Self::Bounce),
            5 => Some(Self::NickInUse),
            6 => Some(Self::NoSuchNick),
            7 => Some(Self::NoSuchChannel),
            8 => Some(Self::ChannelIsFull),
            9 => Some(Self::InviteOnlyChan),
            10 => Some(Self::BannedFromChan),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this reply indicates an error.
    pub fn is_error(self) -> bool {
        matches!(
            self,
            Self::NickInUse | Self::NoSuchNick | Self::NoSuchChannel
                | Self::ChannelIsFull | Self::InviteOnlyChan | Self::BannedFromChan
        )
    }

    /// All supported numeric replies.
    pub const ALL: [NumericReply; 11] = [
        Self::Welcome, Self::YourHost, Self::Created, Self::MyInfo,
        Self::Bounce, Self::NickInUse, Self::NoSuchNick, Self::NoSuchChannel,
        Self::ChannelIsFull, Self::InviteOnlyChan, Self::BannedFromChan,
    ];
}

impl fmt::Display for NumericReply {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ChannelMode (tags 0-9)
// ===========================================================================

/// IRC channel modes (RFC 2812 Section 4).
///
/// Matches `ChannelMode` in `IrcABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ChannelMode {
    /// +o — channel operator (tag 0).
    Op = 0,
    /// +v — voice (tag 1).
    Voice = 1,
    /// +b — ban mask (tag 2).
    Ban = 2,
    /// +l — user limit (tag 3).
    Limit = 3,
    /// +i — invite only (tag 4).
    InviteOnly = 4,
    /// +m — moderated (tag 5).
    Moderated = 5,
    /// +n — no external messages (tag 6).
    NoExternalMsgs = 6,
    /// +t — topic lock (tag 7).
    TopicLock = 7,
    /// +s — secret channel (tag 8).
    Secret = 8,
    /// +p — private channel (tag 9).
    Private = 9,
}

impl ChannelMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Op),
            1 => Some(Self::Voice),
            2 => Some(Self::Ban),
            3 => Some(Self::Limit),
            4 => Some(Self::InviteOnly),
            5 => Some(Self::Moderated),
            6 => Some(Self::NoExternalMsgs),
            7 => Some(Self::TopicLock),
            8 => Some(Self::Secret),
            9 => Some(Self::Private),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The single-character mode flag.
    pub fn mode_char(self) -> char {
        match self {
            Self::Op => 'o',
            Self::Voice => 'v',
            Self::Ban => 'b',
            Self::Limit => 'l',
            Self::InviteOnly => 'i',
            Self::Moderated => 'm',
            Self::NoExternalMsgs => 'n',
            Self::TopicLock => 't',
            Self::Secret => 's',
            Self::Private => 'p',
        }
    }

    /// Whether this mode requires a parameter when set.
    pub fn requires_parameter(self) -> bool {
        matches!(self, Self::Op | Self::Voice | Self::Ban | Self::Limit)
    }

    /// All supported channel modes.
    pub const ALL: [ChannelMode; 10] = [
        Self::Op, Self::Voice, Self::Ban, Self::Limit, Self::InviteOnly,
        Self::Moderated, Self::NoExternalMsgs, Self::TopicLock,
        Self::Secret, Self::Private,
    ];
}

impl fmt::Display for ChannelMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "+{}", self.mode_char())
    }
}

// ===========================================================================
// State (tags 0-4)
// ===========================================================================

/// IRC client connection lifecycle states.
///
/// Matches `IRCState` in `IrcABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum State {
    /// Not connected (tag 0).
    Disconnected = 0,
    /// TCP connection in progress (tag 1).
    Connecting = 1,
    /// NICK/USER sent and accepted (tag 2).
    Registered = 2,
    /// Joined at least one channel (tag 3).
    InChannel = 3,
    /// QUIT sent, awaiting disconnect (tag 4).
    Quitting = 4,
}

impl State {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Disconnected),
            1 => Some(Self::Connecting),
            2 => Some(Self::Registered),
            3 => Some(Self::InChannel),
            4 => Some(Self::Quitting),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: State) -> bool {
        matches!(
            (self, next),
            (Self::Disconnected, Self::Connecting)
                | (Self::Connecting, Self::Registered)
                | (Self::Registered, Self::InChannel)
                | (Self::InChannel, Self::Registered)  // PART last channel
                | (Self::Registered, Self::Quitting)
                | (Self::InChannel, Self::Quitting)
                | (Self::Quitting, Self::Disconnected)
        )
    }
}

impl fmt::Display for State {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// IrcError (tags 0-5)
// ===========================================================================

/// IRC server error categories.
///
/// Matches `IRCError` in `IrcABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum IrcError {
    /// No error (tag 0).
    None = 0,
    /// Nickname already in use (tag 1).
    NickInUse = 1,
    /// Channel is full (tag 2).
    ChannelFull = 2,
    /// Channel is invite-only (tag 3).
    InviteOnly = 3,
    /// Banned from channel (tag 4).
    Banned = 4,
    /// Not registered (tag 5).
    NotRegistered = 5,
}

impl IrcError {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::None),
            1 => Some(Self::NickInUse),
            2 => Some(Self::ChannelFull),
            3 => Some(Self::InviteOnly),
            4 => Some(Self::Banned),
            5 => Some(Self::NotRegistered),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this error code indicates success.
    pub fn is_success(self) -> bool {
        matches!(self, Self::None)
    }

    /// Whether this error relates to channel access.
    pub fn is_channel_error(self) -> bool {
        matches!(self, Self::ChannelFull | Self::InviteOnly | Self::Banned)
    }

    /// All error codes.
    pub const ALL: [IrcError; 6] = [
        Self::None, Self::NickInUse, Self::ChannelFull,
        Self::InviteOnly, Self::Banned, Self::NotRegistered,
    ];
}

impl fmt::Display for IrcError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for IrcError {}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn command_roundtrip() {
        for cmd in Command::ALL {
            let tag = cmd.to_tag();
            let decoded = Command::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, cmd);
        }
        assert!(Command::from_tag(17).is_none());
    }

    #[test]
    fn numeric_reply_roundtrip() {
        for reply in NumericReply::ALL {
            let tag = reply.to_tag();
            let decoded = NumericReply::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, reply);
        }
        assert!(NumericReply::from_tag(11).is_none());
    }

    #[test]
    fn numeric_reply_error_classification() {
        assert!(!NumericReply::Welcome.is_error());
        assert!(NumericReply::NickInUse.is_error());
        assert!(NumericReply::BannedFromChan.is_error());
    }

    #[test]
    fn channel_mode_roundtrip() {
        for mode in ChannelMode::ALL {
            let tag = mode.to_tag();
            let decoded = ChannelMode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, mode);
        }
        assert!(ChannelMode::from_tag(10).is_none());
    }

    #[test]
    fn channel_mode_chars() {
        assert_eq!(ChannelMode::Op.mode_char(), 'o');
        assert_eq!(ChannelMode::Secret.mode_char(), 's');
        assert!(ChannelMode::Op.requires_parameter());
        assert!(!ChannelMode::Secret.requires_parameter());
    }

    #[test]
    fn state_roundtrip() {
        for tag in 0u8..=4 {
            let state = State::from_tag(tag).expect("valid tag");
            assert_eq!(state.to_tag(), tag);
        }
        assert!(State::from_tag(5).is_none());
    }

    #[test]
    fn state_valid_transitions() {
        assert!(State::Disconnected.can_transition_to(State::Connecting));
        assert!(State::Connecting.can_transition_to(State::Registered));
        assert!(State::Registered.can_transition_to(State::InChannel));
        assert!(State::InChannel.can_transition_to(State::Quitting));
        assert!(State::Quitting.can_transition_to(State::Disconnected));
    }

    #[test]
    fn state_invalid_transitions() {
        assert!(!State::Disconnected.can_transition_to(State::Registered));
        assert!(!State::Disconnected.can_transition_to(State::InChannel));
    }

    #[test]
    fn irc_error_roundtrip() {
        for err in IrcError::ALL {
            let tag = err.to_tag();
            let decoded = IrcError::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, err);
        }
        assert!(IrcError::from_tag(6).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(IRC_PORT, 6667);
        assert_eq!(IRCS_PORT, 6697);
    }
}
