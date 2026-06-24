-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| Top-level module for proven-quic.
||| Re-exports the transport core and provides protocol constants.
module Quic

import public Quic.Types
import public Quic.Streams
import public Quic.Transitions
import public Quic.Frames

%default total

||| QUIC version 1 (RFC 9000): the value carried in long-header packets.
public export
version1 : Bits32
version1 = 0x00000001

||| Default UDP port for HTTP/3 over QUIC.
public export
defaultPort : Nat
defaultPort = 443

||| Largest value representable by a QUIC variable-length integer
||| (RFC 9000 Section 16): 2^62 - 1.
public export
maxVarint : Bits64
maxVarint = 4611686018427387903
