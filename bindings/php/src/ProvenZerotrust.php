<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Zero Trust protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** PolicyType matching the Idris2 ABI tags. */
enum PolicyType: int
{
    case AlwaysVerify = 0;
    case NeverTrust = 1;
    case LeastPrivilege = 2;
    case MicroSegmentation = 3;
}

/** IdentityConfidence matching the Idris2 ABI tags. */
enum IdentityConfidence: int
{
    case Unverified = 0;
    case BasicAuth = 1;
    case MfaVerified = 2;
    case StrongAuth = 3;
    case ContinuousAuth = 4;
}

/** DeviceTrustScore matching the Idris2 ABI tags. */
enum DeviceTrustScore: int
{
    case DeviceUnknown = 0;
    case DevicePartial = 1;
    case DeviceCompliant = 2;
    case DeviceManaged = 3;
    case DeviceHardened = 4;
}

/** AccessDecision matching the Idris2 ABI tags. */
enum AccessDecision: int
{
    case Allow = 0;
    case Deny = 1;
    case Challenge = 2;
    case StepUp = 3;
}

/** ContextSignalKind matching the Idris2 ABI tags. */
enum ContextSignalKind: int
{
    case Location = 0;
    case Time = 1;
    case Device = 2;
    case Behavior = 3;
    case Network = 4;
}

/** AuthFactor matching the Idris2 ABI tags. */
enum AuthFactor: int
{
    case Certificate = 0;
    case Token = 1;
    case Biometric = 2;
    case Fido2 = 3;
    case Totp = 4;
    case Push = 5;
}
