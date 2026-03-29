-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DHCPABI.Layout: C-ABI-compatible numeric representations of DHCP types.
--
-- Maps every constructor of the DHCP sum types (MessageType, OptionCode,
-- HardwareType, LeaseState) to fixed Bits8 values for C interop.  Each
-- type gets a total encoder, partial decoder, and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/dhcp.h) and the
-- Zig FFI enums (ffi/zig/src/dhcp.zig) exactly.
--
-- MessageType uses sequential Bits8 tags (0-7) corresponding to the eight
-- DHCP message types from RFC 2131.  OptionCode uses tags (0-7) for the
-- eight most common DHCP options.  HardwareType uses tags (0-3).
-- LeaseState uses tags (0-5) for the six states of a DHCP lease.

module DHCPABI.Layout

import DHCP.Types

%default total

---------------------------------------------------------------------------
-- MessageType (8 constructors, tags 0-7)
--
-- RFC 2131 Section 3.1, option 53.  The DORA lifecycle:
--   Discover(0) -> Offer(1) -> Request(2) -> Ack(3)
-- Plus error/teardown messages:
--   Nak(4), Release(5), Inform(6), Decline(7)
---------------------------------------------------------------------------

||| ABI size of a MessageType tag in bytes.
public export
messageTypeSize : Nat
messageTypeSize = 1

||| Encode a MessageType as a Bits8 ABI tag.
public export
messageTypeToTag : MessageType -> Bits8
messageTypeToTag Discover = 0
messageTypeToTag Offer    = 1
messageTypeToTag Request  = 2
messageTypeToTag Ack      = 3
messageTypeToTag Nak      = 4
messageTypeToTag Release  = 5
messageTypeToTag Inform   = 6
messageTypeToTag Decline  = 7

||| Decode a Bits8 ABI tag to a MessageType, if valid.
public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0 = Just Discover
tagToMessageType 1 = Just Offer
tagToMessageType 2 = Just Request
tagToMessageType 3 = Just Ack
tagToMessageType 4 = Just Nak
tagToMessageType 5 = Just Release
tagToMessageType 6 = Just Inform
tagToMessageType 7 = Just Decline
tagToMessageType _ = Nothing

||| Roundtrip proof: decode(encode(m)) = Just m for all MessageType values.
public export
messageTypeRoundtrip : (m : MessageType) -> tagToMessageType (messageTypeToTag m) = Just m
messageTypeRoundtrip Discover = Refl
messageTypeRoundtrip Offer    = Refl
messageTypeRoundtrip Request  = Refl
messageTypeRoundtrip Ack      = Refl
messageTypeRoundtrip Nak      = Refl
messageTypeRoundtrip Release  = Refl
messageTypeRoundtrip Inform   = Refl
messageTypeRoundtrip Decline  = Refl

---------------------------------------------------------------------------
-- OptionCode (8 constructors, tags 0-7)
--
-- RFC 2132.  Common DHCP options used in server/client negotiation.
---------------------------------------------------------------------------

||| ABI size of an OptionCode tag in bytes.
public export
optionCodeSize : Nat
optionCodeSize = 1

||| Encode an OptionCode as a Bits8 ABI tag.
public export
optionCodeToTag : OptionCode -> Bits8
optionCodeToTag SubnetMask  = 0
optionCodeToTag Router      = 1
optionCodeToTag DNS         = 2
optionCodeToTag DomainName  = 3
optionCodeToTag LeaseTime   = 4
optionCodeToTag ServerID    = 5
optionCodeToTag RequestedIP = 6
optionCodeToTag MsgType     = 7

||| Decode a Bits8 ABI tag to an OptionCode, if valid.
public export
tagToOptionCode : Bits8 -> Maybe OptionCode
tagToOptionCode 0 = Just SubnetMask
tagToOptionCode 1 = Just Router
tagToOptionCode 2 = Just DNS
tagToOptionCode 3 = Just DomainName
tagToOptionCode 4 = Just LeaseTime
tagToOptionCode 5 = Just ServerID
tagToOptionCode 6 = Just RequestedIP
tagToOptionCode 7 = Just MsgType
tagToOptionCode _ = Nothing

||| Roundtrip proof: decode(encode(o)) = Just o for all OptionCode values.
public export
optionCodeRoundtrip : (o : OptionCode) -> tagToOptionCode (optionCodeToTag o) = Just o
optionCodeRoundtrip SubnetMask  = Refl
optionCodeRoundtrip Router      = Refl
optionCodeRoundtrip DNS         = Refl
optionCodeRoundtrip DomainName  = Refl
optionCodeRoundtrip LeaseTime   = Refl
optionCodeRoundtrip ServerID    = Refl
optionCodeRoundtrip RequestedIP = Refl
optionCodeRoundtrip MsgType     = Refl

---------------------------------------------------------------------------
-- OptionCode <-> RFC 2132 wire code mapping
--
-- ABI tags are sequential (0-7); wire codes are the actual DHCP option
-- numbers from RFC 2132.  The Zig FFI handles conversion.
---------------------------------------------------------------------------

