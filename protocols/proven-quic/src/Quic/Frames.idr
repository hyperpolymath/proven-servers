-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| Which frames may appear in which packets (RFC 9000 Section 12.4).
|||
||| `frameAllowedIn` encodes the spec's frame-vs-packet table.  Retry and
||| Version Negotiation packets carry no frames at all.  A handful of the
||| table's cells are then pinned as `Refl` proofs so a regression in the
||| table breaks the build.
module Quic.Frames

import Quic.Types

%default total

||| True iff `f` is permitted in a packet of type `p` (RFC 9000 Section 12.4).
||| Initial (I), Handshake (H), and 1-RTT (1) carry the handshake/ack frames;
||| 0-RTT and 1-RTT carry the application/stream frames.
public export
frameAllowedIn : FrameKind -> PacketType -> Bool
-- Retry and Version Negotiation packets contain no frames.
frameAllowedIn _ PRetry              = False
frameAllowedIn _ PVersionNegotiation = False
-- PADDING and PING may appear in any frame-carrying packet.
frameAllowedIn Padding _ = True
frameAllowedIn Ping    _ = True
-- ACK: Initial, Handshake, 1-RTT (not 0-RTT).
frameAllowedIn Ack PInitial   = True
frameAllowedIn Ack PHandshake = True
frameAllowedIn Ack POneRtt    = True
frameAllowedIn Ack PZeroRtt   = False
-- CRYPTO: Initial, Handshake, 1-RTT (not 0-RTT).
frameAllowedIn Crypto PInitial   = True
frameAllowedIn Crypto PHandshake = True
frameAllowedIn Crypto POneRtt    = True
frameAllowedIn Crypto PZeroRtt   = False
-- CONNECTION_CLOSE (transport form 0x1c): any frame-carrying packet.
frameAllowedIn ConnectionClose PInitial   = True
frameAllowedIn ConnectionClose PHandshake = True
frameAllowedIn ConnectionClose PZeroRtt   = True
frameAllowedIn ConnectionClose POneRtt    = True
-- NEW_TOKEN, PATH_RESPONSE, HANDSHAKE_DONE: 1-RTT only.
frameAllowedIn NewToken      POneRtt = True
frameAllowedIn NewToken      _       = False
frameAllowedIn PathResponse  POneRtt = True
frameAllowedIn PathResponse  _       = False
frameAllowedIn HandshakeDone POneRtt = True
frameAllowedIn HandshakeDone _       = False
-- Everything else (stream/flow-control/connection-id/path-challenge frames):
-- 0-RTT and 1-RTT only.
frameAllowedIn _ PZeroRtt = True
frameAllowedIn _ POneRtt  = True
frameAllowedIn _ _        = False

---------------------------------------------------------------------------
-- Pinned facts from the table
---------------------------------------------------------------------------

||| STREAM frames never appear in Initial packets.
public export
streamNotInInitial : frameAllowedIn StreamFrame PInitial = False
streamNotInInitial = Refl

||| STREAM frames are permitted in 1-RTT packets.
public export
streamInOneRtt : frameAllowedIn StreamFrame POneRtt = True
streamInOneRtt = Refl

||| ACK frames are not allowed in 0-RTT packets.
public export
ackNotInZeroRtt : frameAllowedIn Ack PZeroRtt = False
ackNotInZeroRtt = Refl

||| HANDSHAKE_DONE is confined to 1-RTT packets.
public export
handshakeDoneNotInInitial : frameAllowedIn HandshakeDone PInitial = False
handshakeDoneNotInInitial = Refl

||| Retry packets carry no frames whatsoever.
public export
noFramesInRetry : frameAllowedIn Crypto PRetry = False
noFramesInRetry = Refl

||| Stronger, universally-quantified form: *no* frame kind is permitted in a
||| Retry packet (RFC 9000 17.2.5: Retry packets contain no frames).
public export
retryHasNoFrames : (f : FrameKind) -> frameAllowedIn f PRetry = False
retryHasNoFrames _ = Refl

||| Likewise, Version Negotiation packets carry no frames (RFC 9000 17.2.1).
public export
vnHasNoFrames : (f : FrameKind) -> frameAllowedIn f PVersionNegotiation = False
vnHasNoFrames _ = Refl

||| PADDING is universally permitted in frame-carrying packets.
public export
paddingInInitial : frameAllowedIn Padding PInitial = True
paddingInInitial = Refl

||| CRYPTO is allowed in Initial packets (it carries the TLS handshake).
public export
cryptoInInitial : frameAllowedIn Crypto PInitial = True
cryptoInInitial = Refl
