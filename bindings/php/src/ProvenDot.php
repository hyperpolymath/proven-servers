<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoT protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Connecting = 0;
    case Handshaking = 1;
    case Established = 2;
    case Closing = 3;
    case Closed = 4;
}

/** PaddingStrategy matching the Idris2 ABI tags. */
enum PaddingStrategy: int
{
    case NoPadding = 0;
    case BlockPadding = 1;
    case RandomPadding = 2;
}

/** ErrorReason matching the Idris2 ABI tags. */
enum ErrorReason: int
{
    case HandshakeFailed = 0;
    case CertificateInvalid = 1;
    case Timeout = 2;
    case UpstreamError = 3;
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
