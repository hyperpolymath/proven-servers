-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DNSABI.Layout: C-ABI-compatible numeric representations of DNS types.
--
-- Maps every constructor of the DNS sum types (RecordType, QueryClass,
-- Opcode, ResponseCode, DnssecAlgorithm) to fixed Bits8 values for C
-- interop.  Each type gets a total encoder, partial decoder, and
-- roundtrip proof.
--
-- Record types use sequential Bits8 tags (0-14) rather than IANA wire
-- codes.  The Zig FFI maps between ABI tags and wire format internally.
--
-- Tag values here MUST match the C header (generated/abi/dns.h) and the
-- Zig FFI enums (ffi/zig/src/dns.zig) exactly.

module DNSABI.Layout

import DNS.RecordType
import DNS.Query
import DNS.Response

%default total

---------------------------------------------------------------------------
-- RecordType (15 constructors, tags 0-14)
--
-- Standard record types (A through SRV from DNS.RecordType) plus DNSSEC
-- and CAA types added for the ABI layer.
---------------------------------------------------------------------------

||| Extended record type for the ABI, adding DNSSEC types beyond the
||| original 9 from DNS.RecordType.
public export
data AbiRecordType : Type where
  ||| A record — IPv4 address (RFC 1035).
  AbiA      : AbiRecordType
  ||| AAAA record — IPv6 address (RFC 3596).
  AbiAAAA   : AbiRecordType
  ||| CNAME record — canonical name alias (RFC 1035).
  AbiCNAME  : AbiRecordType
  ||| MX record — mail exchange (RFC 1035).
  AbiMX     : AbiRecordType
  ||| NS record — authoritative name server (RFC 1035).
  AbiNS     : AbiRecordType
  ||| PTR record — domain name pointer (RFC 1035).
  AbiPTR    : AbiRecordType
  ||| SOA record — start of authority (RFC 1035).
  AbiSOA    : AbiRecordType
  ||| SRV record — service locator (RFC 2782).
  AbiSRV    : AbiRecordType
  ||| TXT record — text strings (RFC 1035).
  AbiTXT    : AbiRecordType
  ||| CAA record — certification authority authorization (RFC 8659).
  AbiCAA    : AbiRecordType
  ||| DNSKEY record — DNSSEC public key (RFC 4034).
  AbiDNSKEY : AbiRecordType
  ||| DS record — delegation signer (RFC 4034).
  AbiDS     : AbiRecordType
  ||| RRSIG record — DNSSEC signature (RFC 4034).
  AbiRRSIG  : AbiRecordType
  ||| NSEC record — next secure (RFC 4034).
  AbiNSEC   : AbiRecordType
  ||| NSEC3 record — hashed next secure (RFC 5155).
  AbiNSEC3  : AbiRecordType

public export
Eq AbiRecordType where
  AbiA      == AbiA      = True
  AbiAAAA   == AbiAAAA   = True
  AbiCNAME  == AbiCNAME  = True
  AbiMX     == AbiMX     = True
  AbiNS     == AbiNS     = True
  AbiPTR    == AbiPTR     = True
  AbiSOA    == AbiSOA    = True
  AbiSRV    == AbiSRV    = True
  AbiTXT    == AbiTXT    = True
  AbiCAA    == AbiCAA    = True
  AbiDNSKEY == AbiDNSKEY = True
  AbiDS     == AbiDS     = True
  AbiRRSIG  == AbiRRSIG  = True
  AbiNSEC   == AbiNSEC   = True
  AbiNSEC3  == AbiNSEC3  = True
  _         == _         = False

public export
recordTypeSize : Nat
recordTypeSize = 1

public export
recordTypeToTag : AbiRecordType -> Bits8
recordTypeToTag AbiA      = 0
recordTypeToTag AbiAAAA   = 1
recordTypeToTag AbiCNAME  = 2
recordTypeToTag AbiMX     = 3
recordTypeToTag AbiNS     = 4
recordTypeToTag AbiPTR    = 5
recordTypeToTag AbiSOA    = 6
recordTypeToTag AbiSRV    = 7
recordTypeToTag AbiTXT    = 8
recordTypeToTag AbiCAA    = 9
recordTypeToTag AbiDNSKEY = 10
recordTypeToTag AbiDS     = 11
recordTypeToTag AbiRRSIG  = 12
recordTypeToTag AbiNSEC   = 13
recordTypeToTag AbiNSEC3  = 14

