-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| Top-level module for proven-http3.
||| Re-exports the core and provides protocol constants.
module Http3

import public Http3.Types
import public Http3.Frames
import public Http3.Request

%default total

||| The ALPN protocol identifier for HTTP/3 (RFC 9114 Section 3.1).
public export
alpn : String
alpn = "h3"

||| Default UDP port for HTTP/3.
public export
defaultPort : Nat
defaultPort = 443
