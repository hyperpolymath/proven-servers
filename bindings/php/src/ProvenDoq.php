<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoQ protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** StreamType matching the Idris2 ABI tags. */
enum StreamType: int
{
    case Unidirectional = 0;
    case Bidirectional = 1;
}

/** ErrorCode matching the Idris2 ABI tags. */
enum ErrorCode: int
{
    case NoError = 0;
    case InternalError = 1;
    case ExcessiveLoad = 2;
    case ProtocolError = 3;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Initial = 0;
    case Handshaking = 1;
    case Ready = 2;
    case Draining = 3;
    case Closed = 4;
}

/** ServerState matching the Idris2 ABI tags. */
enum ServerState: int
{
    case Idle = 0;
    case Bound = 1;
    case Listening = 2;
    case Processing = 3;
    case Shutdown = 4;
}
