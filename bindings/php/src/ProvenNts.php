<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTS protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** RecordType matching the Idris2 ABI tags. */
enum RecordType: int
{
    case EndOfMessage = 0;
    case NextProtocol = 1;
    case Error = 2;
    case Warning = 3;
    case AeadAlgorithm = 4;
    case Cookie = 5;
    case CookiePlaceholder = 6;
    case NtskeServer = 7;
    case NtskePort = 8;
}

/** ErrorCode matching the Idris2 ABI tags. */
enum ErrorCode: int
{
    case UnrecognizedCritical = 0;
    case BadRequest = 1;
    case InternalError = 2;
}

/** AeadAlgorithm matching the Idris2 ABI tags. */
enum AeadAlgorithm: int
{
    case AeadAes128Gcm = 0;
    case AeadAes256Gcm = 1;
    case AeadAesSivCmac256 = 2;
}

/** HandshakeState matching the Idris2 ABI tags. */
enum HandshakeState: int
{
    case Initial = 0;
    case HandshakeState_Negotiating = 1;
    case HandshakeState_Established = 2;
    case Failed = 3;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Handshaking = 1;
    case SessionState_Negotiating = 2;
    case SessionState_Established = 3;
    case Closing = 4;
}
