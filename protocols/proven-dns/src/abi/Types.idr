-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DnsABI.Types: C-ABI-compatible numeric representations of Dns types.
--
-- Maps every constructor of the core Dns sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/dns.zig) exactly.
--
-- Types covered:
--   RecordType                (15 constructors, tags 0-14)
--   QueryClass                (4 constructors, tags 0-3)
--   Opcode                    (5 constructors, tags 0-4)
--   ResponseCode              (11 constructors, tags 0-10)
--   DnsState                  (5 constructors, tags 0-4)
--   DnssecState               (4 constructors, tags 0-3)
--   DnssecAlgorithm           (5 constructors, tags 0-4)

module DnsABI.Types

%default total

---------------------------------------------------------------------------
-- RecordType (15 constructors, tags 0-14)
---------------------------------------------------------------------------

public export
record_typeSize : Nat
record_typeSize = 1

||| RecordType sum type for ABI encoding.
public export
data RecordType : Type where
  A : RecordType
  Aaaa : RecordType
  Cname : RecordType
  Mx : RecordType
  Ns : RecordType
  Ptr : RecordType
  Soa : RecordType
  Srv : RecordType
  Txt : RecordType
  Caa : RecordType
  Dnskey : RecordType
  Ds : RecordType
  Rrsig : RecordType
  Nsec : RecordType
  Nsec3 : RecordType

||| Encode a RecordType to its ABI tag value.
public export
record_typeToTag : RecordType -> Bits8
record_typeToTag A = 0
record_typeToTag Aaaa = 1
record_typeToTag Cname = 2
record_typeToTag Mx = 3
record_typeToTag Ns = 4
record_typeToTag Ptr = 5
record_typeToTag Soa = 6
record_typeToTag Srv = 7
record_typeToTag Txt = 8
record_typeToTag Caa = 9
record_typeToTag Dnskey = 10
record_typeToTag Ds = 11
record_typeToTag Rrsig = 12
record_typeToTag Nsec = 13
record_typeToTag Nsec3 = 14

||| Decode an ABI tag to a RecordType.
public export
tagToRecordType : Bits8 -> Maybe RecordType
tagToRecordType 0 = Just A
tagToRecordType 1 = Just Aaaa
tagToRecordType 2 = Just Cname
tagToRecordType 3 = Just Mx
tagToRecordType 4 = Just Ns
tagToRecordType 5 = Just Ptr
tagToRecordType 6 = Just Soa
tagToRecordType 7 = Just Srv
tagToRecordType 8 = Just Txt
tagToRecordType 9 = Just Caa
tagToRecordType 10 = Just Dnskey
tagToRecordType 11 = Just Ds
tagToRecordType 12 = Just Rrsig
tagToRecordType 13 = Just Nsec
tagToRecordType 14 = Just Nsec3
tagToRecordType _ = Nothing

||| Roundtrip proof: decoding an encoded RecordType yields the original.
public export
record_typeRoundtrip : (x : RecordType) -> tagToRecordType (record_typeToTag x) = Just x
record_typeRoundtrip A = Refl
record_typeRoundtrip Aaaa = Refl
record_typeRoundtrip Cname = Refl
record_typeRoundtrip Mx = Refl
record_typeRoundtrip Ns = Refl
record_typeRoundtrip Ptr = Refl
record_typeRoundtrip Soa = Refl
record_typeRoundtrip Srv = Refl
record_typeRoundtrip Txt = Refl
record_typeRoundtrip Caa = Refl
record_typeRoundtrip Dnskey = Refl
record_typeRoundtrip Ds = Refl
record_typeRoundtrip Rrsig = Refl
record_typeRoundtrip Nsec = Refl
record_typeRoundtrip Nsec3 = Refl

