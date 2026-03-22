// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VPN protocol types for proven-servers.

namespace Proven;

/// <summary>TunnelType matching the Idris2 ABI tags (0-3).</summary>
public enum TunnelType : byte
{
    Ipsec = 0,
    Wireguard = 1,
    Openvpn = 2,
    L2tp = 3
}

/// <summary>TunnelPhase matching the Idris2 ABI tags (0-6).</summary>
public enum TunnelPhase : byte
{
    Idle = 0,
    Phase1Init = 1,
    Phase1Auth = 2,
    Phase1Done = 3,
    Phase2Negotiating = 4,
    Established = 5,
    Expired = 6
}

/// <summary>EncryptionAlgorithm matching the Idris2 ABI tags (0-5).</summary>
public enum EncryptionAlgorithm : byte
{
    Aes128Cbc = 0,
    Aes256Cbc = 1,
    Aes128Gcm = 2,
    Aes256Gcm = 3,
    Chacha20Poly1305 = 4,
    NullCipher = 5
}

/// <summary>IntegrityAlgorithm matching the Idris2 ABI tags (0-4).</summary>
public enum IntegrityAlgorithm : byte
{
    HmacSha1 = 0,
    HmacSha256 = 1,
    HmacSha384 = 2,
    HmacSha512 = 3,
    NoIntegrity = 4
}

/// <summary>DhGroup matching the Idris2 ABI tags (0-3).</summary>
public enum DhGroup : byte
{
    Dh14 = 0,
    Ecp256 = 1,
    Ecp384 = 2,
    Curve25519 = 3
}

/// <summary>SaLifecycle matching the Idris2 ABI tags (0-4).</summary>
public enum SaLifecycle : byte
{
    None = 0,
    Active = 1,
    Rekeying = 2,
    Expired = 3,
    Deleted = 4
}

/// <summary>IkeVersion matching the Idris2 ABI tags (0-1).</summary>
public enum IkeVersion : byte
{
    V1 = 0,
    V2 = 1
}

/// <summary>VpnError matching the Idris2 ABI tags (0-5).</summary>
public enum VpnError : byte
{
    AuthenticationFailed = 0,
    NoProposalChosen = 1,
    LifetimeExpired = 2,
    InvalidSpi = 3,
    ReplayDetected = 4,
    NegotiationTimeout = 5
}
