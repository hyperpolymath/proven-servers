<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VPN protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** TunnelType matching the Idris2 ABI tags. */
enum TunnelType: int
{
    case Ipsec = 0;
    case Wireguard = 1;
    case Openvpn = 2;
    case L2tp = 3;
}

/** TunnelPhase matching the Idris2 ABI tags. */
enum TunnelPhase: int
{
    case Idle = 0;
    case Phase1Init = 1;
    case Phase1Auth = 2;
    case Phase1Done = 3;
    case Phase2Negotiating = 4;
    case Established = 5;
    case TunnelPhase_Expired = 6;
}

/** EncryptionAlgorithm matching the Idris2 ABI tags. */
enum EncryptionAlgorithm: int
{
    case Aes128Cbc = 0;
    case Aes256Cbc = 1;
    case Aes128Gcm = 2;
    case Aes256Gcm = 3;
    case Chacha20Poly1305 = 4;
    case NullCipher = 5;
}

/** IntegrityAlgorithm matching the Idris2 ABI tags. */
enum IntegrityAlgorithm: int
{
    case HmacSha1 = 0;
    case HmacSha256 = 1;
    case HmacSha384 = 2;
    case HmacSha512 = 3;
    case NoIntegrity = 4;
}

/** DhGroup matching the Idris2 ABI tags. */
enum DhGroup: int
{
    case Dh14 = 0;
    case Ecp256 = 1;
    case Ecp384 = 2;
    case Curve25519 = 3;
}

/** SaLifecycle matching the Idris2 ABI tags. */
enum SaLifecycle: int
{
    case None = 0;
    case Active = 1;
    case Rekeying = 2;
    case SaLifecycle_Expired = 3;
    case Deleted = 4;
}

/** IkeVersion matching the Idris2 ABI tags. */
enum IkeVersion: int
{
    case V1 = 0;
    case V2 = 1;
}

/** VpnError matching the Idris2 ABI tags. */
enum VpnError: int
{
    case AuthenticationFailed = 0;
    case NoProposalChosen = 1;
    case LifetimeExpired = 2;
    case InvalidSpi = 3;
    case ReplayDetected = 4;
    case NegotiationTimeout = 5;
}
