-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GrooveProxyABI.Layout: C-ABI-compatible tag encodings with roundtrip proofs.
--
-- Maps every constructor of the proxy's sum types to fixed Bits8 values
-- for C interop. Each type gets:
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving encoding then decoding is identity
--
-- Tag values MUST match generated/abi/groove_proxy.h and ffi/zig/src/groove_proxy.zig.

module GrooveProxyABI.Layout

import GrooveProxy.Types

%default total

---------------------------------------------------------------------------
-- AddrFamily (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
addrFamilySize : Nat
addrFamilySize = 1

public export
addrFamilyToTag : AddrFamily -> Bits8
addrFamilyToTag IPv4 = 0
addrFamilyToTag IPv6 = 1

public export
tagToAddrFamily : Bits8 -> Maybe AddrFamily
tagToAddrFamily 0 = Just IPv4
tagToAddrFamily 1 = Just IPv6
tagToAddrFamily _ = Nothing

public export
addrFamilyRoundtrip : (f : AddrFamily) -> tagToAddrFamily (addrFamilyToTag f) = Just f
addrFamilyRoundtrip IPv4 = Refl
addrFamilyRoundtrip IPv6 = Refl

---------------------------------------------------------------------------
-- SpliceMode (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
spliceModeSize : Nat
spliceModeSize = 1

public export
spliceModeToTag : SpliceMode -> Bits8
spliceModeToTag KernelSplice  = 0
spliceModeToTag UserspaceCopy = 1

public export
tagToSpliceMode : Bits8 -> Maybe SpliceMode
tagToSpliceMode 0 = Just KernelSplice
tagToSpliceMode 1 = Just UserspaceCopy
tagToSpliceMode _ = Nothing

public export
spliceModeRoundtrip : (m : SpliceMode) -> tagToSpliceMode (spliceModeToTag m) = Just m
spliceModeRoundtrip KernelSplice  = Refl
spliceModeRoundtrip UserspaceCopy = Refl

---------------------------------------------------------------------------
-- ProxyState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
proxyStateSize : Nat
proxyStateSize = 1

public export
proxyStateToTag : ProxyState -> Bits8
proxyStateToTag Idle      = 0
proxyStateToTag Accepted  = 1
proxyStateToTag Connected = 2
proxyStateToTag Splicing  = 3
proxyStateToTag Draining  = 4
proxyStateToTag Closed    = 5

public export
tagToProxyState : Bits8 -> Maybe ProxyState
tagToProxyState 0 = Just Idle
tagToProxyState 1 = Just Accepted
tagToProxyState 2 = Just Connected
tagToProxyState 3 = Just Splicing
tagToProxyState 4 = Just Draining
tagToProxyState 5 = Just Closed
tagToProxyState _ = Nothing

public export
proxyStateRoundtrip : (s : ProxyState) -> tagToProxyState (proxyStateToTag s) = Just s
proxyStateRoundtrip Idle      = Refl
proxyStateRoundtrip Accepted  = Refl
proxyStateRoundtrip Connected = Refl
proxyStateRoundtrip Splicing  = Refl
proxyStateRoundtrip Draining  = Refl
proxyStateRoundtrip Closed    = Refl
