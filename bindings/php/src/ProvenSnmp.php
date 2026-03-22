<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SNMP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Version matching the Idris2 ABI tags. */
enum Version: int
{
    case V1 = 0;
    case V2c = 1;
    case V3 = 2;
}

/** PduType matching the Idris2 ABI tags. */
enum PduType: int
{
    case GetRequest = 0;
    case GetNextRequest = 1;
    case GetResponse = 2;
    case SetRequest = 3;
    case GetBulkRequest = 4;
    case InformRequest = 5;
    case SnmpV2Trap = 6;
}

/** ErrorStatus matching the Idris2 ABI tags. */
enum ErrorStatus: int
{
    case NoError = 0;
    case TooBig = 1;
    case NoSuchName = 2;
    case BadValue = 3;
    case ReadOnly = 4;
    case GenErr = 5;
    case NoAccess = 6;
    case WrongType = 7;
    case WrongLength = 8;
    case WrongValue = 9;
    case NoCreation = 10;
    case InconsistentValue = 11;
    case ResourceUnavailable = 12;
    case CommitFailed = 13;
    case UndoFailed = 14;
    case AuthorizationError = 15;
}
