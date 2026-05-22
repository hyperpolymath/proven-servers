<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LPD protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** CommandCode matching the Idris2 ABI tags. */
enum CommandCode: int
{
    case PrintJob = 1;
    case ReceiveJob = 2;
    case ShortQueue = 3;
    case LongQueue = 4;
    case RemoveJobs = 5;
}

/** SubCommandCode matching the Idris2 ABI tags. */
enum SubCommandCode: int
{
    case AbortJob = 1;
    case ControlFile = 2;
    case DataFile = 3;
}

/** JobStatus matching the Idris2 ABI tags. */
enum JobStatus: int
{
    case Pending = 0;
    case Printing = 1;
    case Complete = 2;
    case Failed = 3;
}
