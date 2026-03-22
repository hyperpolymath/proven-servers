<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DDS protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ReliabilityKind matching the Idris2 ABI tags. */
enum ReliabilityKind: int
{
    case BestEffort = 0;
    case Reliable = 1;
}

/** DurabilityKind matching the Idris2 ABI tags. */
enum DurabilityKind: int
{
    case TransientLocal = 1;
    case Transient = 2;
    case Persistent = 3;
}

/** HistoryKind matching the Idris2 ABI tags. */
enum HistoryKind: int
{
    case KeepLast = 0;
    case KeepAll = 1;
}

/** OwnershipKind matching the Idris2 ABI tags. */
enum OwnershipKind: int
{
    case Shared = 0;
    case Exclusive = 1;
}

/** EntityType matching the Idris2 ABI tags. */
enum EntityType: int
{
    case Participant = 0;
    case Publisher = 1;
    case Subscriber = 2;
    case Topic = 3;
    case DataWriter = 4;
    case DataReader = 5;
}

/** ParticipantState matching the Idris2 ABI tags. */
enum ParticipantState: int
{
    case Idle = 0;
    case Joined = 1;
    case Publishing = 2;
    case Subscribing = 3;
    case Leaving = 4;
}
