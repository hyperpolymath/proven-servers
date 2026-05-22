<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TFTP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Opcode matching the Idris2 ABI tags. */
enum Opcode: int
{
    case Rrq = 0;
    case Wrq = 1;
    case Data = 2;
    case Ack = 3;
    case Error = 4;
}

/** TransferMode matching the Idris2 ABI tags. */
enum TransferMode: int
{
    case NetAscii = 0;
    case Octet = 1;
    case Mail = 2;
}

/** TftpError matching the Idris2 ABI tags. */
enum TftpError: int
{
    case NotDefined = 0;
    case FileNotFound = 1;
    case AccessViolation = 2;
    case DiskFull = 3;
    case IllegalOperation = 4;
    case UnknownTid = 5;
    case FileExists = 6;
    case NoSuchUser = 7;
}

/** TransferState matching the Idris2 ABI tags. */
enum TransferState: int
{
    case Idle = 0;
    case Reading = 1;
    case Writing = 2;
    case InError = 3;
    case Complete = 4;
}
