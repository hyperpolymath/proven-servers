//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// DHCP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `DhcpABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// DHCP Constants
// ===========================================================================

/// Dhcp Server Port constant.
pub const dhcp_server_port = 67

/// Dhcp Client Port constant.
pub const dhcp_client_port = 68

// ===========================================================================
// MessageType
// ===========================================================================

/// DHCP message types (RFC 2131 Section 3.1).
/// 
/// Matches `MessageType` in `DhcpABI.Types`.
pub type MessageType {
  /// DHCPDISCOVER — client broadcasts to find servers (tag 0).
  Discover
  /// DHCPOFFER — server response with address offer (tag 1).
  Offer
  /// DHCPREQUEST — client requests offered address (tag 2).
  Request
  /// DHCPACK — server confirms address assignment (tag 3).
  Ack
  /// DHCPNAK — server rejects request (tag 4).
  Nak
  /// DHCPRELEASE — client releases address (tag 5).
  Release
  /// DHCPINFORM — client requests config without address (tag 6).
  Inform
  /// DHCPDECLINE — client rejects offered address (tag 7).
  Decline
}

/// Convert a `MessageType` to its C-ABI tag value.
pub fn message_type_to_int(value: MessageType) -> Int {
  case value {
    Discover -> 0
    Offer -> 1
    Request -> 2
    Ack -> 3
    Nak -> 4
    Release -> 5
    Inform -> 6
    Decline -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn message_type_from_int(tag: Int) -> Result(MessageType, Nil) {
  case tag {
    0 -> Ok(Discover)
    1 -> Ok(Offer)
    2 -> Ok(Request)
    3 -> Ok(Ack)
    4 -> Ok(Nak)
    5 -> Ok(Release)
    6 -> Ok(Inform)
    7 -> Ok(Decline)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// OptionCode
// ===========================================================================

/// DHCP option codes (RFC 2132).
/// 
/// Matches `OptionCode` in `DhcpABI.Types`.
pub type OptionCode {
  /// Subnet Mask (option 1) (tag 0).
  SubnetMask
  /// Router (option 3) (tag 1).
  Router
  /// DNS Server (option 6) (tag 2).
  Dns
  /// Domain Name (option 15) (tag 3).
  DomainName
  /// IP Address Lease Time (option 51) (tag 4).
  LeaseTime
  /// Server Identifier (option 54) (tag 5).
  ServerId
  /// Requested IP Address (option 50) (tag 6).
  RequestedIp
  /// DHCP Message Type (option 53) (tag 7).
  MsgType
}

/// Convert a `OptionCode` to its C-ABI tag value.
pub fn option_code_to_int(value: OptionCode) -> Int {
  case value {
    SubnetMask -> 0
    Router -> 1
    Dns -> 2
    DomainName -> 3
    LeaseTime -> 4
    ServerId -> 5
    RequestedIp -> 6
    MsgType -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn option_code_from_int(tag: Int) -> Result(OptionCode, Nil) {
  case tag {
    0 -> Ok(SubnetMask)
    1 -> Ok(Router)
    2 -> Ok(Dns)
    3 -> Ok(DomainName)
    4 -> Ok(LeaseTime)
    5 -> Ok(ServerId)
    6 -> Ok(RequestedIp)
    7 -> Ok(MsgType)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HardwareType
// ===========================================================================

/// Hardware address types (RFC 1700).
/// 
/// Matches `HardwareType` in `DhcpABI.Types`.
pub type HardwareType {
  /// Ethernet (10Mb) (tag 0).
  Ethernet
  /// IEEE 802 Networks (tag 1).
  Ieee802
  /// ARCNET (tag 2).
  Arcnet
  /// Frame Relay (tag 3).
  FrameRelay
}

/// Convert a `HardwareType` to its C-ABI tag value.
pub fn hardware_type_to_int(value: HardwareType) -> Int {
  case value {
    Ethernet -> 0
    Ieee802 -> 1
    Arcnet -> 2
    FrameRelay -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn hardware_type_from_int(tag: Int) -> Result(HardwareType, Nil) {
  case tag {
    0 -> Ok(Ethernet)
    1 -> Ok(Ieee802)
    2 -> Ok(Arcnet)
    3 -> Ok(FrameRelay)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DhcpState
// ===========================================================================

/// DHCP server state machine.
/// 
/// Matches `DhcpState` in `DhcpABI.Types`.
pub type DhcpState {
  /// Idle — awaiting DHCPDISCOVER (tag 0).
  Idle
  /// DHCPDISCOVER received (tag 1).
  DiscoverReceived
  /// DHCPOFFER sent (tag 2).
  OfferSent
  /// DHCPREQUEST received (tag 3).
  RequestReceived
  /// DHCPACK sent (tag 4).
  AckSent
  /// DHCPNAK sent (tag 5).
  NakSent
}

/// Convert a `DhcpState` to its C-ABI tag value.
pub fn dhcp_state_to_int(value: DhcpState) -> Int {
  case value {
    Idle -> 0
    DiscoverReceived -> 1
    OfferSent -> 2
    RequestReceived -> 3
    AckSent -> 4
    NakSent -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn dhcp_state_from_int(tag: Int) -> Result(DhcpState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(DiscoverReceived)
    2 -> Ok(OfferSent)
    3 -> Ok(RequestReceived)
    4 -> Ok(AckSent)
    5 -> Ok(NakSent)
    _ -> Error(Nil)
  }
}

/// Validate whether a state transition is allowed.
pub fn dhcp_state_can_transition_to(from: DhcpState, to: DhcpState) -> Bool {
  case from, to {
    Idle, DiscoverReceived -> True
    DiscoverReceived, OfferSent -> True
    OfferSent, RequestReceived -> True
    RequestReceived, AckSent -> True
    RequestReceived, NakSent -> True
    AckSent, Idle -> True
    NakSent, Idle -> True
    _, _ -> False
  }
}

// ===========================================================================
// LeaseState
// ===========================================================================

/// DHCP lease lifecycle states.
/// 
/// Matches `LeaseState` in `DhcpABI.Types`.
pub type LeaseState {
  /// Available in pool (tag 0).
  Available
  /// Offered to a client (tag 1).
  Offered
  /// Bound — client actively using (tag 2).
  Bound
  /// Renewing — client requesting lease extension (tag 3).
  Renewing
  /// Rebinding — broadcast renewal attempt (tag 4).
  Rebinding
  /// Expired — lease no longer valid (tag 5).
  Expired
}

/// Convert a `LeaseState` to its C-ABI tag value.
pub fn lease_state_to_int(value: LeaseState) -> Int {
  case value {
    Available -> 0
    Offered -> 1
    Bound -> 2
    Renewing -> 3
    Rebinding -> 4
    Expired -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn lease_state_from_int(tag: Int) -> Result(LeaseState, Nil) {
  case tag {
    0 -> Ok(Available)
    1 -> Ok(Offered)
    2 -> Ok(Bound)
    3 -> Ok(Renewing)
    4 -> Ok(Rebinding)
    5 -> Ok(Expired)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// RelaySubOption
// ===========================================================================

/// DHCP relay agent sub-options (RFC 3046).
/// 
/// Matches `RelaySubOption` in `DhcpABI.Types`.
pub type RelaySubOption {
  /// Circuit ID — identifies the relay agent port (tag 0).
  CircuitId
  /// Remote ID — identifies the remote host (tag 1).
  RemoteId
}

/// Convert a `RelaySubOption` to its C-ABI tag value.
pub fn relay_sub_option_to_int(value: RelaySubOption) -> Int {
  case value {
    CircuitId -> 0
    RemoteId -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn relay_sub_option_from_int(tag: Int) -> Result(RelaySubOption, Nil) {
  case tag {
    0 -> Ok(CircuitId)
    1 -> Ok(RemoteId)
    _ -> Error(Nil)
  }
}