public export
tagToRecordType : Bits8 -> Maybe AbiRecordType
tagToRecordType 0  = Just AbiA
tagToRecordType 1  = Just AbiAAAA
tagToRecordType 2  = Just AbiCNAME
tagToRecordType 3  = Just AbiMX
tagToRecordType 4  = Just AbiNS
tagToRecordType 5  = Just AbiPTR
tagToRecordType 6  = Just AbiSOA
tagToRecordType 7  = Just AbiSRV
tagToRecordType 8  = Just AbiTXT
tagToRecordType 9  = Just AbiCAA
tagToRecordType 10 = Just AbiDNSKEY
tagToRecordType 11 = Just AbiDS
tagToRecordType 12 = Just AbiRRSIG
tagToRecordType 13 = Just AbiNSEC
tagToRecordType 14 = Just AbiNSEC3
tagToRecordType _  = Nothing

public export
recordTypeRoundtrip : (r : AbiRecordType) -> tagToRecordType (recordTypeToTag r) = Just r
recordTypeRoundtrip AbiA      = Refl
recordTypeRoundtrip AbiAAAA   = Refl
recordTypeRoundtrip AbiCNAME  = Refl
recordTypeRoundtrip AbiMX     = Refl
recordTypeRoundtrip AbiNS     = Refl
recordTypeRoundtrip AbiPTR    = Refl
recordTypeRoundtrip AbiSOA    = Refl
recordTypeRoundtrip AbiSRV    = Refl
recordTypeRoundtrip AbiTXT    = Refl
recordTypeRoundtrip AbiCAA    = Refl
recordTypeRoundtrip AbiDNSKEY = Refl
recordTypeRoundtrip AbiDS     = Refl
recordTypeRoundtrip AbiRRSIG  = Refl
recordTypeRoundtrip AbiNSEC   = Refl
recordTypeRoundtrip AbiNSEC3  = Refl

