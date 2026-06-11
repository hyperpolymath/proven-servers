-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CAABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.  The CA FFI manages certificate
-- lifecycle, chain validation, CRL management, and OCSP responder state.

module CAABI.Foreign

import CA.Types
import CAABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a CA context (certificate store + CRL + OCSP state).
||| Created by ca_create(), destroyed by ca_destroy().
export
data CaHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version — must match ca_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (20 functions)
---------------------------------------------------------------------------

-- +-------------------------------------------------------------------------+
-- | Function                | Signature                                     |
-- +-------------------------+-----------------------------------------------+
-- | ca_abi_version          | () -> Bits32                                  |
-- +-------------------------+-----------------------------------------------+
-- | ca_create               | () -> c_int (slot, -1 on failure)             |
-- |                         | Creates a CA context.                         |
-- +-------------------------+-----------------------------------------------+
-- | ca_destroy              | (slot: c_int) -> ()                           |
-- |                         | Releases a CA context.                        |
-- +-------------------------+-----------------------------------------------+
-- | ca_issue_cert           | (slot: c_int, cert_type: u8, key_algo: u8,   |
-- |                         |  sig_algo: u8) -> c_int (cert_id, -1=fail)   |
-- |                         | Issues a new certificate in Pending state.    |
-- +-------------------------+-----------------------------------------------+
-- | ca_sign_cert            | (slot: c_int, cert_id: c_int) -> u8          |
-- |                         | Pending -> Active. 0=ok, 1=rejected.         |
-- +-------------------------+-----------------------------------------------+
-- | ca_revoke_cert          | (slot: c_int, cert_id: c_int,                |
-- |                         |  reason: u8) -> u8                            |
-- |                         | Active/Suspended -> Revoked. 0=ok, 1=reject. |
-- +-------------------------+-----------------------------------------------+
-- | ca_suspend_cert         | (slot: c_int, cert_id: c_int) -> u8          |
-- |                         | Active -> Suspended. 0=ok, 1=rejected.       |
-- +-------------------------+-----------------------------------------------+
-- | ca_reinstate_cert       | (slot: c_int, cert_id: c_int) -> u8          |
-- |                         | Suspended -> Active. 0=ok, 1=rejected.       |
-- +-------------------------+-----------------------------------------------+
-- | ca_expire_cert          | (slot: c_int, cert_id: c_int) -> u8          |
-- |                         | Active -> Expired. 0=ok, 1=rejected.         |
-- +-------------------------+-----------------------------------------------+
-- | ca_renew_cert           | (slot: c_int, cert_id: c_int) -> c_int       |
-- |                         | Active -> Pending (new cert). Returns new id. |
-- +-------------------------+-----------------------------------------------+
-- | ca_cert_state           | (slot: c_int, cert_id: c_int) -> u8          |
-- |                         | Returns CertState tag.  255 = invalid.       |
-- +-------------------------+-----------------------------------------------+
-- | ca_cert_type            | (slot: c_int, cert_id: c_int) -> u8          |
-- |                         | Returns CertType tag.  255 = invalid.        |
-- +-------------------------+-----------------------------------------------+
-- | ca_cert_key_algo        | (slot: c_int, cert_id: c_int) -> u8          |
-- |                         | Returns KeyAlgorithm tag.  255 = invalid.    |
-- +-------------------------+-----------------------------------------------+
-- | ca_cert_sig_algo        | (slot: c_int, cert_id: c_int) -> u8          |
-- |                         | Returns SignatureAlgorithm tag. 255=invalid. |
-- +-------------------------+-----------------------------------------------+
-- | ca_cert_count           | (slot: c_int) -> c_int                       |
-- |                         | Number of certificates in this CA context.   |
-- +-------------------------+-----------------------------------------------+
-- | ca_validate_chain       | (slot: c_int, cert_id: c_int) -> u8          |
-- |                         | Validates issuer chain. 0=valid, 1=invalid.  |
-- +-------------------------+-----------------------------------------------+
-- | ca_can_issue            | (issuer: u8, child: u8) -> u8                |
-- |                         | Stateless: can issuer type issue child type? |
-- |                         | 1=yes, 0=no.  Matches CanIssue GADT.        |
-- +-------------------------+-----------------------------------------------+
-- | ca_can_transition       | (from: u8, to: u8) -> u8                     |
-- |                         | Stateless: is state transition valid?        |
-- |                         | 1=yes, 0=no.  Matches ValidCertTransition.  |
-- +-------------------------+-----------------------------------------------+
-- | ca_crl_status           | (slot: c_int) -> u8                          |
-- |                         | Returns CRLStatus tag for this CA context.   |
-- +-------------------------+-----------------------------------------------+
-- | ca_update_crl           | (slot: c_int) -> u8                          |
-- |                         | Refreshes the CRL. 0=ok, 1=error.           |
-- +-------------------------+-----------------------------------------------+
-- | ca_ocsp_status          | (slot: c_int) -> u8                          |
-- |                         | Returns OCSPStatus tag for this CA context.  |
-- +-------------------------+-----------------------------------------------+
-- | ca_ocsp_query           | (slot: c_int, cert_id: c_int) -> u8          |
-- |                         | Queries OCSP for a cert. Returns OCSPStatus  |
-- |                         | tag (Good/Revoked/Unknown/Unavailable).      |
-- +-------------------------+-----------------------------------------------+
-- | ca_set_issuer           | (slot: c_int, cert_id: c_int,                |
-- |                         |  issuer_id: c_int) -> u8                     |
-- |                         | Sets the issuer of a cert. 0=ok, 1=rejected. |
-- |                         | Validates CanIssue(issuer_type, child_type). |
-- +-------------------------+-----------------------------------------------+
-- | ca_cert_issuer          | (slot: c_int, cert_id: c_int) -> c_int       |
-- |                         | Returns issuer cert id.  -1 = self-signed.   |
-- +-------------------------+-----------------------------------------------+
-- | ca_set_validity         | (slot: c_int, cert_id: c_int,                |
-- |                         |  not_before: u64, not_after: u64) -> u8      |
-- |                         | Sets validity period.  Enforces               |
-- |                         | notBefore < notAfter.  0=ok, 1=rejected.     |
-- +-------------------------+-----------------------------------------------+
-- | ca_cert_not_before      | (slot: c_int, cert_id: c_int) -> u64         |
-- |                         | Returns notBefore epoch.  0 = unset.         |
-- +-------------------------+-----------------------------------------------+
-- | ca_cert_not_after       | (slot: c_int, cert_id: c_int) -> u64         |
-- |                         | Returns notAfter epoch.  0 = unset.          |
-- +-------------------------+-----------------------------------------------+
-- | ca_cert_serial          | (slot: c_int, cert_id: c_int) -> u64         |
-- |                         | Returns monotonic serial number.  0=invalid. |
-- +-------------------------+-----------------------------------------------+
-- | ca_next_serial          | (slot: c_int) -> u64                         |
-- |                         | Returns next serial that will be assigned.   |
-- +-------------------------+-----------------------------------------------+
-- | ca_set_path_length      | (slot: c_int, cert_id: c_int,                |
-- |                         |  max_path_len: i32) -> u8                    |
-- |                         | Sets path length constraint.  -1=none.       |
-- |                         | Only CA types may have >= 0.  0=ok, 1=fail.  |
-- +-------------------------+-----------------------------------------------+
-- | ca_cert_path_length     | (slot: c_int, cert_id: c_int) -> i32         |
-- |                         | Returns path length.  -1 = unconstrained.    |
-- +-------------------------+-----------------------------------------------+
-- | ca_validate_path_length | (slot: c_int, cert_id: c_int) -> u8          |
-- |                         | Validates path length decreases along chain. |
-- |                         | 0=valid, 1=violation.                        |
-- +-------------------------+-----------------------------------------------+
-- | ca_set_key_usage        | (slot: c_int, cert_id: c_int,                |
-- |                         |  key_usage_bits: u16) -> u8                  |
-- |                         | Sets key usage bitmask.  0=ok, 1=rejected.   |
-- +-------------------------+-----------------------------------------------+
-- | ca_cert_key_usage       | (slot: c_int, cert_id: c_int) -> u16         |
-- |                         | Returns key usage bitmask.  0 = none.        |
-- +-------------------------+-----------------------------------------------+
-- | ca_validate_key_usage   | (slot: c_int, cert_id: c_int) -> u8          |
-- |                         | Validates key usage vs cert type.            |
-- |                         | CA must have keyCertSign; leaf must not.     |
-- |                         | 0=valid, 1=inconsistent.                     |
-- +-------------------------+-----------------------------------------------+
