// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DHCP protocol types for proven-servers.

/** MessageType matching the Idris2 ABI tags. */
export const MessageType = Object.freeze({
  DISCOVER: 0,
  OFFER: 1,
  REQUEST: 2,
  ACK: 3,
  NAK: 4,
  RELEASE: 5,
  INFORM: 6,
  DECLINE: 7,
});

/** OptionCode matching the Idris2 ABI tags. */
export const OptionCode = Object.freeze({
  SUBNET_MASK: 0,
  ROUTER: 1,
  DNS: 2,
  DOMAIN_NAME: 3,
  LEASE_TIME: 4,
  SERVER_ID: 5,
  REQUESTED_IP: 6,
  MSG_TYPE: 7,
});

/** HardwareType matching the Idris2 ABI tags. */
export const HardwareType = Object.freeze({
  ETHERNET: 0,
  IEEE802: 1,
  ARCNET: 2,
  FRAME_RELAY: 3,
});

/** DhcpState matching the Idris2 ABI tags. */
export const DhcpState = Object.freeze({
  IDLE: 0,
  DISCOVER_RECEIVED: 1,
  OFFER_SENT: 2,
  REQUEST_RECEIVED: 3,
  ACK_SENT: 4,
  NAK_SENT: 5,
});

/** LeaseState matching the Idris2 ABI tags. */
export const LeaseState = Object.freeze({
  AVAILABLE: 0,
  OFFERED: 1,
  BOUND: 2,
  RENEWING: 3,
  REBINDING: 4,
  EXPIRED: 5,
});

/** RelaySubOption matching the Idris2 ABI tags. */
export const RelaySubOption = Object.freeze({
  CIRCUIT_ID: 0,
  REMOTE_ID: 1,
});
