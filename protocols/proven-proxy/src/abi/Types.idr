-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ProxyABI.Types: C-ABI-compatible numeric representations of Proxy types.
--
-- Maps every constructor of the Proxy domain types (ProxyMode, HopByHopHeader,
-- CacheDirective, ProxyError) to fixed Bits8 values for C interop.
-- Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/proxy.zig) exactly.

module ProxyABI.Types

import Proxy.Types

%default total

---------------------------------------------------------------------------
-- ProxyMode (2 constructors, tags 0-1)
---------------------------------------------------------------------------

||| C-ABI representation size for ProxyMode (1 byte).
public export
proxyModeSize : Nat
proxyModeSize = 1

||| Map ProxyMode to its C-ABI byte value.
|||
||| Tag assignments:
|||   Forward = 0
|||   Reverse = 1
public export
proxyModeToTag : ProxyMode -> Bits8
proxyModeToTag Forward = 0
proxyModeToTag Reverse = 1

||| Recover ProxyMode from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-1.
public export
tagToProxyMode : Bits8 -> Maybe ProxyMode
tagToProxyMode 0 = Just Forward
tagToProxyMode 1 = Just Reverse
tagToProxyMode _ = Nothing

||| Proof: encoding then decoding ProxyMode is the identity.
public export
proxyModeRoundtrip : (m : ProxyMode) -> tagToProxyMode (proxyModeToTag m) = Just m
proxyModeRoundtrip Forward = Refl
proxyModeRoundtrip Reverse = Refl

---------------------------------------------------------------------------
-- HopByHopHeader (8 constructors, tags 0-7)
---------------------------------------------------------------------------

||| C-ABI representation size for HopByHopHeader (1 byte).
public export
hopByHopHeaderSize : Nat
hopByHopHeaderSize = 1

||| Map HopByHopHeader to its C-ABI byte value.
|||
||| Tag assignments:
|||   Connection       = 0    KeepAlive        = 1    ProxyAuth  = 2
|||   ProxyAuthz       = 3    TE               = 4    Trailers   = 5
|||   TransferEncoding = 6    Upgrade          = 7
public export
hopByHopHeaderToTag : HopByHopHeader -> Bits8
hopByHopHeaderToTag Connection       = 0
hopByHopHeaderToTag KeepAlive        = 1
hopByHopHeaderToTag ProxyAuth        = 2
hopByHopHeaderToTag ProxyAuthz       = 3
hopByHopHeaderToTag TE               = 4
hopByHopHeaderToTag Trailers         = 5
hopByHopHeaderToTag TransferEncoding = 6
hopByHopHeaderToTag Upgrade          = 7

||| Recover HopByHopHeader from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-7.
public export
tagToHopByHopHeader : Bits8 -> Maybe HopByHopHeader
tagToHopByHopHeader 0 = Just Connection
tagToHopByHopHeader 1 = Just KeepAlive
tagToHopByHopHeader 2 = Just ProxyAuth
tagToHopByHopHeader 3 = Just ProxyAuthz
tagToHopByHopHeader 4 = Just TE
tagToHopByHopHeader 5 = Just Trailers
tagToHopByHopHeader 6 = Just TransferEncoding
tagToHopByHopHeader 7 = Just Upgrade
tagToHopByHopHeader _ = Nothing

||| Proof: encoding then decoding HopByHopHeader is the identity.
public export
hopByHopHeaderRoundtrip : (h : HopByHopHeader) -> tagToHopByHopHeader (hopByHopHeaderToTag h) = Just h
hopByHopHeaderRoundtrip Connection       = Refl
hopByHopHeaderRoundtrip KeepAlive        = Refl
hopByHopHeaderRoundtrip ProxyAuth        = Refl
hopByHopHeaderRoundtrip ProxyAuthz       = Refl
hopByHopHeaderRoundtrip TE               = Refl
hopByHopHeaderRoundtrip Trailers         = Refl
hopByHopHeaderRoundtrip TransferEncoding = Refl
hopByHopHeaderRoundtrip Upgrade          = Refl

