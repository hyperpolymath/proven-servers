// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Hardened protocol types for proven-servers.

namespace Proven;

/// <summary>HardeningLevel matching the Idris2 ABI tags (0-3).</summary>
public enum HardeningLevel : byte
{
    Minimal = 0,
    Standard = 1,
    High = 2,
    Maximum = 3
}

/// <summary>SecurityControl matching the Idris2 ABI tags (0-6).</summary>
public enum SecurityControl : byte
{
    Aslr = 0,
    Dep = 1,
    StackCanary = 2,
    Cfi = 3,
    Sandboxing = 4,
    SecureBoot = 5,
    AuditLog = 6
}

/// <summary>ComplianceStandard matching the Idris2 ABI tags (0-4).</summary>
public enum ComplianceStandard : byte
{
    Cis = 0,
    Stig = 1,
    Nist80053 = 2,
    PciDss = 3,
    Fips140 = 4
}

/// <summary>AuditEvent matching the Idris2 ABI tags (0-5).</summary>
public enum AuditEvent : byte
{
    ProcessStart = 0,
    FileAccess = 1,
    NetworkConn = 2,
    PrivilegeEscalation = 3,
    ConfigChange = 4,
    AuthAttempt = 5
}

/// <summary>HardenedHealthStatus matching the Idris2 ABI tags (0-3).</summary>
public enum HardenedHealthStatus : byte
{
    Healthy = 0,
    Degraded = 1,
    Compromised = 2,
    Unresponsive = 3
}

/// <summary>ServerState matching the Idris2 ABI tags (0-4).</summary>
public enum ServerState : byte
{
    Idle = 0,
    Hardening = 1,
    Active = 2,
    Auditing = 3,
    Shutdown = 4
}
