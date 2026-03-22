<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WebSocket protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Opcode matching the Idris2 ABI tags. */
enum Opcode: int
{
    case Continuation = 0;
    case Text = 0;
    case Binary = 0;
    case Close = 0;
    case Ping = 0;
    case Pong = 0;
}

/** CloseCode matching the Idris2 ABI tags. */
enum CloseCode: int
{
    case Normal = 1000;
    case GoingAway = 1001;
    case ProtocolError = 1002;
    case UnsupportedData = 1003;
    case NoStatus = 1005;
    case Abnormal = 1006;
    case InvalidPayload = 1007;
    case PolicyViolation = 1008;
    case MessageTooBig = 1009;
    case MandatoryExtension = 1010;
    case InternalError = 1011;
}
