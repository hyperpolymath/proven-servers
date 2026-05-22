// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Zero Trust protocol types for proven-servers.

namespace Proven;

/// <summary>PolicyType matching the Idris2 ABI tags (0-3).</summary>
public enum PolicyType : byte
{
    AlwaysVerify = 0,
    NeverTrust = 1,
    LeastPrivilege = 2,
    MicroSegmentation = 3
}

/// <summary>IdentityConfidence matching the Idris2 ABI tags (0-4).</summary>
public enum IdentityConfidence : byte
{
    Unverified = 0,
    BasicAuth = 1,
    MfaVerified = 2,
    StrongAuth = 3,
    ContinuousAuth = 4
}

/// <summary>DeviceTrustScore matching the Idris2 ABI tags (0-4).</summary>
public enum DeviceTrustScore : byte
{
    DeviceUnknown = 0,
    DevicePartial = 1,
    DeviceCompliant = 2,
    DeviceManaged = 3,
    DeviceHardened = 4
}

/// <summary>AccessDecision matching the Idris2 ABI tags (0-3).</summary>
public enum AccessDecision : byte
{
    Allow = 0,
    Deny = 1,
    Challenge = 2,
    StepUp = 3
}

/// <summary>ContextSignalKind matching the Idris2 ABI tags (0-4).</summary>
public enum ContextSignalKind : byte
{
    Location = 0,
    Time = 1,
    Device = 2,
    Behavior = 3,
    Network = 4
}

/// <summary>AuthFactor matching the Idris2 ABI tags (0-5).</summary>
public enum AuthFactor : byte
{
    Certificate = 0,
    Token = 1,
    Biometric = 2,
    Fido2 = 3,
    Totp = 4,
    Push = 5
}
