<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CA protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** CertType matching the Idris2 ABI tags. */
enum CertType: int
{
    case Root = 0;
    case Intermediate = 1;
    case EndEntity = 2;
    case CrossSigned = 3;
    case CodeSigning = 4;
    case EmailProtection = 5;
    case OcspSigning = 6;
}

/** KeyAlgorithm matching the Idris2 ABI tags. */
enum KeyAlgorithm: int
{
    case Rsa2048 = 0;
    case Rsa4096 = 1;
    case EcdsaP256 = 2;
    case EcdsaP384 = 3;
    case Ed25519 = 4;
    case Ed448 = 5;
}

/** SignatureAlgorithm matching the Idris2 ABI tags. */
enum SignatureAlgorithm: int
{
    case Sha256WithRsa = 0;
    case Sha384WithRsa = 1;
    case Sha512WithRsa = 2;
    case Sha256WithEcdsa = 3;
    case Sha384WithEcdsa = 4;
    case PureEd25519 = 5;
    case PureEd448 = 6;
}

/** CertState matching the Idris2 ABI tags. */
enum CertState: int
{
    case Pending = 0;
    case Active = 1;
    case Revoked = 2;
    case Expired = 3;
    case Suspended = 4;
}

/** RevocationReason matching the Idris2 ABI tags. */
enum RevocationReason: int
{
    case Unspecified = 0;
    case KeyCompromise = 1;
    case CaCompromise = 2;
    case AffiliationChanged = 3;
    case Superseded = 4;
    case CessationOfOperation = 5;
    case CertificateHold = 6;
}

/** CrlStatus matching the Idris2 ABI tags. */
enum CrlStatus: int
{
    case Current = 0;
    case CrlExpired = 1;
    case CrlPending = 2;
    case CrlError = 3;
}

/** OcspStatus matching the Idris2 ABI tags. */
enum OcspStatus: int
{
    case Good = 0;
    case OcspRevoked = 1;
    case Unknown = 2;
    case Unavailable = 3;
}

/** Extension matching the Idris2 ABI tags. */
enum Extension: int
{
    case BasicConstraints = 0;
    case KeyUsage = 1;
    case ExtKeyUsage = 2;
    case SubjectAltName = 3;
    case AuthorityInfoAccess = 4;
    case CrlDistributionPoints = 5;
}

/** KeyUsageBit matching the Idris2 ABI tags. */
enum KeyUsageBit: int
{
    case DigitalSignature = 0;
    case NonRepudiation = 1;
    case KeyEncipherment = 2;
    case DataEncipherment = 3;
    case KeyAgreement = 4;
    case KeyCertSign = 5;
    case CrlSign = 6;
    case EncipherOnly = 7;
    case DecipherOnly = 8;
}
