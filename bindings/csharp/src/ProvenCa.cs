// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CA protocol types for proven-servers.

namespace Proven;

/// <summary>CertType matching the Idris2 ABI tags (0-6).</summary>
public enum CertType : byte
{
    Root = 0,
    Intermediate = 1,
    EndEntity = 2,
    CrossSigned = 3,
    CodeSigning = 4,
    EmailProtection = 5,
    OcspSigning = 6
}

/// <summary>KeyAlgorithm matching the Idris2 ABI tags (0-5).</summary>
public enum KeyAlgorithm : byte
{
    Rsa2048 = 0,
    Rsa4096 = 1,
    EcdsaP256 = 2,
    EcdsaP384 = 3,
    Ed25519 = 4,
    Ed448 = 5
}

/// <summary>SignatureAlgorithm matching the Idris2 ABI tags (0-6).</summary>
public enum SignatureAlgorithm : byte
{
    Sha256WithRsa = 0,
    Sha384WithRsa = 1,
    Sha512WithRsa = 2,
    Sha256WithEcdsa = 3,
    Sha384WithEcdsa = 4,
    PureEd25519 = 5,
    PureEd448 = 6
}

/// <summary>CertState matching the Idris2 ABI tags (0-4).</summary>
public enum CertState : byte
{
    Pending = 0,
    Active = 1,
    Revoked = 2,
    Expired = 3,
    Suspended = 4
}

/// <summary>RevocationReason matching the Idris2 ABI tags (0-6).</summary>
public enum RevocationReason : byte
{
    Unspecified = 0,
    KeyCompromise = 1,
    CaCompromise = 2,
    AffiliationChanged = 3,
    Superseded = 4,
    CessationOfOperation = 5,
    CertificateHold = 6
}

/// <summary>CrlStatus matching the Idris2 ABI tags (0-3).</summary>
public enum CrlStatus : byte
{
    Current = 0,
    CrlExpired = 1,
    CrlPending = 2,
    CrlError = 3
}

/// <summary>OcspStatus matching the Idris2 ABI tags (0-3).</summary>
public enum OcspStatus : byte
{
    Good = 0,
    OcspRevoked = 1,
    Unknown = 2,
    Unavailable = 3
}

/// <summary>Extension matching the Idris2 ABI tags (0-5).</summary>
public enum Extension : byte
{
    BasicConstraints = 0,
    KeyUsage = 1,
    ExtKeyUsage = 2,
    SubjectAltName = 3,
    AuthorityInfoAccess = 4,
    CrlDistributionPoints = 5
}

/// <summary>KeyUsageBit matching the Idris2 ABI tags (0-8).</summary>
public enum KeyUsageBit : byte
{
    DigitalSignature = 0,
    NonRepudiation = 1,
    KeyEncipherment = 2,
    DataEncipherment = 3,
    KeyAgreement = 4,
    KeyCertSign = 5,
    CrlSign = 6,
    EncipherOnly = 7,
    DecipherOnly = 8
}
