-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ResolverConnABI.Layout: C-ABI-compatible numeric representations of each type.
--
-- Maps every constructor of the five core sum types (RecordType, ResolverState,
-- DNSSECStatus, ResolverError, CachePolicy) to a fixed Bits8 value for C interop.
--
-- Tag values here MUST match the C header (generated/abi/resolverconn.h) and the
-- Zig FFI enums (ffi/zig/src/resolverconn.zig) exactly.

module ResolverConnABI.Layout

import ResolverConn.Types

%default total

---------------------------------------------------------------------------
-- RecordType (13 constructors, tags 0-12)
---------------------------------------------------------------------------

public export
recordTypeSize : Nat
recordTypeSize = 1

public export
recordTypeToTag : RecordType -> Bits8
recordTypeToTag A     = 0
recordTypeToTag AAAA  = 1
recordTypeToTag CNAME = 2
recordTypeToTag MX    = 3
recordTypeToTag TXT   = 4
recordTypeToTag SRV   = 5
recordTypeToTag NS    = 6
recordTypeToTag SOA   = 7
recordTypeToTag PTR   = 8
recordTypeToTag CAA   = 9
recordTypeToTag TLSA  = 10
recordTypeToTag SVCB  = 11
recordTypeToTag HTTPS = 12

public export
tagToRecordType : Bits8 -> Maybe RecordType
tagToRecordType 0  = Just A
tagToRecordType 1  = Just AAAA
tagToRecordType 2  = Just CNAME
tagToRecordType 3  = Just MX
tagToRecordType 4  = Just TXT
tagToRecordType 5  = Just SRV
tagToRecordType 6  = Just NS
tagToRecordType 7  = Just SOA
tagToRecordType 8  = Just PTR
tagToRecordType 9  = Just CAA
tagToRecordType 10 = Just TLSA
tagToRecordType 11 = Just SVCB
tagToRecordType 12 = Just HTTPS
tagToRecordType _  = Nothing

public export
recordTypeRoundtrip : (rt : RecordType) -> tagToRecordType (recordTypeToTag rt) = Just rt
recordTypeRoundtrip A     = Refl
recordTypeRoundtrip AAAA  = Refl
recordTypeRoundtrip CNAME = Refl
recordTypeRoundtrip MX    = Refl
recordTypeRoundtrip TXT   = Refl
recordTypeRoundtrip SRV   = Refl
recordTypeRoundtrip NS    = Refl
recordTypeRoundtrip SOA   = Refl
recordTypeRoundtrip PTR   = Refl
recordTypeRoundtrip CAA   = Refl
recordTypeRoundtrip TLSA  = Refl
recordTypeRoundtrip SVCB  = Refl
recordTypeRoundtrip HTTPS = Refl

---------------------------------------------------------------------------
-- ResolverState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
resolverStateSize : Nat
resolverStateSize = 1

public export
resolverStateToTag : ResolverState -> Bits8
resolverStateToTag Ready    = 0
resolverStateToTag Querying = 1
resolverStateToTag Cached   = 2
resolverStateToTag Failed   = 3

public export
tagToResolverState : Bits8 -> Maybe ResolverState
tagToResolverState 0 = Just Ready
tagToResolverState 1 = Just Querying
tagToResolverState 2 = Just Cached
tagToResolverState 3 = Just Failed
tagToResolverState _ = Nothing

public export
resolverStateRoundtrip : (s : ResolverState) -> tagToResolverState (resolverStateToTag s) = Just s
resolverStateRoundtrip Ready    = Refl
resolverStateRoundtrip Querying = Refl
resolverStateRoundtrip Cached   = Refl
resolverStateRoundtrip Failed   = Refl

---------------------------------------------------------------------------
-- DNSSECStatus (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
dnssecStatusSize : Nat
dnssecStatusSize = 1

public export
dnssecStatusToTag : DNSSECStatus -> Bits8
dnssecStatusToTag Secure        = 0
dnssecStatusToTag Insecure      = 1
dnssecStatusToTag Bogus         = 2
dnssecStatusToTag Indeterminate = 3

public export
tagToDNSSECStatus : Bits8 -> Maybe DNSSECStatus
tagToDNSSECStatus 0 = Just Secure
tagToDNSSECStatus 1 = Just Insecure
tagToDNSSECStatus 2 = Just Bogus
tagToDNSSECStatus 3 = Just Indeterminate
tagToDNSSECStatus _ = Nothing

public export
dnssecStatusRoundtrip : (ds : DNSSECStatus) -> tagToDNSSECStatus (dnssecStatusToTag ds) = Just ds
dnssecStatusRoundtrip Secure        = Refl
dnssecStatusRoundtrip Insecure      = Refl
dnssecStatusRoundtrip Bogus         = Refl
dnssecStatusRoundtrip Indeterminate = Refl

---------------------------------------------------------------------------
-- ResolverError (7 constructors, tags 1-7; 0 = no error)
---------------------------------------------------------------------------

public export
resolverErrorSize : Nat
resolverErrorSize = 1

public export
resolverErrorToTag : ResolverError -> Bits8
resolverErrorToTag NXDOMAIN                = 1
resolverErrorToTag ServerFailure           = 2
resolverErrorToTag Refused                 = 3
resolverErrorToTag Timeout                 = 4
resolverErrorToTag DNSSECValidationFailed  = 5
resolverErrorToTag NetworkUnreachable      = 6
resolverErrorToTag TruncatedResponse       = 7

public export
tagToResolverError : Bits8 -> Maybe ResolverError
tagToResolverError 1 = Just NXDOMAIN
tagToResolverError 2 = Just ServerFailure
tagToResolverError 3 = Just Refused
tagToResolverError 4 = Just Timeout
tagToResolverError 5 = Just DNSSECValidationFailed
tagToResolverError 6 = Just NetworkUnreachable
tagToResolverError 7 = Just TruncatedResponse
tagToResolverError _ = Nothing

public export
resolverErrorRoundtrip : (e : ResolverError) -> tagToResolverError (resolverErrorToTag e) = Just e
resolverErrorRoundtrip NXDOMAIN                = Refl
resolverErrorRoundtrip ServerFailure           = Refl
resolverErrorRoundtrip Refused                 = Refl
resolverErrorRoundtrip Timeout                 = Refl
resolverErrorRoundtrip DNSSECValidationFailed  = Refl
resolverErrorRoundtrip NetworkUnreachable      = Refl
resolverErrorRoundtrip TruncatedResponse       = Refl

---------------------------------------------------------------------------
-- CachePolicy (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
cachePolicySize : Nat
cachePolicySize = 1

public export
cachePolicyToTag : CachePolicy -> Bits8
cachePolicyToTag UseCache     = 0
cachePolicyToTag BypassCache  = 1
cachePolicyToTag CacheOnly    = 2
cachePolicyToTag RefreshCache = 3

public export
tagToCachePolicy : Bits8 -> Maybe CachePolicy
tagToCachePolicy 0 = Just UseCache
tagToCachePolicy 1 = Just BypassCache
tagToCachePolicy 2 = Just CacheOnly
tagToCachePolicy 3 = Just RefreshCache
tagToCachePolicy _ = Nothing

public export
cachePolicyRoundtrip : (cp : CachePolicy) -> tagToCachePolicy (cachePolicyToTag cp) = Just cp
cachePolicyRoundtrip UseCache     = Refl
cachePolicyRoundtrip BypassCache  = Refl
cachePolicyRoundtrip CacheOnly    = Refl
cachePolicyRoundtrip RefreshCache = Refl
