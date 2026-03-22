// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IRC protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * IRC protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenIrc {
    private ProvenIrc() {}

    /** Command (tags 0-16). */
    public enum Command {
        NICK(0),
        USER(1),
        JOIN(2),
        PART(3),
        PRIVMSG(4),
        NOTICE(5),
        QUIT(6),
        PING(7),
        PONG(8),
        MODE(9),
        KICK(10),
        TOPIC(11),
        INVITE(12),
        NAMES(13),
        LIST(14),
        WHO(15),
        WHOIS(16);

        private final int tag;
        Command(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Command fromTag(int tag) {
            for (Command v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NumericReply (tags 0-10). */
    public enum NumericReply {
        WELCOME(0),
        YOUR_HOST(1),
        CREATED(2),
        MY_INFO(3),
        BOUNCE(4),
        NICK_IN_USE(5),
        NO_SUCH_NICK(6),
        NO_SUCH_CHANNEL(7),
        CHANNEL_IS_FULL(8),
        INVITE_ONLY_CHAN(9),
        BANNED_FROM_CHAN(10);

        private final int tag;
        NumericReply(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NumericReply fromTag(int tag) {
            for (NumericReply v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ChannelMode (tags 0-9). */
    public enum ChannelMode {
        OP(0),
        VOICE(1),
        BAN(2),
        LIMIT(3),
        INVITE_ONLY(4),
        MODERATED(5),
        NO_EXTERNAL_MSGS(6),
        TOPIC_LOCK(7),
        SECRET(8),
        PRIVATE(9);

        private final int tag;
        ChannelMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ChannelMode fromTag(int tag) {
            for (ChannelMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** State (tags 0-4). */
    public enum State {
        DISCONNECTED(0),
        CONNECTING(1),
        REGISTERED(2),
        IN_CHANNEL(3),
        QUITTING(4);

        private final int tag;
        State(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static State fromTag(int tag) {
            for (State v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** IrcError (tags 0-5). */
    public enum IrcError {
        NONE(0),
        NICK_IN_USE(1),
        CHANNEL_FULL(2),
        INVITE_ONLY(3),
        BANNED(4),
        NOT_REGISTERED(5);

        private final int tag;
        IrcError(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static IrcError fromTag(int tag) {
            for (IrcError v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
