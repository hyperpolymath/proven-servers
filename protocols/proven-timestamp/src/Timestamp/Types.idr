-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| Core data types and constants for proven-timestamp.
|||
||| proven-timestamp is an evidence-preservation timestamp receipt service:
||| it hashes submitted content and records a tamper-evident, hash-chained
||| receipt proving the content existed at or before a given time.  It is
||| NOT a qualified electronic timestamping authority (see `disclaimer`).
module Timestamp.Types

%default total

---------------------------------------------------------------------------
-- Hash algorithm
---------------------------------------------------------------------------

||| Hash algorithm recorded in every receipt's `hash_algorithm` field.
|||
||| All four are real, standardised, and quantum-resistant at the 256-bit
||| level: Grover's algorithm gives only a quadratic speed-up, so a 256-bit
||| digest retains ~128-bit pre-image strength against a quantum adversary.
|||
||| NOTE on the brief: it asked for a "SHAKE512-256/Kyber-1024 hash".  That
||| conflates a hash / extendable-output function (SHAKE, SHA-2, SHA-3) with
||| a key-encapsulation mechanism (Kyber / ML-KEM-1024), which cannot hash
||| data.  We therefore implement real hashes and record, per receipt, which
||| one was used — so the format can evolve without breaking verification.
public export
data HashAlgo : Type where
  ||| SHA-256 (FIPS 180-4).
  SHA256     : HashAlgo
  ||| SHA-512/256 (FIPS 180-4): SHA-512 truncated to 256 bits.
  SHA512_256 : HashAlgo
  ||| SHA3-256 (FIPS 202).  The service default.
  SHA3_256   : HashAlgo
  ||| SHAKE256 squeezed to 256 bits (FIPS 202 XOF).
  SHAKE256   : HashAlgo

public export
Eq HashAlgo where
  SHA256     == SHA256     = True
  SHA512_256 == SHA512_256 = True
  SHA3_256   == SHA3_256   = True
  SHAKE256   == SHAKE256   = True
  _          == _          = False

||| Canonical wire names.  These MUST match the Zig engine exactly because
||| the name is embedded in the receipt pre-image that gets hashed.
public export
Show HashAlgo where
  show SHA256     = "sha-256"
  show SHA512_256 = "sha-512-256"
  show SHA3_256   = "sha3-256"
  show SHAKE256   = "shake-256"

---------------------------------------------------------------------------
-- Timestamp source
---------------------------------------------------------------------------

||| Where a receipt's timestamp authority comes from (`timestamp_source`).
||| v1 only ever emits `Internal`; the others are reserved for the
||| RFC 3161 and external-anchoring providers (see Timestamp.Provider).
public export
data TimestampSource : Type where
  ||| The local, non-qualified internal clock.
  Internal : TimestampSource
  ||| An external RFC 3161 Time-Stamping Authority (future).
  Rfc3161  : TimestampSource
  ||| Anchored into an external ledger / transparency log (future).
  Anchored : TimestampSource

public export
Eq TimestampSource where
  Internal == Internal = True
  Rfc3161  == Rfc3161  = True
  Anchored == Anchored = True
  _        == _        = False

public export
Show TimestampSource where
  show Internal = "internal"
  show Rfc3161  = "rfc3161"
  show Anchored = "anchored"

---------------------------------------------------------------------------
-- Verification result
---------------------------------------------------------------------------

||| Outcome of a verification request (content re-hash or chain walk).
public export
data VerificationResult : Type where
  ||| Content hash and/or chain links all match.
  Verified        : VerificationResult
  ||| Re-hashed content does not match the receipt's content_hash.
  ContentMismatch : VerificationResult
  ||| A receipt's previous_receipt_hash does not match its predecessor.
  ChainBroken     : VerificationResult
  ||| No receipt with the requested id exists.
  NotFound        : VerificationResult

public export
Eq VerificationResult where
  Verified        == Verified        = True
  ContentMismatch == ContentMismatch = True
  ChainBroken     == ChainBroken     = True
  NotFound        == NotFound        = True
  _               == _               = False

public export
Show VerificationResult where
  show Verified        = "verified"
  show ContentMismatch = "content_mismatch"
  show ChainBroken     = "chain_broken"
  show NotFound        = "not_found"

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| 64 hex zeros: the conventional predecessor of the first receipt.
||| The genesis receipt's `previous_receipt_hash` equals this value.
public export
genesisHash : String
genesisHash = "0000000000000000000000000000000000000000000000000000000000000000"

||| Embedded in every serialised receipt so a third party can re-check it.
public export
verificationInstructions : String
verificationInstructions = "Recompute the content hash with the named hash_algorithm and compare it to content_hash; then recompute receipt_hash over the canonical pre-image and confirm previous_receipt_hash equals the prior receipt's receipt_hash."

||| Honest framing carried by every receipt.
public export
disclaimer : String
disclaimer = "NOT a qualified electronic timestamp. Internal evidence only; not produced by an RFC 3161 TSA or a qualified trust service."