---------------------------------------------------------------------------
-- CacheDirective (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for CacheDirective (1 byte).
public export
cacheDirectiveSize : Nat
cacheDirectiveSize = 1

||| Map CacheDirective to its C-ABI byte value.
|||
||| Tag assignments:
|||   NoCache        = 0    NoStore        = 1    MaxAge  = 2
|||   Public         = 3    Private        = 4    MustRevalidate = 5
public export
cacheDirectiveToTag : CacheDirective -> Bits8
cacheDirectiveToTag NoCache        = 0
cacheDirectiveToTag NoStore        = 1
cacheDirectiveToTag MaxAge         = 2
cacheDirectiveToTag Public         = 3
cacheDirectiveToTag Private        = 4
cacheDirectiveToTag MustRevalidate = 5

||| Recover CacheDirective from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-5.
public export
tagToCacheDirective : Bits8 -> Maybe CacheDirective
tagToCacheDirective 0 = Just NoCache
tagToCacheDirective 1 = Just NoStore
tagToCacheDirective 2 = Just MaxAge
tagToCacheDirective 3 = Just Public
tagToCacheDirective 4 = Just Private
tagToCacheDirective 5 = Just MustRevalidate
tagToCacheDirective _ = Nothing

||| Proof: encoding then decoding CacheDirective is the identity.
public export
cacheDirectiveRoundtrip : (d : CacheDirective) -> tagToCacheDirective (cacheDirectiveToTag d) = Just d
cacheDirectiveRoundtrip NoCache        = Refl
cacheDirectiveRoundtrip NoStore        = Refl
cacheDirectiveRoundtrip MaxAge         = Refl
cacheDirectiveRoundtrip Public         = Refl
cacheDirectiveRoundtrip Private        = Refl
cacheDirectiveRoundtrip MustRevalidate = Refl

---------------------------------------------------------------------------
-- ProxyError (4 constructors, tags 0-3) - domain errors from Types.idr
---------------------------------------------------------------------------

||| C-ABI representation size for ProxyError (1 byte).
public export
proxyErrorSize : Nat
proxyErrorSize = 1

||| Map ProxyError to its C-ABI byte value.
|||
||| Tag assignments:
|||   BadGateway      = 0
|||   GatewayTimeout  = 1
|||   UpstreamRefused = 2
|||   UpstreamTLS     = 3
public export
proxyErrorToTag : ProxyError -> Bits8
proxyErrorToTag BadGateway      = 0
proxyErrorToTag GatewayTimeout  = 1
proxyErrorToTag UpstreamRefused = 2
proxyErrorToTag UpstreamTLS     = 3

||| Recover ProxyError from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToProxyError : Bits8 -> Maybe ProxyError
tagToProxyError 0 = Just BadGateway
tagToProxyError 1 = Just GatewayTimeout
tagToProxyError 2 = Just UpstreamRefused
tagToProxyError 3 = Just UpstreamTLS
tagToProxyError _ = Nothing

||| Proof: encoding then decoding ProxyError is the identity.
public export
proxyErrorRoundtrip : (e : ProxyError) -> tagToProxyError (proxyErrorToTag e) = Just e
proxyErrorRoundtrip BadGateway      = Refl
proxyErrorRoundtrip GatewayTimeout  = Refl
proxyErrorRoundtrip UpstreamRefused = Refl
proxyErrorRoundtrip UpstreamTLS     = Refl

---------------------------------------------------------------------------
-- ProxyFFIError (6 constructors, tags 0-5) - FFI operation errors
---------------------------------------------------------------------------

||| Error codes for Proxy FFI operations.
public export
data ProxyFFIError : Type where
  ||| No error.
  PxOk               : ProxyFFIError
  ||| Invalid slot index.
  PxInvalidSlot      : ProxyFFIError
  ||| Connection not active.
  PxNotActive        : ProxyFFIError
  ||| Invalid upstream configuration.
  PxInvalidUpstream  : ProxyFFIError
  ||| Cache operation failed.
  PxCacheError       : ProxyFFIError
  ||| Hop-by-hop header violation.
  PxHeaderViolation  : ProxyFFIError

public export
Show ProxyFFIError where
  show PxOk               = "Ok"
  show PxInvalidSlot       = "InvalidSlot"
  show PxNotActive         = "NotActive"
  show PxInvalidUpstream   = "InvalidUpstream"
  show PxCacheError        = "CacheError"
  show PxHeaderViolation   = "HeaderViolation"

||| C-ABI representation size for ProxyFFIError (1 byte).
public export
proxyFFIErrorSize : Nat
proxyFFIErrorSize = 1

||| Map ProxyFFIError to its C-ABI byte value.
public export
proxyFFIErrorToTag : ProxyFFIError -> Bits8
proxyFFIErrorToTag PxOk               = 0
proxyFFIErrorToTag PxInvalidSlot      = 1
proxyFFIErrorToTag PxNotActive        = 2
proxyFFIErrorToTag PxInvalidUpstream  = 3
proxyFFIErrorToTag PxCacheError       = 4
proxyFFIErrorToTag PxHeaderViolation  = 5

||| Recover ProxyFFIError from its C-ABI byte value.
public export
tagToProxyFFIError : Bits8 -> Maybe ProxyFFIError
tagToProxyFFIError 0 = Just PxOk
tagToProxyFFIError 1 = Just PxInvalidSlot
tagToProxyFFIError 2 = Just PxNotActive
tagToProxyFFIError 3 = Just PxInvalidUpstream
tagToProxyFFIError 4 = Just PxCacheError
tagToProxyFFIError 5 = Just PxHeaderViolation
tagToProxyFFIError _ = Nothing

||| Proof: encoding then decoding ProxyFFIError is the identity.
public export
proxyFFIErrorRoundtrip : (e : ProxyFFIError) -> tagToProxyFFIError (proxyFFIErrorToTag e) = Just e
proxyFFIErrorRoundtrip PxOk               = Refl
proxyFFIErrorRoundtrip PxInvalidSlot      = Refl
proxyFFIErrorRoundtrip PxNotActive        = Refl
proxyFFIErrorRoundtrip PxInvalidUpstream  = Refl
proxyFFIErrorRoundtrip PxCacheError       = Refl
proxyFFIErrorRoundtrip PxHeaderViolation  = Refl
