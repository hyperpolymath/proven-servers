-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- TLS: Top-level module for proven-tls.
-- Re-exports TLS.Types and provides TLS-related constants.

module TLS

import public TLS.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| The standard TLS port.
public export
tlsPort : Nat
tlsPort = 443

||| The minimum acceptable TLS version as a human-readable string.
public export
minVersion : String
minVersion = "TLS 1.2"

||| Maximum certificate chain depth before rejecting.
public export
maxCertChainDepth : Nat
maxCertChainDepth = 10

||| Default session ticket lifetime in seconds (2 hours).
public export
sessionTicketLifetime : Nat
sessionTicketLifetime = 7200
