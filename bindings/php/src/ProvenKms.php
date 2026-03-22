<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// KMS protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ObjectType matching the Idris2 ABI tags. */
enum ObjectType: int
{
    case SymmetricKey = 0;
    case PublicKey = 1;
    case PrivateKey = 2;
    case SecretData = 3;
    case Certificate = 4;
    case OpaqueData = 5;
}

/** Operation matching the Idris2 ABI tags. */
enum Operation: int
{
    case Create = 0;
    case Get = 1;
    case Activate = 2;
    case Revoke = 3;
    case Destroy = 4;
    case Locate = 5;
    case Register = 6;
    case Rekey = 7;
    case Encrypt = 8;
    case Decrypt = 9;
    case Sign = 10;
    case Verify = 11;
    case Wrap = 12;
    case Unwrap = 13;
    case Mac = 14;
}

/** KeyState matching the Idris2 ABI tags. */
enum KeyState: int
{
    case PreActive = 0;
    case Active = 1;
    case Deactivated = 2;
    case Compromised = 3;
    case Destroyed = 4;
    case DestroyedCompromised = 5;
}

/** KmsAlgorithm matching the Idris2 ABI tags. */
enum KmsAlgorithm: int
{
    case Aes128 = 0;
    case Aes256 = 1;
    case Rsa2048 = 2;
    case Rsa4096 = 3;
    case EcdsaP256 = 4;
    case EcdsaP384 = 5;
    case Ed25519 = 6;
    case Chacha20Poly1305 = 7;
    case HmacSha256 = 8;
}
