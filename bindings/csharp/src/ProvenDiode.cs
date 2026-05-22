// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Data Diode protocol types for proven-servers.

namespace Proven;

/// <summary>Direction matching the Idris2 ABI tags (0-1).</summary>
public enum Direction : byte
{
    HighToLow = 0,
    LowToHigh = 1
}

/// <summary>DiodeProtocol matching the Idris2 ABI tags (0-4).</summary>
public enum DiodeProtocol : byte
{
    Udp = 0,
    Tcp = 1,
    FileTransfer = 2,
    Syslog = 3,
    Snmp = 4
}

/// <summary>TransferState matching the Idris2 ABI tags (0-4).</summary>
public enum TransferState : byte
{
    Queued = 0,
    Sending = 1,
    Confirming = 2,
    Complete = 3,
    Failed = 4
}

/// <summary>ValidationResult matching the Idris2 ABI tags (0-3).</summary>
public enum ValidationResult : byte
{
    Passed = 0,
    FormatError = 1,
    SizeExceeded = 2,
    PolicyBlocked = 3
}

/// <summary>IntegrityCheck matching the Idris2 ABI tags (0-2).</summary>
public enum IntegrityCheck : byte
{
    Crc32 = 0,
    Sha256 = 1,
    Hmac = 2
}

/// <summary>GatewayState matching the Idris2 ABI tags (0-4).</summary>
public enum GatewayState : byte
{
    Idle = 0,
    Configured = 1,
    Transferring = 2,
    Validating = 3,
    Shutdown = 4
}
