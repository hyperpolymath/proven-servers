-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TLSABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module TLSABI.Foreign

import TLS.Types
import TLSABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a TLS session.
||| Created by tls_create(), destroyed by tls_destroy().
export
data TlsHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version — must match tls_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function              | Signature                                     |
-- +-----------------------+-----------------------------------------------+
-- | tls_abi_version       | () -> Bits32                                  |
-- +-----------------------+-----------------------------------------------+
-- | tls_create            | (version: u8, cipher: u8) -> c_int (slot)     |
-- |                       | Creates session in ClientHello state.         |
-- +-----------------------+-----------------------------------------------+
-- | tls_destroy           | (slot: c_int) -> ()                           |
-- +-----------------------+-----------------------------------------------+
-- | tls_state             | (slot: c_int) -> u8 (HandshakeState tag)      |
-- +-----------------------+-----------------------------------------------+
-- | tls_version           | (slot: c_int) -> u8 (TLSVersion tag)          |
-- +-----------------------+-----------------------------------------------+
-- | tls_cipher            | (slot: c_int) -> u8 (CipherSuite tag)         |
-- +-----------------------+-----------------------------------------------+
-- | tls_advance           | (slot: c_int) -> u8 (0=ok, 1=rejected)        |
-- |                       | Advances to the next valid handshake state.   |
-- +-----------------------+-----------------------------------------------+
-- | tls_abort             | (slot: c_int, alert: u8) -> u8                |
-- |                       | Transitions to Closed with an alert.          |
-- +-----------------------+-----------------------------------------------+
-- | tls_key_update        | (slot: c_int) -> u8 (0=ok, 1=rejected)        |
-- |                       | Established -> Established rekey.             |
-- +-----------------------+-----------------------------------------------+
-- | tls_close             | (slot: c_int) -> u8 (0=ok, 1=rejected)        |
-- |                       | Established -> Closed (graceful close).       |
-- +-----------------------+-----------------------------------------------+
-- | tls_can_send          | (slot: c_int) -> u8 (1=yes, 0=no)             |
-- |                       | Whether application data can flow.            |
-- +-----------------------+-----------------------------------------------+
-- | tls_last_alert        | (slot: c_int) -> u8 (AlertDescription tag)    |
-- +-----------------------+-----------------------------------------------+
-- | tls_validate_cert     | (slot: c_int, result: u8) -> u8               |
-- |                       | Records a CertValidation result.              |
-- +-----------------------+-----------------------------------------------+
-- | tls_cert_status       | (slot: c_int) -> u8 (CertValidation tag)      |
-- +-----------------------+-----------------------------------------------+
-- | tls_can_transition    | (from: u8, to: u8) -> u8 (1=yes, 0=no)        |
-- +-----------------------+-----------------------------------------------+
