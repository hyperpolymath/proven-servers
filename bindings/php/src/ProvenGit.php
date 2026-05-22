<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Git protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Command matching the Idris2 ABI tags. */
enum Command: int
{
    case UploadPack = 0;
    case ReceivePack = 1;
    case UploadArchive = 2;
}

/** PacketType matching the Idris2 ABI tags. */
enum PacketType: int
{
    case Flush = 0;
    case Delimiter = 1;
    case ResponseEnd = 2;
    case Data = 3;
    case PktError = 4;
    case SidebandData = 5;
    case SidebandProgress = 6;
    case SidebandError = 7;
}

/** RefType matching the Idris2 ABI tags. */
enum RefType: int
{
    case Branch = 0;
    case Tag = 1;
    case Head = 2;
    case Remote = 3;
    case GitNote = 4;
}

/** Capability matching the Idris2 ABI tags. */
enum Capability: int
{
    case MultiAck = 0;
    case ThinPack = 1;
    case SideBand64k = 2;
    case OfsDelta = 3;
    case Shallow = 4;
    case DeepenSince = 5;
    case DeepenNot = 6;
    case FilterSpec = 7;
    case ObjectFormat = 8;
}

/** HookResult matching the Idris2 ABI tags. */
enum HookResult: int
{
    case Accept = 0;
    case Reject = 1;
}

/** ServerState matching the Idris2 ABI tags. */
enum ServerState: int
{
    case Idle = 0;
    case Discovery = 1;
    case Negotiating = 2;
    case Transfer = 3;
    case Shutdown = 4;
}
