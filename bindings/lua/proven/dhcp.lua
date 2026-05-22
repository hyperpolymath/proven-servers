-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DHCP protocol types for proven-servers.

local M = {}

--- MessageType matching the Idris2 ABI tags.
M.MessageType = {
    DISCOVER = 0,
    OFFER = 1,
    REQUEST = 2,
    ACK = 3,
    NAK = 4,
    RELEASE = 5,
    INFORM = 6,
    DECLINE = 7,
}

--- OptionCode matching the Idris2 ABI tags.
M.OptionCode = {
    SUBNET_MASK = 0,
    ROUTER = 1,
    DNS = 2,
    DOMAIN_NAME = 3,
    LEASE_TIME = 4,
    SERVER_ID = 5,
    REQUESTED_IP = 6,
    MSG_TYPE = 7,
}

--- HardwareType matching the Idris2 ABI tags.
M.HardwareType = {
    ETHERNET = 0,
    IEEE802 = 1,
    ARCNET = 2,
    FRAME_RELAY = 3,
}

--- DhcpState matching the Idris2 ABI tags.
M.DhcpState = {
    IDLE = 0,
    DISCOVER_RECEIVED = 1,
    OFFER_SENT = 2,
    REQUEST_RECEIVED = 3,
    ACK_SENT = 4,
    NAK_SENT = 5,
}

--- LeaseState matching the Idris2 ABI tags.
M.LeaseState = {
    AVAILABLE = 0,
    OFFERED = 1,
    BOUND = 2,
    RENEWING = 3,
    REBINDING = 4,
    EXPIRED = 5,
}

--- RelaySubOption matching the Idris2 ABI tags.
M.RelaySubOption = {
    CIRCUIT_ID = 0,
    REMOTE_ID = 1,
}

return M
