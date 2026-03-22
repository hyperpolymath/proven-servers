// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VPN protocol types for proven-servers.

/// TunnelType matching the Idris2 ABI tags.
public enum TunnelType: UInt8, CaseIterable, Sendable {
    case ipsec = 0
    case wireguard = 1
    case openvpn = 2
    case l2tp = 3
}

/// TunnelPhase matching the Idris2 ABI tags.
public enum TunnelPhase: UInt8, CaseIterable, Sendable {
    case idle = 0
    case phase1Init = 1
    case phase1Auth = 2
    case phase1Done = 3
    case phase2Negotiating = 4
    case established = 5
    case tunnelPhase_Expired = 6
}

/// EncryptionAlgorithm matching the Idris2 ABI tags.
public enum EncryptionAlgorithm: UInt8, CaseIterable, Sendable {
    case aes128Cbc = 0
    case aes256Cbc = 1
    case aes128Gcm = 2
    case aes256Gcm = 3
    case chacha20Poly1305 = 4
    case nullCipher = 5
}

/// IntegrityAlgorithm matching the Idris2 ABI tags.
public enum IntegrityAlgorithm: UInt8, CaseIterable, Sendable {
    case hmacSha1 = 0
    case hmacSha256 = 1
    case hmacSha384 = 2
    case hmacSha512 = 3
    case noIntegrity = 4
}

/// DhGroup matching the Idris2 ABI tags.
public enum DhGroup: UInt8, CaseIterable, Sendable {
    case dh14 = 0
    case ecp256 = 1
    case ecp384 = 2
    case curve25519 = 3
}

/// SaLifecycle matching the Idris2 ABI tags.
public enum SaLifecycle: UInt8, CaseIterable, Sendable {
    case none = 0
    case active = 1
    case rekeying = 2
    case saLifecycle_Expired = 3
    case deleted = 4
}

/// IkeVersion matching the Idris2 ABI tags.
public enum IkeVersion: UInt8, CaseIterable, Sendable {
    case v1 = 0
    case v2 = 1
}

/// VpnError matching the Idris2 ABI tags.
public enum VpnError: UInt8, CaseIterable, Sendable {
    case authenticationFailed = 0
    case noProposalChosen = 1
    case lifetimeExpired = 2
    case invalidSpi = 3
    case replayDetected = 4
    case negotiationTimeout = 5
}
