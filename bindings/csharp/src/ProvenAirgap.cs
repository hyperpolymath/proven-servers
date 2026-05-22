// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Air Gap protocol types for proven-servers.

namespace Proven;

/// <summary>TransferDirection matching the Idris2 ABI tags (0-1).</summary>
public enum TransferDirection : byte
{
    Import = 0,
    Export = 1
}

/// <summary>MediaType matching the Idris2 ABI tags (0-3).</summary>
public enum MediaType : byte
{
    Usb = 0,
    OpticalDisc = 1,
    TapeCartridge = 2,
    DiodeLink = 3
}

/// <summary>ScanResult matching the Idris2 ABI tags (0-3).</summary>
public enum ScanResult : byte
{
    Clean = 0,
    Suspicious = 1,
    Malicious = 2,
    Unscannable = 3
}

/// <summary>TransferState matching the Idris2 ABI tags (0-6).</summary>
public enum TransferState : byte
{
    Pending = 0,
    Scanning = 1,
    Approved = 2,
    Rejected = 3,
    InProgress = 4,
    Complete = 5,
    Failed = 6
}

/// <summary>ValidationCheck matching the Idris2 ABI tags (0-4).</summary>
public enum ValidationCheck : byte
{
    HashVerify = 0,
    SignatureVerify = 1,
    FormatCheck = 2,
    ContentInspection = 3,
    MalwareScan = 4
}
