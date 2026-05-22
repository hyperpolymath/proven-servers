// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Agentic AI protocol types for proven-servers.

/// AgentState matching the Idris2 ABI tags.
public enum AgentState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case planning = 1
    case acting = 2
    case observing = 3
    case reflecting = 4
    case blocked = 5
    case terminated = 6
}

/// ToolCall matching the Idris2 ABI tags.
public enum ToolCall: UInt8, CaseIterable, Sendable {
    case execute = 0
    case query = 1
    case transform = 2
    case communicate = 3
    case delegate = 4
    case escalate = 5
}

/// PlanStep matching the Idris2 ABI tags.
public enum PlanStep: UInt8, CaseIterable, Sendable {
    case action = 0
    case condition = 1
    case loop = 2
    case branch = 3
    case parallel = 4
    case checkpoint = 5
    case rollback = 6
}

/// Coordination matching the Idris2 ABI tags.
public enum Coordination: UInt8, CaseIterable, Sendable {
    case solo = 0
    case collaborative = 1
    case competitive = 2
    case hierarchical = 3
    case swarm = 4
    case consensus = 5
}

/// SafetyCheck matching the Idris2 ABI tags.
public enum SafetyCheck: UInt8, CaseIterable, Sendable {
    case approved = 0
    case denied = 1
    case escalated = 2
    case timeout = 3
    case sandboxed = 4
    case humanRequired = 5
}
