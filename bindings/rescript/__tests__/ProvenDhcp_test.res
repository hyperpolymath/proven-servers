// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenDhcp protocol bindings.

open ProvenDhcp

let test_messageType_roundtrip = () => {
  assert(messageTypeFromTag(0) == Some(Discover))
  assert(messageTypeFromTag(1) == Some(Offer))
  assert(messageTypeFromTag(2) == Some(Request))
  assert(messageTypeFromTag(3) == Some(Ack))
  assert(messageTypeFromTag(4) == Some(Nak))
  assert(messageTypeFromTag(5) == Some(Release))
  assert(messageTypeFromTag(6) == Some(Inform))
  assert(messageTypeFromTag(7) == Some(Decline))
  assert(messageTypeFromTag(8) == None)
}

let test_messageType_toTag = () => {
  assert(messageTypeToTag(Discover) == 0)
  assert(messageTypeToTag(Offer) == 1)
  assert(messageTypeToTag(Request) == 2)
  assert(messageTypeToTag(Ack) == 3)
  assert(messageTypeToTag(Nak) == 4)
  assert(messageTypeToTag(Release) == 5)
  assert(messageTypeToTag(Inform) == 6)
  assert(messageTypeToTag(Decline) == 7)
}

let test_optionCode_roundtrip = () => {
  assert(optionCodeFromTag(0) == Some(SubnetMask))
  assert(optionCodeFromTag(1) == Some(Router))
  assert(optionCodeFromTag(2) == Some(Dns))
  assert(optionCodeFromTag(3) == Some(DomainName))
  assert(optionCodeFromTag(4) == Some(LeaseTime))
  assert(optionCodeFromTag(5) == Some(ServerId))
  assert(optionCodeFromTag(6) == Some(RequestedIp))
  assert(optionCodeFromTag(7) == Some(MsgType))
  assert(optionCodeFromTag(8) == None)
}

let test_optionCode_toTag = () => {
  assert(optionCodeToTag(SubnetMask) == 0)
  assert(optionCodeToTag(Router) == 1)
  assert(optionCodeToTag(Dns) == 2)
  assert(optionCodeToTag(DomainName) == 3)
  assert(optionCodeToTag(LeaseTime) == 4)
  assert(optionCodeToTag(ServerId) == 5)
  assert(optionCodeToTag(RequestedIp) == 6)
  assert(optionCodeToTag(MsgType) == 7)
}

let test_hardwareType_roundtrip = () => {
  assert(hardwareTypeFromTag(0) == Some(Ethernet))
  assert(hardwareTypeFromTag(1) == Some(Ieee802))
  assert(hardwareTypeFromTag(2) == Some(Arcnet))
  assert(hardwareTypeFromTag(3) == Some(FrameRelay))
  assert(hardwareTypeFromTag(4) == None)
}

let test_hardwareType_toTag = () => {
  assert(hardwareTypeToTag(Ethernet) == 0)
  assert(hardwareTypeToTag(Ieee802) == 1)
  assert(hardwareTypeToTag(Arcnet) == 2)
  assert(hardwareTypeToTag(FrameRelay) == 3)
}

let test_dhcpState_roundtrip = () => {
  assert(dhcpStateFromTag(0) == Some(Idle))
  assert(dhcpStateFromTag(1) == Some(DiscoverReceived))
  assert(dhcpStateFromTag(2) == Some(OfferSent))
  assert(dhcpStateFromTag(3) == Some(RequestReceived))
  assert(dhcpStateFromTag(4) == Some(AckSent))
  assert(dhcpStateFromTag(5) == Some(NakSent))
  assert(dhcpStateFromTag(6) == None)
}

let test_dhcpState_toTag = () => {
  assert(dhcpStateToTag(Idle) == 0)
  assert(dhcpStateToTag(DiscoverReceived) == 1)
  assert(dhcpStateToTag(OfferSent) == 2)
  assert(dhcpStateToTag(RequestReceived) == 3)
  assert(dhcpStateToTag(AckSent) == 4)
  assert(dhcpStateToTag(NakSent) == 5)
}

let test_leaseState_roundtrip = () => {
  assert(leaseStateFromTag(0) == Some(Available))
  assert(leaseStateFromTag(1) == Some(Offered))
  assert(leaseStateFromTag(2) == Some(Bound))
  assert(leaseStateFromTag(3) == Some(Renewing))
  assert(leaseStateFromTag(4) == Some(Rebinding))
  assert(leaseStateFromTag(5) == Some(Expired))
  assert(leaseStateFromTag(6) == None)
}

let test_leaseState_toTag = () => {
  assert(leaseStateToTag(Available) == 0)
  assert(leaseStateToTag(Offered) == 1)
  assert(leaseStateToTag(Bound) == 2)
  assert(leaseStateToTag(Renewing) == 3)
  assert(leaseStateToTag(Rebinding) == 4)
  assert(leaseStateToTag(Expired) == 5)
}

let test_relaySubOption_roundtrip = () => {
  assert(relaySubOptionFromTag(0) == Some(CircuitId))
  assert(relaySubOptionFromTag(1) == Some(RemoteId))
  assert(relaySubOptionFromTag(2) == None)
}

let test_relaySubOption_toTag = () => {
  assert(relaySubOptionToTag(CircuitId) == 0)
  assert(relaySubOptionToTag(RemoteId) == 1)
}

// Run all tests
test_messageType_roundtrip()
test_messageType_toTag()
test_optionCode_roundtrip()
test_optionCode_toTag()
test_hardwareType_roundtrip()
test_hardwareType_toTag()
test_dhcpState_roundtrip()
test_dhcpState_toTag()
test_leaseState_roundtrip()
test_leaseState_toTag()
test_relaySubOption_roundtrip()
test_relaySubOption_toTag()
