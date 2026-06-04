-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DhcpABI.Types: C-ABI-compatible numeric representations of Dhcp types.
--
-- Maps every constructor of the core Dhcp sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/dhcp.zig) exactly.
--
-- Types covered:
--   MessageType               (8 constructors, tags 0-7)
--   OptionCode                (8 constructors, tags 0-7)
--   HardwareType              (4 constructors, tags 0-3)
--   DhcpState                 (6 constructors, tags 0-5)
--   LeaseState                (6 constructors, tags 0-5)
--   RelaySubOption            (2 constructors, tags 0-1)

module DhcpABI.Types

%default total

---------------------------------------------------------------------------
-- MessageType (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
message_typeSize : Nat
message_typeSize = 1

||| MessageType sum type for ABI encoding.
public export
data MessageType : Type where
  Discover : MessageType
  Offer : MessageType
  Request : MessageType
  Ack : MessageType
  Nak : MessageType
  Release : MessageType
  Inform : MessageType
  Decline : MessageType

||| Encode a MessageType to its ABI tag value.
public export
message_typeToTag : MessageType -> Bits8
message_typeToTag Discover = 0
message_typeToTag Offer = 1
message_typeToTag Request = 2
message_typeToTag Ack = 3
message_typeToTag Nak = 4
message_typeToTag Release = 5
message_typeToTag Inform = 6
message_typeToTag Decline = 7

||| Decode an ABI tag to a MessageType.
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

||| Roundtrip proof: decoding an encoded MessageType yields the original.
public export
message_typeRoundtrip : (x : MessageType) -> tagToMessageType (message_typeToTag x) = Just x
message_typeRoundtrip Discover = Refl
message_typeRoundtrip Offer = Refl
message_typeRoundtrip Request = Refl
message_typeRoundtrip Ack = Refl
message_typeRoundtrip Nak = Refl
message_typeRoundtrip Release = Refl
message_typeRoundtrip Inform = Refl
message_typeRoundtrip Decline = Refl

---------------------------------------------------------------------------
-- OptionCode (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
option_codeSize : Nat
option_codeSize = 1

||| OptionCode sum type for ABI encoding.
public export
data OptionCode : Type where
  SubnetMask : OptionCode
  Router : OptionCode
  Dns : OptionCode
  DomainName : OptionCode
  LeaseTime : OptionCode
  ServerId : OptionCode
  RequestedIp : OptionCode
  MsgType : OptionCode

||| Encode a OptionCode to its ABI tag value.
public export
option_codeToTag : OptionCode -> Bits8
option_codeToTag SubnetMask = 0
option_codeToTag Router = 1
option_codeToTag Dns = 2
option_codeToTag DomainName = 3
option_codeToTag LeaseTime = 4
option_codeToTag ServerId = 5
option_codeToTag RequestedIp = 6
option_codeToTag MsgType = 7

||| Decode an ABI tag to a OptionCode.
public export
tagToOptionCode : Bits8 -> Maybe OptionCode
tagToOptionCode 0 = Just SubnetMask
tagToOptionCode 1 = Just Router
tagToOptionCode 2 = Just Dns
tagToOptionCode 3 = Just DomainName
tagToOptionCode 4 = Just LeaseTime
tagToOptionCode 5 = Just ServerId
tagToOptionCode 6 = Just RequestedIp
tagToOptionCode 7 = Just MsgType
tagToOptionCode _ = Nothing

||| Roundtrip proof: decoding an encoded OptionCode yields the original.
public export
option_codeRoundtrip : (x : OptionCode) -> tagToOptionCode (option_codeToTag x) = Just x
option_codeRoundtrip SubnetMask = Refl
option_codeRoundtrip Router = Refl
option_codeRoundtrip Dns = Refl
option_codeRoundtrip DomainName = Refl
option_codeRoundtrip LeaseTime = Refl
option_codeRoundtrip ServerId = Refl
option_codeRoundtrip RequestedIp = Refl
option_codeRoundtrip MsgType = Refl

---------------------------------------------------------------------------
-- HardwareType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
hardware_typeSize : Nat
hardware_typeSize = 1

||| HardwareType sum type for ABI encoding.
public export
data HardwareType : Type where
  Ethernet : HardwareType
  Ieee802 : HardwareType
  Arcnet : HardwareType
  FrameRelay : HardwareType

||| Encode a HardwareType to its ABI tag value.
public export
hardware_typeToTag : HardwareType -> Bits8
hardware_typeToTag Ethernet = 0
hardware_typeToTag Ieee802 = 1
hardware_typeToTag Arcnet = 2
hardware_typeToTag FrameRelay = 3

||| Decode an ABI tag to a HardwareType.
public export
tagToHardwareType : Bits8 -> Maybe HardwareType
tagToHardwareType 0 = Just Ethernet
tagToHardwareType 1 = Just Ieee802
tagToHardwareType 2 = Just Arcnet
tagToHardwareType 3 = Just FrameRelay
tagToHardwareType _ = Nothing

||| Roundtrip proof: decoding an encoded HardwareType yields the original.
public export
hardware_typeRoundtrip : (x : HardwareType) -> tagToHardwareType (hardware_typeToTag x) = Just x
hardware_typeRoundtrip Ethernet = Refl
hardware_typeRoundtrip Ieee802 = Refl
hardware_typeRoundtrip Arcnet = Refl
hardware_typeRoundtrip FrameRelay = Refl

---------------------------------------------------------------------------
-- DhcpState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
dhcp_stateSize : Nat
dhcp_stateSize = 1

||| DhcpState sum type for ABI encoding.
public export
data DhcpState : Type where
  Idle : DhcpState
  DiscoverReceived : DhcpState
  OfferSent : DhcpState
  RequestReceived : DhcpState
  AckSent : DhcpState
  NakSent : DhcpState

||| Encode a DhcpState to its ABI tag value.
public export
dhcp_stateToTag : DhcpState -> Bits8
dhcp_stateToTag Idle = 0
dhcp_stateToTag DiscoverReceived = 1
dhcp_stateToTag OfferSent = 2
dhcp_stateToTag RequestReceived = 3
dhcp_stateToTag AckSent = 4
dhcp_stateToTag NakSent = 5

||| Decode an ABI tag to a DhcpState.
public export
tagToDhcpState : Bits8 -> Maybe DhcpState
tagToDhcpState 0 = Just Idle
tagToDhcpState 1 = Just DiscoverReceived
tagToDhcpState 2 = Just OfferSent
tagToDhcpState 3 = Just RequestReceived
tagToDhcpState 4 = Just AckSent
tagToDhcpState 5 = Just NakSent
tagToDhcpState _ = Nothing

||| Roundtrip proof: decoding an encoded DhcpState yields the original.
public export
dhcp_stateRoundtrip : (x : DhcpState) -> tagToDhcpState (dhcp_stateToTag x) = Just x
dhcp_stateRoundtrip Idle = Refl
dhcp_stateRoundtrip DiscoverReceived = Refl
dhcp_stateRoundtrip OfferSent = Refl
dhcp_stateRoundtrip RequestReceived = Refl
dhcp_stateRoundtrip AckSent = Refl
dhcp_stateRoundtrip NakSent = Refl

---------------------------------------------------------------------------
-- LeaseState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
lease_stateSize : Nat
lease_stateSize = 1

||| LeaseState sum type for ABI encoding.
public export
data LeaseState : Type where
  Available : LeaseState
  Offered : LeaseState
  Bound : LeaseState
  Renewing : LeaseState
  Rebinding : LeaseState
  Expired : LeaseState

||| Encode a LeaseState to its ABI tag value.
public export
lease_stateToTag : LeaseState -> Bits8
lease_stateToTag Available = 0
lease_stateToTag Offered = 1
lease_stateToTag Bound = 2
lease_stateToTag Renewing = 3
lease_stateToTag Rebinding = 4
lease_stateToTag Expired = 5

||| Decode an ABI tag to a LeaseState.
public export
tagToLeaseState : Bits8 -> Maybe LeaseState
tagToLeaseState 0 = Just Available
tagToLeaseState 1 = Just Offered
tagToLeaseState 2 = Just Bound
tagToLeaseState 3 = Just Renewing
tagToLeaseState 4 = Just Rebinding
tagToLeaseState 5 = Just Expired
tagToLeaseState _ = Nothing

||| Roundtrip proof: decoding an encoded LeaseState yields the original.
public export
lease_stateRoundtrip : (x : LeaseState) -> tagToLeaseState (lease_stateToTag x) = Just x
lease_stateRoundtrip Available = Refl
lease_stateRoundtrip Offered = Refl
lease_stateRoundtrip Bound = Refl
lease_stateRoundtrip Renewing = Refl
lease_stateRoundtrip Rebinding = Refl
lease_stateRoundtrip Expired = Refl

---------------------------------------------------------------------------
-- RelaySubOption (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
relay_sub_optionSize : Nat
relay_sub_optionSize = 1

||| RelaySubOption sum type for ABI encoding.
public export
data RelaySubOption : Type where
  CircuitId : RelaySubOption
  RemoteId : RelaySubOption

||| Encode a RelaySubOption to its ABI tag value.
public export
relay_sub_optionToTag : RelaySubOption -> Bits8
relay_sub_optionToTag CircuitId = 0
relay_sub_optionToTag RemoteId = 1

||| Decode an ABI tag to a RelaySubOption.
public export
tagToRelaySubOption : Bits8 -> Maybe RelaySubOption
tagToRelaySubOption 0 = Just CircuitId
tagToRelaySubOption 1 = Just RemoteId
tagToRelaySubOption _ = Nothing

||| Roundtrip proof: decoding an encoded RelaySubOption yields the original.
public export
relay_sub_optionRoundtrip : (x : RelaySubOption) -> tagToRelaySubOption (relay_sub_optionToTag x) = Just x
relay_sub_optionRoundtrip CircuitId = Refl
relay_sub_optionRoundtrip RemoteId = Refl
