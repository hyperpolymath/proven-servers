<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Data Diode protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Direction matching the Idris2 ABI tags. */
enum Direction: int
{
    case HighToLow = 0;
    case LowToHigh = 1;
}

/** DiodeProtocol matching the Idris2 ABI tags. */
enum DiodeProtocol: int
{
    case Udp = 0;
    case Tcp = 1;
    case FileTransfer = 2;
    case Syslog = 3;
    case Snmp = 4;
}

/** TransferState matching the Idris2 ABI tags. */
enum TransferState: int
{
    case Queued = 0;
    case Sending = 1;
    case Confirming = 2;
    case Complete = 3;
    case Failed = 4;
}

/** ValidationResult matching the Idris2 ABI tags. */
enum ValidationResult: int
{
    case Passed = 0;
    case FormatError = 1;
    case SizeExceeded = 2;
    case PolicyBlocked = 3;
}

/** IntegrityCheck matching the Idris2 ABI tags. */
enum IntegrityCheck: int
{
    case Crc32 = 0;
    case Sha256 = 1;
    case Hmac = 2;
}

/** GatewayState matching the Idris2 ABI tags. */
enum GatewayState: int
{
    case Idle = 0;
    case Configured = 1;
    case Transferring = 2;
    case Validating = 3;
    case Shutdown = 4;
}
