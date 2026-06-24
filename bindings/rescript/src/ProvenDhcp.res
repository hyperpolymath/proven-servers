// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DHCP protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module DhcpABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard DHCP server port (RFC 2131).
let dhcpServerPort = 67

/// Standard DHCP client port (RFC 2131).
let dhcpClientPort = 68

// ===========================================================================
// MessageType (tags 0-7)
// ===========================================================================

/// Standard DHCP server port (RFC 2131).
type messageType =
  | @as(0) Discover
  | @as(1) Offer
  | @as(2) Request
  | @as(3) Ack
  | @as(4) Nak
  | @as(5) Release
  | @as(6) Inform
  | @as(7) Decline

/// Decode from the C-ABI tag value.
let messageTypeFromTag = (tag: int): option<messageType> =>
  switch tag {
  | 0 => Some(Discover)
  | 1 => Some(Offer)
  | 2 => Some(Request)
  | 3 => Some(Ack)
  | 4 => Some(Nak)
  | 5 => Some(Release)
  | 6 => Some(Inform)
  | 7 => Some(Decline)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let messageTypeToTag = (v: messageType): int =>
  switch v {
  | Discover => 0
  | Offer => 1
  | Request => 2
  | Ack => 3
  | Nak => 4
  | Release => 5
  | Inform => 6
  | Decline => 7
  }

/// Whether this message is sent by a client.
let messageTypeIsClientMessage = (v: messageType): bool =>
  switch v {
  | Discover | Request | Release | Inform | Decline => true
  | _ => false
  }

/// Whether this message is sent by a server.
let messageTypeIsServerMessage = (v: messageType): bool =>
  switch v {
  | Offer | Ack | Nak => true
  | _ => false
  }

// ===========================================================================
// OptionCode (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type optionCode =
  | @as(0) SubnetMask
  | @as(1) Router
  | @as(2) Dns
  | @as(3) DomainName
  | @as(4) LeaseTime
  | @as(5) ServerId
  | @as(6) RequestedIp
  | @as(7) MsgType

/// Decode from the C-ABI tag value.
let optionCodeFromTag = (tag: int): option<optionCode> =>
  switch tag {
  | 0 => Some(SubnetMask)
  | 1 => Some(Router)
  | 2 => Some(Dns)
  | 3 => Some(DomainName)
  | 4 => Some(LeaseTime)
  | 5 => Some(ServerId)
  | 6 => Some(RequestedIp)
  | 7 => Some(MsgType)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let optionCodeToTag = (v: optionCode): int =>
  switch v {
  | SubnetMask => 0
  | Router => 1
  | Dns => 2
  | DomainName => 3
  | LeaseTime => 4
  | ServerId => 5
  | RequestedIp => 6
  | MsgType => 7
  }

// ===========================================================================
// HardwareType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type hardwareType =
  | @as(0) Ethernet
  | @as(1) Ieee802
  | @as(2) Arcnet
  | @as(3) FrameRelay

/// Decode from the C-ABI tag value.
let hardwareTypeFromTag = (tag: int): option<hardwareType> =>
  switch tag {
  | 0 => Some(Ethernet)
  | 1 => Some(Ieee802)
  | 2 => Some(Arcnet)
  | 3 => Some(FrameRelay)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let hardwareTypeToTag = (v: hardwareType): int =>
  switch v {
  | Ethernet => 0
  | Ieee802 => 1
  | Arcnet => 2
  | FrameRelay => 3
  }

// ===========================================================================
// DhcpState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type dhcpState =
  | @as(0) Idle
  | @as(1) DiscoverReceived
  | @as(2) OfferSent
  | @as(3) RequestReceived
  | @as(4) AckSent
  | @as(5) NakSent

/// Decode from the C-ABI tag value.
let dhcpStateFromTag = (tag: int): option<dhcpState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(DiscoverReceived)
  | 2 => Some(OfferSent)
  | 3 => Some(RequestReceived)
  | 4 => Some(AckSent)
  | 5 => Some(NakSent)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let dhcpStateToTag = (v: dhcpState): int =>
  switch v {
  | Idle => 0
  | DiscoverReceived => 1
  | OfferSent => 2
  | RequestReceived => 3
  | AckSent => 4
  | NakSent => 5
  }

// dhcpStateCanTransitionTo removed: unproven reimplementation. The verified check lives in the
// Idris2/Zig core; calling it needs @module FFI wiring not yet present for this
// protocol. Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

// ===========================================================================
// LeaseState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type leaseState =
  | @as(0) Available
  | @as(1) Offered
  | @as(2) Bound
  | @as(3) Renewing
  | @as(4) Rebinding
  | @as(5) Expired

/// Decode from the C-ABI tag value.
let leaseStateFromTag = (tag: int): option<leaseState> =>
  switch tag {
  | 0 => Some(Available)
  | 1 => Some(Offered)
  | 2 => Some(Bound)
  | 3 => Some(Renewing)
  | 4 => Some(Rebinding)
  | 5 => Some(Expired)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let leaseStateToTag = (v: leaseState): int =>
  switch v {
  | Available => 0
  | Offered => 1
  | Bound => 2
  | Renewing => 3
  | Rebinding => 4
  | Expired => 5
  }

/// Whether this state means the address is in use.
let leaseStateIsActive = (v: leaseState): bool =>
  switch v {
  | Bound | Renewing | Rebinding => true
  | _ => false
  }

// ===========================================================================
// RelaySubOption (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type relaySubOption =
  | @as(0) CircuitId
  | @as(1) RemoteId

/// Decode from the C-ABI tag value.
let relaySubOptionFromTag = (tag: int): option<relaySubOption> =>
  switch tag {
  | 0 => Some(CircuitId)
  | 1 => Some(RemoteId)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let relaySubOptionToTag = (v: relaySubOption): int =>
  switch v {
  | CircuitId => 0
  | RemoteId => 1
  }

