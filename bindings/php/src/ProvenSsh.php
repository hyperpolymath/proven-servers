<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SSH protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** SshMessageType matching the Idris2 ABI tags. */
enum SshMessageType: int
{
    case Kexinit = 0;
    case Newkeys = 1;
    case ServiceRequest = 2;
    case UserauthRequest = 3;
    case SshMessageType_ChannelOpen = 4;
    case ChannelData = 5;
    case ChannelClose = 6;
    case Disconnect = 7;
}

/** AuthMethod matching the Idris2 ABI tags. */
enum AuthMethod: int
{
    case Publickey = 0;
    case Password = 1;
    case KeyboardInteractive = 2;
    case AuthNone = 3;
}

/** KexMethod matching the Idris2 ABI tags. */
enum KexMethod: int
{
    case DiffieHellmanGroup14Sha256 = 0;
    case Curve25519Sha256 = 1;
    case DiffieHellmanGroup16Sha512 = 2;
    case DiffieHellmanGroup18Sha512 = 3;
    case EcdhSha2Nistp256 = 4;
    case EcdhSha2Nistp384 = 5;
}

/** ChannelType matching the Idris2 ABI tags. */
enum ChannelType: int
{
    case Session = 0;
    case DirectTcpip = 1;
    case ForwardedTcpip = 2;
    case X11 = 3;
}

/** BastionState matching the Idris2 ABI tags. */
enum BastionState: int
{
    case Connected = 0;
    case KeyExchanged = 1;
    case Authenticated = 2;
    case BastionState_ChannelOpen = 3;
    case Active = 4;
    case BastionState_Closed = 5;
}

/** ChannelState matching the Idris2 ABI tags. */
enum ChannelState: int
{
    case Opening = 0;
    case Open = 1;
    case Closing = 2;
    case ChannelState_Closed = 3;
}

/** DisconnectReason matching the Idris2 ABI tags. */
enum DisconnectReason: int
{
    case HostNotAllowed = 0;
    case ProtocolError = 1;
    case KeyExchangeFailed = 2;
    case HostAuthFailed = 3;
    case MacError = 4;
    case ServiceNotAvailable = 5;
    case VersionNotSupported = 6;
    case HostKeyNotVerifiable = 7;
    case ConnectionLost = 8;
    case ByApplication = 9;
    case TooManyConnections = 10;
    case AuthCancelled = 11;
}

/** HostKeyAlgorithm matching the Idris2 ABI tags. */
enum HostKeyAlgorithm: int
{
    case SshEd25519 = 0;
    case RsaSha2256 = 1;
    case RsaSha2512 = 2;
    case EcdsaNistp256 = 3;
}

/** CipherAlgorithm matching the Idris2 ABI tags. */
enum CipherAlgorithm: int
{
    case Chacha20Poly1305 = 0;
    case Aes256Gcm = 1;
    case Aes128Gcm = 2;
    case Aes256Ctr = 3;
    case Aes192Ctr = 4;
    case Aes128Ctr = 5;
}

/** ChannelOpenFailure matching the Idris2 ABI tags. */
enum ChannelOpenFailure: int
{
    case AdminProhibited = 0;
    case ConnectFailed = 1;
    case UnknownChannelType = 2;
    case ResourceShortage = 3;
}
