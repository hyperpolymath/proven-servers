# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-irc protocol types.

"""IRC protocol types for proven-servers."""

from enum import IntEnum


class Command(IntEnum):
    """Command matching the Idris2 ABI tags."""
    NICK = 0
    USER = 1
    JOIN = 2
    PART = 3
    PRIVMSG = 4
    NOTICE = 5
    QUIT = 6
    PING = 7
    PONG = 8
    MODE = 9
    KICK = 10
    TOPIC = 11
    INVITE = 12
    NAMES = 13
    LIST = 14
    WHO = 15
    WHOIS = 16


class NumericReply(IntEnum):
    """NumericReply matching the Idris2 ABI tags."""
    WELCOME = 0
    YOUR_HOST = 1
    CREATED = 2
    MY_INFO = 3
    BOUNCE = 4
    NUMERIC_REPLY_NICK_IN_USE = 5
    NO_SUCH_NICK = 6
    NO_SUCH_CHANNEL = 7
    CHANNEL_IS_FULL = 8
    INVITE_ONLY_CHAN = 9
    BANNED_FROM_CHAN = 10


class ChannelMode(IntEnum):
    """ChannelMode matching the Idris2 ABI tags."""
    OP = 0
    VOICE = 1
    BAN = 2
    LIMIT = 3
    CHANNEL_MODE_INVITE_ONLY = 4
    MODERATED = 5
    NO_EXTERNAL_MSGS = 6
    TOPIC_LOCK = 7
    SECRET = 8
    PRIVATE = 9


class State(IntEnum):
    """State matching the Idris2 ABI tags."""
    DISCONNECTED = 0
    CONNECTING = 1
    REGISTERED = 2
    IN_CHANNEL = 3
    QUITTING = 4


class IrcError(IntEnum):
    """IrcError matching the Idris2 ABI tags."""
    NONE = 0
    IRC_ERROR_NICK_IN_USE = 1
    CHANNEL_FULL = 2
    IRC_ERROR_INVITE_ONLY = 3
    BANNED = 4
    NOT_REGISTERED = 5