||| Map an OptionCode ABI tag to its RFC 2132 wire code.
public export
optionCodeToWire : OptionCode -> Bits8
optionCodeToWire SubnetMask  = 1
optionCodeToWire Router      = 3
optionCodeToWire DNS         = 6
optionCodeToWire DomainName  = 15
optionCodeToWire LeaseTime   = 51
optionCodeToWire ServerID    = 54
optionCodeToWire RequestedIP = 50
optionCodeToWire MsgType     = 53

---------------------------------------------------------------------------
-- HardwareType (4 constructors, tags 0-3)
--
-- RFC 1700 / IANA hardware type identifiers for the htype field.
---------------------------------------------------------------------------

||| ABI size of a HardwareType tag in bytes.
public export
hardwareTypeSize : Nat
hardwareTypeSize = 1

||| Encode a HardwareType as a Bits8 ABI tag.
public export
hardwareTypeToTag : HardwareType -> Bits8
hardwareTypeToTag Ethernet   = 0
hardwareTypeToTag IEEE802    = 1
hardwareTypeToTag Arcnet     = 2
hardwareTypeToTag FrameRelay = 3

||| Decode a Bits8 ABI tag to a HardwareType, if valid.
public export
tagToHardwareType : Bits8 -> Maybe HardwareType
tagToHardwareType 0 = Just Ethernet
tagToHardwareType 1 = Just IEEE802
tagToHardwareType 2 = Just Arcnet
tagToHardwareType 3 = Just FrameRelay
tagToHardwareType _ = Nothing

||| Roundtrip proof: decode(encode(h)) = Just h for all HardwareType values.
public export
hardwareTypeRoundtrip : (h : HardwareType) -> tagToHardwareType (hardwareTypeToTag h) = Just h
hardwareTypeRoundtrip Ethernet   = Refl
hardwareTypeRoundtrip IEEE802    = Refl
hardwareTypeRoundtrip Arcnet     = Refl
hardwareTypeRoundtrip FrameRelay = Refl

---------------------------------------------------------------------------
-- HardwareType <-> IANA wire code mapping
---------------------------------------------------------------------------

||| Map a HardwareType ABI tag to its IANA wire code.
public export
hardwareTypeToWire : HardwareType -> Bits8
hardwareTypeToWire Ethernet   = 1
hardwareTypeToWire IEEE802    = 6
hardwareTypeToWire Arcnet     = 7
hardwareTypeToWire FrameRelay = 15

---------------------------------------------------------------------------
-- LeaseState (6 constructors, tags 0-5)
--
-- RFC 2131 Section 4.4 — DHCP lease lifecycle states.
-- A lease progresses: Available -> Offered -> Bound -> Renewing ->
-- Rebinding -> Expired (or back to Available on release).
---------------------------------------------------------------------------

||| DHCP lease lifecycle states.
public export
data LeaseState : Type where
  ||| Address is available for allocation.
  Available  : LeaseState
  ||| Address has been offered to a client (awaiting REQUEST).
  Offered    : LeaseState
  ||| Address is bound to a client with an active lease.
  Bound      : LeaseState
  ||| Client is attempting to renew the lease (T1 timer expired).
  Renewing   : LeaseState
  ||| Client is attempting to rebind (T2 timer expired, unicast failed).
  Rebinding  : LeaseState
  ||| Lease has expired; address may be reclaimed.
  Expired    : LeaseState

public export
Eq LeaseState where
  Available  == Available  = True
  Offered    == Offered    = True
  Bound      == Bound      = True
  Renewing   == Renewing   = True
  Rebinding  == Rebinding  = True
  Expired    == Expired    = True
  _          == _          = False

public export
Show LeaseState where
  show Available  = "Available"
  show Offered    = "Offered"
  show Bound      = "Bound"
  show Renewing   = "Renewing"
  show Rebinding  = "Rebinding"
  show Expired    = "Expired"

||| ABI size of a LeaseState tag in bytes.
public export
leaseStateSize : Nat
leaseStateSize = 1

||| Encode a LeaseState as a Bits8 ABI tag.
public export
leaseStateToTag : LeaseState -> Bits8
leaseStateToTag Available  = 0
leaseStateToTag Offered    = 1
leaseStateToTag Bound      = 2
leaseStateToTag Renewing   = 3
leaseStateToTag Rebinding  = 4
leaseStateToTag Expired    = 5

||| Decode a Bits8 ABI tag to a LeaseState, if valid.
public export
tagToLeaseState : Bits8 -> Maybe LeaseState
tagToLeaseState 0 = Just Available
tagToLeaseState 1 = Just Offered
tagToLeaseState 2 = Just Bound
tagToLeaseState 3 = Just Renewing
tagToLeaseState 4 = Just Rebinding
tagToLeaseState 5 = Just Expired
tagToLeaseState _ = Nothing

||| Roundtrip proof: decode(encode(s)) = Just s for all LeaseState values.
public export
leaseStateRoundtrip : (s : LeaseState) -> tagToLeaseState (leaseStateToTag s) = Just s
leaseStateRoundtrip Available  = Refl
leaseStateRoundtrip Offered    = Refl
leaseStateRoundtrip Bound      = Refl
leaseStateRoundtrip Renewing   = Refl
leaseStateRoundtrip Rebinding  = Refl
leaseStateRoundtrip Expired    = Refl
