-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- =========================================================================
-- SECURITY WARNING — READ THIS BEFORE USING THIS SKELETON
-- =========================================================================
--
-- Telnet (RFC 854) is a FUNDAMENTALLY INSECURE protocol.
--
--   - All traffic is transmitted in CLEARTEXT (passwords, commands, data)
--   - There is NO authentication mechanism in the protocol itself
--   - There is NO integrity checking — data can be modified in transit
--   - There is NO encryption — anyone on the network can read everything
--   - IAC command injection can be used for protocol-level attacks
--
-- Telnet has been SUPERSEDED by SSH (RFC 4253) for ALL interactive use.
-- Use proven-ssh-bastion instead.
--
-- This skeleton exists ONLY for:
--   1. Interfacing with legacy hardware that speaks only telnet
--      (old network switches, PLCs, industrial equipment)
--   2. Building a TLS-wrapping proxy in front of such hardware
--      (compose with proven-proxy or proven-ssh-bastion)
--   3. Educational/research purposes
--
-- If you are building a new interactive remote access system and you
-- reach for this skeleton instead of proven-ssh-bastion, you are
-- making a mistake. We provide this skeleton so you can interface
-- with legacy systems safely — not so you can build new insecure ones.
--
-- The recommended architecture for legacy telnet devices:
--
--   [Client] --SSH--> [proven-ssh-bastion] --telnet--> [Legacy Device]
--                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--                     Secure boundary ends here.
--                     The bastion handles the insecure hop internally.
--
-- =========================================================================

||| Top-level module for proven-telnet.
||| Re-exports Telnet.Types and provides protocol constants.
|||
||| **INSECURE PROTOCOL** — See security warning above.
||| Use proven-ssh-bastion for all new interactive access.
||| This skeleton is for legacy device interoperability only.
module Telnet

import public Telnet.Types

%default total

---------------------------------------------------------------------------
-- Protocol Constants (RFC 854)
---------------------------------------------------------------------------

||| Default Telnet port.
||| **WARNING:** Port 23 is unencrypted. Use behind a TLS proxy or SSH bastion.
public export
telnetPort : Nat
telnetPort = 23

||| Maximum line length in bytes.
public export
maxLineLength : Nat
maxLineLength = 512

||| Security notice string. Implementations SHOULD display this on startup.
public export
securityNotice : String
securityNotice = "WARNING: Telnet is an insecure protocol. All traffic is cleartext. Use SSH instead."
