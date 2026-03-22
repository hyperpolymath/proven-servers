// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DDS protocol types for proven-servers.

namespace Proven;

/// <summary>ReliabilityKind matching the Idris2 ABI tags (0-1).</summary>
public enum ReliabilityKind : byte
{
    BestEffort = 0,
    Reliable = 1
}

/// <summary>DurabilityKind matching the Idris2 ABI tags (0-2).</summary>
public enum DurabilityKind : byte
{
    TransientLocal = 0,
    Transient = 1,
    Persistent = 2
}

/// <summary>HistoryKind matching the Idris2 ABI tags (0-1).</summary>
public enum HistoryKind : byte
{
    KeepLast = 0,
    KeepAll = 1
}

/// <summary>OwnershipKind matching the Idris2 ABI tags (0-1).</summary>
public enum OwnershipKind : byte
{
    Shared = 0,
    Exclusive = 1
}

/// <summary>EntityType matching the Idris2 ABI tags (0-5).</summary>
public enum EntityType : byte
{
    Participant = 0,
    Publisher = 1,
    Subscriber = 2,
    Topic = 3,
    DataWriter = 4,
    DataReader = 5
}

/// <summary>ParticipantState matching the Idris2 ABI tags (0-4).</summary>
public enum ParticipantState : byte
{
    Idle = 0,
    Joined = 1,
    Publishing = 2,
    Subscribing = 3,
    Leaving = 4
}