---------------------------------------------------------------------------
-- QueryClass (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
queryClassSize : Nat
queryClassSize = 1

public export
queryClassToTag : QueryClass -> Bits8
queryClassToTag IN  = 0
queryClassToTag CH  = 1
queryClassToTag HS  = 2
queryClassToTag ANY = 3

public export
tagToQueryClass : Bits8 -> Maybe QueryClass
tagToQueryClass 0 = Just IN
tagToQueryClass 1 = Just CH
tagToQueryClass 2 = Just HS
tagToQueryClass 3 = Just ANY
tagToQueryClass _ = Nothing

public export
queryClassRoundtrip : (c : QueryClass) -> tagToQueryClass (queryClassToTag c) = Just c
queryClassRoundtrip IN  = Refl
queryClassRoundtrip CH  = Refl
queryClassRoundtrip HS  = Refl
queryClassRoundtrip ANY = Refl

---------------------------------------------------------------------------
-- Opcode (5 constructors, tags 0-4)
--
-- Extends the existing 3 from DNS.Query with Notify and Update (RFC
-- 1996, RFC 2136).
---------------------------------------------------------------------------

||| Extended opcode for the ABI, adding Notify and Update.
public export
data AbiOpcode : Type where
  ||| Standard query (0).
  AbiQuery   : AbiOpcode
  ||| Inverse query (1) — obsolete per RFC 3425.
  AbiIQuery  : AbiOpcode
  ||| Server status request (2).
  AbiStatus  : AbiOpcode
  ||| Zone change notification (4, RFC 1996).
  AbiNotify  : AbiOpcode
  ||| Dynamic update (5, RFC 2136).
  AbiUpdate  : AbiOpcode

public export
Eq AbiOpcode where
  AbiQuery  == AbiQuery  = True
  AbiIQuery == AbiIQuery = True
  AbiStatus == AbiStatus = True
  AbiNotify == AbiNotify = True
  AbiUpdate == AbiUpdate = True
  _         == _         = False

public export
opcodeSize : Nat
opcodeSize = 1

public export
opcodeToTag : AbiOpcode -> Bits8
opcodeToTag AbiQuery  = 0
opcodeToTag AbiIQuery = 1
opcodeToTag AbiStatus = 2
opcodeToTag AbiNotify = 3
opcodeToTag AbiUpdate = 4

public export
tagToOpcode : Bits8 -> Maybe AbiOpcode
tagToOpcode 0 = Just AbiQuery
tagToOpcode 1 = Just AbiIQuery
tagToOpcode 2 = Just AbiStatus
tagToOpcode 3 = Just AbiNotify
tagToOpcode 4 = Just AbiUpdate
tagToOpcode _ = Nothing

public export
opcodeRoundtrip : (o : AbiOpcode) -> tagToOpcode (opcodeToTag o) = Just o
opcodeRoundtrip AbiQuery  = Refl
opcodeRoundtrip AbiIQuery = Refl
opcodeRoundtrip AbiStatus = Refl
opcodeRoundtrip AbiNotify = Refl
opcodeRoundtrip AbiUpdate = Refl

---------------------------------------------------------------------------
-- ResponseCode (11 constructors, tags 0-10)
--
-- Extends the existing 6 from DNS.Response with YXDomain, YXRRSet,
-- NXRRSet, NotAuth, NotZone (RFC 2136).
---------------------------------------------------------------------------

||| Extended response code for the ABI, covering update response codes.
public export
data AbiResponseCode : Type where
  ||| No error (0).
  AbiNoError  : AbiResponseCode
  ||| Format error (1).
  AbiFormErr  : AbiResponseCode
  ||| Server failure (2).
  AbiServFail : AbiResponseCode
  ||| Non-existent domain (3).
  AbiNXDomain : AbiResponseCode
  ||| Not implemented (4).
  AbiNotImp   : AbiResponseCode
  ||| Query refused (5).
  AbiRefused  : AbiResponseCode
  ||| Name exists when it should not (6, RFC 2136).
  AbiYXDomain : AbiResponseCode
  ||| RR set exists when it should not (7, RFC 2136).
  AbiYXRRSet  : AbiResponseCode
  ||| RR set that should exist does not (8, RFC 2136).
  AbiNXRRSet  : AbiResponseCode
  ||| Not authoritative (9, RFC 2136).
  AbiNotAuth  : AbiResponseCode
  ||| Name not contained in zone (10, RFC 2136).
  AbiNotZone  : AbiResponseCode

public export
Eq AbiResponseCode where
  AbiNoError  == AbiNoError  = True
  AbiFormErr  == AbiFormErr  = True
  AbiServFail == AbiServFail = True
  AbiNXDomain == AbiNXDomain = True
  AbiNotImp   == AbiNotImp   = True
  AbiRefused  == AbiRefused  = True
  AbiYXDomain == AbiYXDomain = True
  AbiYXRRSet  == AbiYXRRSet  = True
  AbiNXRRSet  == AbiNXRRSet  = True
  AbiNotAuth  == AbiNotAuth  = True
  AbiNotZone  == AbiNotZone  = True
  _           == _           = False

public export
responseCodeSize : Nat
responseCodeSize = 1

public export
responseCodeToTag : AbiResponseCode -> Bits8
responseCodeToTag AbiNoError  = 0
responseCodeToTag AbiFormErr  = 1
responseCodeToTag AbiServFail = 2
responseCodeToTag AbiNXDomain = 3
responseCodeToTag AbiNotImp   = 4
responseCodeToTag AbiRefused  = 5
responseCodeToTag AbiYXDomain = 6
responseCodeToTag AbiYXRRSet  = 7
responseCodeToTag AbiNXRRSet  = 8
responseCodeToTag AbiNotAuth  = 9
responseCodeToTag AbiNotZone  = 10

public export
tagToResponseCode : Bits8 -> Maybe AbiResponseCode
tagToResponseCode 0  = Just AbiNoError
tagToResponseCode 1  = Just AbiFormErr
tagToResponseCode 2  = Just AbiServFail
tagToResponseCode 3  = Just AbiNXDomain
tagToResponseCode 4  = Just AbiNotImp
tagToResponseCode 5  = Just AbiRefused
tagToResponseCode 6  = Just AbiYXDomain
tagToResponseCode 7  = Just AbiYXRRSet
tagToResponseCode 8  = Just AbiNXRRSet
tagToResponseCode 9  = Just AbiNotAuth
tagToResponseCode 10 = Just AbiNotZone
tagToResponseCode _  = Nothing

public export
responseCodeRoundtrip : (r : AbiResponseCode) -> tagToResponseCode (responseCodeToTag r) = Just r
responseCodeRoundtrip AbiNoError  = Refl
responseCodeRoundtrip AbiFormErr  = Refl
responseCodeRoundtrip AbiServFail = Refl
responseCodeRoundtrip AbiNXDomain = Refl
responseCodeRoundtrip AbiNotImp   = Refl
responseCodeRoundtrip AbiRefused  = Refl
responseCodeRoundtrip AbiYXDomain = Refl
responseCodeRoundtrip AbiYXRRSet  = Refl
responseCodeRoundtrip AbiNXRRSet  = Refl
responseCodeRoundtrip AbiNotAuth  = Refl
responseCodeRoundtrip AbiNotZone  = Refl

---------------------------------------------------------------------------
-- DnssecAlgorithm (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| DNSSEC signing algorithm identifiers (RFC 8624).
public export
data DnssecAlgorithm : Type where
  ||| RSA/SHA-256 (algorithm 8).
  RsaSha256       : DnssecAlgorithm
  ||| RSA/SHA-512 (algorithm 10).
  RsaSha512       : DnssecAlgorithm
  ||| ECDSA P-256/SHA-256 (algorithm 13).
  EcdsaP256Sha256 : DnssecAlgorithm
  ||| ECDSA P-384/SHA-384 (algorithm 14).
  EcdsaP384Sha384 : DnssecAlgorithm
  ||| Ed25519 (algorithm 15).
  Ed25519         : DnssecAlgorithm

public export
Eq DnssecAlgorithm where
  RsaSha256       == RsaSha256       = True
  RsaSha512       == RsaSha512       = True
  EcdsaP256Sha256 == EcdsaP256Sha256 = True
  EcdsaP384Sha384 == EcdsaP384Sha384 = True
  Ed25519         == Ed25519         = True
  _               == _               = False

public export
dnssecAlgorithmSize : Nat
dnssecAlgorithmSize = 1

public export
dnssecAlgorithmToTag : DnssecAlgorithm -> Bits8
dnssecAlgorithmToTag RsaSha256       = 0
dnssecAlgorithmToTag RsaSha512       = 1
dnssecAlgorithmToTag EcdsaP256Sha256 = 2
dnssecAlgorithmToTag EcdsaP384Sha384 = 3
dnssecAlgorithmToTag Ed25519         = 4

public export
tagToDnssecAlgorithm : Bits8 -> Maybe DnssecAlgorithm
tagToDnssecAlgorithm 0 = Just RsaSha256
tagToDnssecAlgorithm 1 = Just RsaSha512
tagToDnssecAlgorithm 2 = Just EcdsaP256Sha256
tagToDnssecAlgorithm 3 = Just EcdsaP384Sha384
tagToDnssecAlgorithm 4 = Just Ed25519
tagToDnssecAlgorithm _ = Nothing

public export
dnssecAlgorithmRoundtrip : (a : DnssecAlgorithm) -> tagToDnssecAlgorithm (dnssecAlgorithmToTag a) = Just a
dnssecAlgorithmRoundtrip RsaSha256       = Refl
dnssecAlgorithmRoundtrip RsaSha512       = Refl
dnssecAlgorithmRoundtrip EcdsaP256Sha256 = Refl
dnssecAlgorithmRoundtrip EcdsaP384Sha384 = Refl
dnssecAlgorithmRoundtrip Ed25519         = Refl

---------------------------------------------------------------------------
-- Conversion: DNS.RecordType <-> AbiRecordType
---------------------------------------------------------------------------

||| Map the existing 9 DNS.RecordType constructors into AbiRecordType.
public export
fromRecordType : RecordType -> AbiRecordType
fromRecordType A     = AbiA
fromRecordType AAAA  = AbiAAAA
fromRecordType CNAME = AbiCNAME
fromRecordType MX    = AbiMX
fromRecordType NS    = AbiNS
fromRecordType PTR   = AbiPTR
fromRecordType SOA   = AbiSOA
fromRecordType SRV   = AbiSRV
fromRecordType TXT   = AbiTXT

||| Map an AbiRecordType back to DNS.RecordType if it is one of the
||| original 9 types.  Returns Nothing for DNSSEC/CAA types.
public export
toRecordType : AbiRecordType -> Maybe RecordType
toRecordType AbiA      = Just A
toRecordType AbiAAAA   = Just AAAA
toRecordType AbiCNAME  = Just CNAME
toRecordType AbiMX     = Just MX
toRecordType AbiNS     = Just NS
toRecordType AbiPTR    = Just PTR
toRecordType AbiSOA    = Just SOA
toRecordType AbiSRV    = Just SRV
toRecordType AbiTXT    = Just TXT
toRecordType _         = Nothing

---------------------------------------------------------------------------
-- Conversion: DNS.Query.Opcode <-> AbiOpcode
---------------------------------------------------------------------------

||| Map the existing 3 Opcode constructors into AbiOpcode.
public export
fromOpcode : Opcode -> AbiOpcode
fromOpcode StandardQuery = AbiQuery
fromOpcode InverseQuery  = AbiIQuery
fromOpcode StatusRequest = AbiStatus

---------------------------------------------------------------------------
-- Conversion: DNS.Response.ResponseCode <-> AbiResponseCode
---------------------------------------------------------------------------

||| Map the existing 6 ResponseCode constructors into AbiResponseCode.
public export
fromResponseCode : ResponseCode -> AbiResponseCode
fromResponseCode NOERROR  = AbiNoError
fromResponseCode FORMERR  = AbiFormErr
fromResponseCode SERVFAIL = AbiServFail
fromResponseCode NXDOMAIN = AbiNXDomain
fromResponseCode NOTIMP   = AbiNotImp
fromResponseCode REFUSED  = AbiRefused
