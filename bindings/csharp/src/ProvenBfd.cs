// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BFD protocol types for proven-servers.

namespace Proven;

/// <summary>BfdState matching the Idris2 ABI tags (0-3).</summary>
public enum BfdState : byte
{
    AdminDown = 0,
    Down = 1,
    Init = 2,
    Up = 3
}

/// <summary>Diagnostic matching the Idris2 ABI tags (0-8).</summary>
public enum Diagnostic : byte
{
    NoDiagnostic = 0,
    ControlDetectionTimeExpired = 1,
    EchoFunctionFailed = 2,
    NeighborSignaledSessionDown = 3,
    ForwardingPlaneReset = 4,
    PathDown = 5,
    ConcatenatedPathDown = 6,
    AdministrativelyDown = 7,
    ReverseConcatenatedPathDown = 8
}

/// <summary>SessionMode matching the Idris2 ABI tags (0-1).</summary>
public enum SessionMode : byte
{
    AsyncMode = 0,
    DemandMode = 1
}

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Idle = 0,
    SsDown = 1,
    Negotiating = 2,
    Established = 3,
    Teardown = 4
}
