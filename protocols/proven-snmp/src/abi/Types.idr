-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SNMPABI.Types: C-ABI-compatible numeric representations of SNMP types.
--
-- Maps every constructor of the core SNMP sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/snmp.h) and the
-- Zig FFI enums (ffi/zig/src/snmp.zig) exactly.
--
-- Types covered:
--   Version     (3 constructors, tags 0-2)
--   PDUType     (7 constructors, tags 0-6)
--   ErrorStatus (16 constructors, tags 0-15)

module SNMPABI.Types

import SNMP.Types

%default total

---------------------------------------------------------------------------
-- Version (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
versionSize : Nat
versionSize = 1

||| Encode a Version to its ABI tag value.
public export
versionToTag : Version -> Bits8
versionToTag V1  = 0
versionToTag V2c = 1
versionToTag V3  = 2

||| Decode an ABI tag to a Version.
public export
tagToVersion : Bits8 -> Maybe Version
tagToVersion 0 = Just V1
tagToVersion 1 = Just V2c
tagToVersion 2 = Just V3
tagToVersion _ = Nothing

||| Roundtrip proof: decoding an encoded Version yields the original.
public export
versionRoundtrip : (v : Version) -> tagToVersion (versionToTag v) = Just v
versionRoundtrip V1  = Refl
versionRoundtrip V2c = Refl
versionRoundtrip V3  = Refl

---------------------------------------------------------------------------
-- PDUType (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
pduTypeSize : Nat
pduTypeSize = 1

||| Encode a PDUType to its ABI tag value.
public export
pduTypeToTag : PDUType -> Bits8
pduTypeToTag GetRequest     = 0
pduTypeToTag GetNextRequest = 1
pduTypeToTag GetResponse    = 2
pduTypeToTag SetRequest     = 3
pduTypeToTag GetBulkRequest = 4
pduTypeToTag InformRequest  = 5
pduTypeToTag SNMPv2Trap     = 6

||| Decode an ABI tag to a PDUType.
public export
tagToPDUType : Bits8 -> Maybe PDUType
tagToPDUType 0 = Just GetRequest
tagToPDUType 1 = Just GetNextRequest
tagToPDUType 2 = Just GetResponse
tagToPDUType 3 = Just SetRequest
tagToPDUType 4 = Just GetBulkRequest
tagToPDUType 5 = Just InformRequest
tagToPDUType 6 = Just SNMPv2Trap
tagToPDUType _ = Nothing

||| Roundtrip proof: decoding an encoded PDUType yields the original.
public export
pduTypeRoundtrip : (p : PDUType) -> tagToPDUType (pduTypeToTag p) = Just p
pduTypeRoundtrip GetRequest     = Refl
pduTypeRoundtrip GetNextRequest = Refl
pduTypeRoundtrip GetResponse    = Refl
pduTypeRoundtrip SetRequest     = Refl
pduTypeRoundtrip GetBulkRequest = Refl
pduTypeRoundtrip InformRequest  = Refl
pduTypeRoundtrip SNMPv2Trap     = Refl

---------------------------------------------------------------------------
-- ErrorStatus (16 constructors, tags 0-15)
---------------------------------------------------------------------------

public export
errorStatusSize : Nat
errorStatusSize = 1

||| Encode an ErrorStatus to its ABI tag value.
public export
errorStatusToTag : ErrorStatus -> Bits8
errorStatusToTag NoError             = 0
errorStatusToTag TooBig              = 1
errorStatusToTag NoSuchName          = 2
errorStatusToTag BadValue            = 3
errorStatusToTag ReadOnly            = 4
errorStatusToTag GenErr              = 5
errorStatusToTag NoAccess            = 6
errorStatusToTag WrongType           = 7
errorStatusToTag WrongLength         = 8
errorStatusToTag WrongValue          = 9
errorStatusToTag NoCreation          = 10
errorStatusToTag InconsistentValue   = 11
errorStatusToTag ResourceUnavailable = 12
errorStatusToTag CommitFailed        = 13
errorStatusToTag UndoFailed          = 14
errorStatusToTag AuthorizationError  = 15

||| Decode an ABI tag to an ErrorStatus.
public export
tagToErrorStatus : Bits8 -> Maybe ErrorStatus
tagToErrorStatus 0  = Just NoError
tagToErrorStatus 1  = Just TooBig
tagToErrorStatus 2  = Just NoSuchName
tagToErrorStatus 3  = Just BadValue
tagToErrorStatus 4  = Just ReadOnly
tagToErrorStatus 5  = Just GenErr
tagToErrorStatus 6  = Just NoAccess
tagToErrorStatus 7  = Just WrongType
tagToErrorStatus 8  = Just WrongLength
tagToErrorStatus 9  = Just WrongValue
tagToErrorStatus 10 = Just NoCreation
tagToErrorStatus 11 = Just InconsistentValue
tagToErrorStatus 12 = Just ResourceUnavailable
tagToErrorStatus 13 = Just CommitFailed
tagToErrorStatus 14 = Just UndoFailed
tagToErrorStatus 15 = Just AuthorizationError
tagToErrorStatus _  = Nothing

||| Roundtrip proof: decoding an encoded ErrorStatus yields the original.
public export
errorStatusRoundtrip : (e : ErrorStatus) -> tagToErrorStatus (errorStatusToTag e) = Just e
errorStatusRoundtrip NoError             = Refl
errorStatusRoundtrip TooBig              = Refl
errorStatusRoundtrip NoSuchName          = Refl
errorStatusRoundtrip BadValue            = Refl
errorStatusRoundtrip ReadOnly            = Refl
errorStatusRoundtrip GenErr              = Refl
errorStatusRoundtrip NoAccess            = Refl
errorStatusRoundtrip WrongType           = Refl
errorStatusRoundtrip WrongLength         = Refl
errorStatusRoundtrip WrongValue          = Refl
errorStatusRoundtrip NoCreation          = Refl
errorStatusRoundtrip InconsistentValue   = Refl
errorStatusRoundtrip ResourceUnavailable = Refl
errorStatusRoundtrip CommitFailed        = Refl
errorStatusRoundtrip UndoFailed          = Refl
errorStatusRoundtrip AuthorizationError  = Refl
