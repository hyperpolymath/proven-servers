<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Air Gap protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** TransferDirection matching the Idris2 ABI tags. */
enum TransferDirection: int
{
    case Import = 0;
    case Export = 1;
}

/** MediaType matching the Idris2 ABI tags. */
enum MediaType: int
{
    case Usb = 0;
    case OpticalDisc = 1;
    case TapeCartridge = 2;
    case DiodeLink = 3;
}

/** ScanResult matching the Idris2 ABI tags. */
enum ScanResult: int
{
    case Clean = 0;
    case Suspicious = 1;
    case Malicious = 2;
    case Unscannable = 3;
}

/** TransferState matching the Idris2 ABI tags. */
enum TransferState: int
{
    case Pending = 0;
    case Scanning = 1;
    case Approved = 2;
    case Rejected = 3;
    case InProgress = 4;
    case Complete = 5;
    case Failed = 6;
}

/** ValidationCheck matching the Idris2 ABI tags. */
enum ValidationCheck: int
{
    case HashVerify = 0;
    case SignatureVerify = 1;
    case FormatCheck = 2;
    case ContentInspection = 3;
    case MalwareScan = 4;
}
