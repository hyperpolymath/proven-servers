// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DHCP protocol types for proven-servers.

/// MessageType matching the Idris2 ABI tags.
public enum MessageType: UInt8, CaseIterable, Sendable {
    case discover = 0
    case offer = 1
    case request = 2
    case ack = 3
    case nak = 4
    case release = 5
    case inform = 6
    case decline = 7
}

/// OptionCode matching the Idris2 ABI tags.
public enum OptionCode: UInt8, CaseIterable, Sendable {
    case subnetMask = 0
    case router = 1
    case dns = 2
    case domainName = 3
    case leaseTime = 4
    case serverId = 5
    case requestedIp = 6
    case msgType = 7
}

/// HardwareType matching the Idris2 ABI tags.
public enum HardwareType: UInt8, CaseIterable, Sendable {
    case ethernet = 0
    case ieee802 = 1
    case arcnet = 2
    case frameRelay = 3
}

/// DhcpState matching the Idris2 ABI tags.
public enum DhcpState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case discoverReceived = 1
    case offerSent = 2
    case requestReceived = 3
    case ackSent = 4
    case nakSent = 5
}

/// LeaseState matching the Idris2 ABI tags.
public enum LeaseState: UInt8, CaseIterable, Sendable {
    case available = 0
    case offered = 1
    case bound = 2
    case renewing = 3
    case rebinding = 4
    case expired = 5
}

/// RelaySubOption matching the Idris2 ABI tags.
public enum RelaySubOption: UInt8, CaseIterable, Sendable {
    case circuitId = 0
    case remoteId = 1
}
