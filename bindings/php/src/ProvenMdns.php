<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// mDNS protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** MdnsRecordType matching the Idris2 ABI tags. */
enum MdnsRecordType: int
{
    case A = 0;
    case Aaaa = 1;
    case Ptr = 2;
    case Srv = 3;
    case Txt = 4;
}

/** QueryType matching the Idris2 ABI tags. */
enum QueryType: int
{
    case Standard = 0;
    case OneShot = 1;
    case Continuous = 2;
}

/** ConflictAction matching the Idris2 ABI tags. */
enum ConflictAction: int
{
    case Probe = 0;
    case Defend = 1;
    case Withdraw = 2;
}

/** ServiceFlag matching the Idris2 ABI tags. */
enum ServiceFlag: int
{
    case Unique = 0;
    case Shared = 1;
}

/** ResponderState matching the Idris2 ABI tags. */
enum ResponderState: int
{
    case Idle = 0;
    case Probing = 1;
    case Announcing = 2;
    case Running = 3;
    case ShuttingDown = 4;
}