---------------------------------------------------------------------------
-- QueryClass (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
query_classSize : Nat
query_classSize = 1

||| QueryClass sum type for ABI encoding.
public export
data QueryClass : Type where
  In : QueryClass
  Ch : QueryClass
  Hs : QueryClass
  Any : QueryClass

||| Encode a QueryClass to its ABI tag value.
public export
query_classToTag : QueryClass -> Bits8
query_classToTag In = 0
query_classToTag Ch = 1
query_classToTag Hs = 2
query_classToTag Any = 3

||| Decode an ABI tag to a QueryClass.
public export
tagToQueryClass : Bits8 -> Maybe QueryClass
tagToQueryClass 0 = Just In
tagToQueryClass 1 = Just Ch
tagToQueryClass 2 = Just Hs
tagToQueryClass 3 = Just Any
tagToQueryClass _ = Nothing

||| Roundtrip proof: decoding an encoded QueryClass yields the original.
public export
query_classRoundtrip : (x : QueryClass) -> tagToQueryClass (query_classToTag x) = Just x
query_classRoundtrip In = Refl
query_classRoundtrip Ch = Refl
query_classRoundtrip Hs = Refl
query_classRoundtrip Any = Refl

---------------------------------------------------------------------------
-- Opcode (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
opcodeSize : Nat
opcodeSize = 1

||| Opcode sum type for ABI encoding.
public export
data Opcode : Type where
  Query : Opcode
  Iquery : Opcode
  Status : Opcode
  Notify : Opcode
  Update : Opcode

||| Encode a Opcode to its ABI tag value.
public export
opcodeToTag : Opcode -> Bits8
opcodeToTag Query = 0
opcodeToTag Iquery = 1
opcodeToTag Status = 2
opcodeToTag Notify = 3
opcodeToTag Update = 4

||| Decode an ABI tag to a Opcode.
public export
tagToOpcode : Bits8 -> Maybe Opcode
tagToOpcode 0 = Just Query
tagToOpcode 1 = Just Iquery
tagToOpcode 2 = Just Status
tagToOpcode 3 = Just Notify
tagToOpcode 4 = Just Update
tagToOpcode _ = Nothing

||| Roundtrip proof: decoding an encoded Opcode yields the original.
public export
opcodeRoundtrip : (x : Opcode) -> tagToOpcode (opcodeToTag x) = Just x
opcodeRoundtrip Query = Refl
opcodeRoundtrip Iquery = Refl
opcodeRoundtrip Status = Refl
opcodeRoundtrip Notify = Refl
opcodeRoundtrip Update = Refl

---------------------------------------------------------------------------
-- ResponseCode (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
response_codeSize : Nat
response_codeSize = 1

||| ResponseCode sum type for ABI encoding.
public export
data ResponseCode : Type where
  NoError : ResponseCode
  FormErr : ResponseCode
  ServFail : ResponseCode
  NxDomain : ResponseCode
  NotImp : ResponseCode
  Refused : ResponseCode
  YxDomain : ResponseCode
  YxRrset : ResponseCode
  NxRrset : ResponseCode
  NotAuth : ResponseCode
  NotZone : ResponseCode

||| Encode a ResponseCode to its ABI tag value.
public export
response_codeToTag : ResponseCode -> Bits8
response_codeToTag NoError = 0
response_codeToTag FormErr = 1
response_codeToTag ServFail = 2
response_codeToTag NxDomain = 3
response_codeToTag NotImp = 4
response_codeToTag Refused = 5
response_codeToTag YxDomain = 6
response_codeToTag YxRrset = 7
response_codeToTag NxRrset = 8
response_codeToTag NotAuth = 9
response_codeToTag NotZone = 10

||| Decode an ABI tag to a ResponseCode.
public export
tagToResponseCode : Bits8 -> Maybe ResponseCode
tagToResponseCode 0 = Just NoError
tagToResponseCode 1 = Just FormErr
tagToResponseCode 2 = Just ServFail
tagToResponseCode 3 = Just NxDomain
tagToResponseCode 4 = Just NotImp
tagToResponseCode 5 = Just Refused
tagToResponseCode 6 = Just YxDomain
tagToResponseCode 7 = Just YxRrset
tagToResponseCode 8 = Just NxRrset
tagToResponseCode 9 = Just NotAuth
tagToResponseCode 10 = Just NotZone
tagToResponseCode _ = Nothing

||| Roundtrip proof: decoding an encoded ResponseCode yields the original.
public export
response_codeRoundtrip : (x : ResponseCode) -> tagToResponseCode (response_codeToTag x) = Just x
response_codeRoundtrip NoError = Refl
response_codeRoundtrip FormErr = Refl
response_codeRoundtrip ServFail = Refl
response_codeRoundtrip NxDomain = Refl
response_codeRoundtrip NotImp = Refl
response_codeRoundtrip Refused = Refl
response_codeRoundtrip YxDomain = Refl
response_codeRoundtrip YxRrset = Refl
response_codeRoundtrip NxRrset = Refl
response_codeRoundtrip NotAuth = Refl
response_codeRoundtrip NotZone = Refl

---------------------------------------------------------------------------
-- DnsState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
dns_stateSize : Nat
dns_stateSize = 1

||| DnsState sum type for ABI encoding.
public export
data DnsState : Type where
  Idle : DnsState
  QueryReceived : DnsState
  Lookup : DnsState
  ResponseBuilding : DnsState
  Sent : DnsState

||| Encode a DnsState to its ABI tag value.
public export
dns_stateToTag : DnsState -> Bits8
dns_stateToTag Idle = 0
dns_stateToTag QueryReceived = 1
dns_stateToTag Lookup = 2
dns_stateToTag ResponseBuilding = 3
dns_stateToTag Sent = 4

||| Decode an ABI tag to a DnsState.
public export
tagToDnsState : Bits8 -> Maybe DnsState
tagToDnsState 0 = Just Idle
tagToDnsState 1 = Just QueryReceived
tagToDnsState 2 = Just Lookup
tagToDnsState 3 = Just ResponseBuilding
tagToDnsState 4 = Just Sent
tagToDnsState _ = Nothing

||| Roundtrip proof: decoding an encoded DnsState yields the original.
public export
dns_stateRoundtrip : (x : DnsState) -> tagToDnsState (dns_stateToTag x) = Just x
dns_stateRoundtrip Idle = Refl
dns_stateRoundtrip QueryReceived = Refl
dns_stateRoundtrip Lookup = Refl
dns_stateRoundtrip ResponseBuilding = Refl
dns_stateRoundtrip Sent = Refl

---------------------------------------------------------------------------
-- DnssecState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
dnssec_stateSize : Nat
dnssec_stateSize = 1

||| DnssecState sum type for ABI encoding.
public export
data DnssecState : Type where
  Disabled : DnssecState
  Enabled : DnssecState
  KeyLoaded : DnssecState
  Validated : DnssecState

||| Encode a DnssecState to its ABI tag value.
public export
dnssec_stateToTag : DnssecState -> Bits8
dnssec_stateToTag Disabled = 0
dnssec_stateToTag Enabled = 1
dnssec_stateToTag KeyLoaded = 2
dnssec_stateToTag Validated = 3

||| Decode an ABI tag to a DnssecState.
public export
tagToDnssecState : Bits8 -> Maybe DnssecState
tagToDnssecState 0 = Just Disabled
tagToDnssecState 1 = Just Enabled
tagToDnssecState 2 = Just KeyLoaded
tagToDnssecState 3 = Just Validated
tagToDnssecState _ = Nothing

||| Roundtrip proof: decoding an encoded DnssecState yields the original.
public export
dnssec_stateRoundtrip : (x : DnssecState) -> tagToDnssecState (dnssec_stateToTag x) = Just x
dnssec_stateRoundtrip Disabled = Refl
dnssec_stateRoundtrip Enabled = Refl
dnssec_stateRoundtrip KeyLoaded = Refl
dnssec_stateRoundtrip Validated = Refl

---------------------------------------------------------------------------
-- DnssecAlgorithm (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
dnssec_algorithmSize : Nat
dnssec_algorithmSize = 1

||| DnssecAlgorithm sum type for ABI encoding.
public export
data DnssecAlgorithm : Type where
  RsaSha256 : DnssecAlgorithm
  RsaSha512 : DnssecAlgorithm
  EcdsaP256Sha256 : DnssecAlgorithm
  EcdsaP384Sha384 : DnssecAlgorithm
  Ed25519 : DnssecAlgorithm

||| Encode a DnssecAlgorithm to its ABI tag value.
public export
dnssec_algorithmToTag : DnssecAlgorithm -> Bits8
dnssec_algorithmToTag RsaSha256 = 0
dnssec_algorithmToTag RsaSha512 = 1
dnssec_algorithmToTag EcdsaP256Sha256 = 2
dnssec_algorithmToTag EcdsaP384Sha384 = 3
dnssec_algorithmToTag Ed25519 = 4

||| Decode an ABI tag to a DnssecAlgorithm.
public export
tagToDnssecAlgorithm : Bits8 -> Maybe DnssecAlgorithm
tagToDnssecAlgorithm 0 = Just RsaSha256
tagToDnssecAlgorithm 1 = Just RsaSha512
tagToDnssecAlgorithm 2 = Just EcdsaP256Sha256
tagToDnssecAlgorithm 3 = Just EcdsaP384Sha384
tagToDnssecAlgorithm 4 = Just Ed25519
tagToDnssecAlgorithm _ = Nothing

||| Roundtrip proof: decoding an encoded DnssecAlgorithm yields the original.
public export
dnssec_algorithmRoundtrip : (x : DnssecAlgorithm) -> tagToDnssecAlgorithm (dnssec_algorithmToTag x) = Just x
dnssec_algorithmRoundtrip RsaSha256 = Refl
dnssec_algorithmRoundtrip RsaSha512 = Refl
dnssec_algorithmRoundtrip EcdsaP256Sha256 = Refl
dnssec_algorithmRoundtrip EcdsaP384Sha384 = Refl
dnssec_algorithmRoundtrip Ed25519 = Refl
