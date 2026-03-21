// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Agentic AI types for the proven-servers ABI.
//!
//! Formally verified agentic AI orchestration types.
//! Mirrors the Idris2 module `AgenticABI.Types`.
//!
//! - `AgentState` -- AI agent lifecycle states.
//! - `ToolCall` -- Agent tool call types.
//! - `PlanStep` -- Agent plan step types.
//! - `Coordination` -- Multi-agent coordination modes.
//! - `SafetyCheck` -- Agent safety check results.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// AgentState (tags 0-6)
// ===========================================================================

/// AI agent lifecycle states.
///
/// Matches `AgentState` in `AgenticABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AgentState {
    /// Idle (tag 0).
    Idle = 0,
    /// Planning (tag 1).
    Planning = 1,
    /// Acting (tag 2).
    Acting = 2,
    /// Observing (tag 3).
    Observing = 3,
    /// Reflecting (tag 4).
    Reflecting = 4,
    /// Blocked (tag 5).
    Blocked = 5,
    /// Terminated (tag 6).
    Terminated = 6,
}

impl AgentState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Planning),
            2 => Some(Self::Acting),
            3 => Some(Self::Observing),
            4 => Some(Self::Reflecting),
            5 => Some(Self::Blocked),
            6 => Some(Self::Terminated),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the agent is actively working.
    pub fn is_active(self) -> bool {
        matches!(self, Self::Planning | Self::Acting | Self::Observing | Self::Reflecting)
    }

    /// All variants of this type.
    pub const ALL: [AgentState; 7] = [
        Self::Idle, Self::Planning, Self::Acting, Self::Observing, Self::Reflecting, Self::Blocked, Self::Terminated,
    ];
}

impl fmt::Display for AgentState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ToolCall (tags 0-5)
// ===========================================================================

/// Agent tool call types.
///
/// Matches `ToolCall` in `AgenticABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ToolCall {
    /// Execute (tag 0).
    Execute = 0,
    /// Query (tag 1).
    Query = 1,
    /// Transform (tag 2).
    Transform = 2,
    /// Communicate (tag 3).
    Communicate = 3,
    /// Delegate (tag 4).
    Delegate = 4,
    /// Escalate (tag 5).
    Escalate = 5,
}

impl ToolCall {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Execute),
            1 => Some(Self::Query),
            2 => Some(Self::Transform),
            3 => Some(Self::Communicate),
            4 => Some(Self::Delegate),
            5 => Some(Self::Escalate),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ToolCall; 6] = [
        Self::Execute, Self::Query, Self::Transform, Self::Communicate, Self::Delegate, Self::Escalate,
    ];
}

impl fmt::Display for ToolCall {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PlanStep (tags 0-6)
// ===========================================================================

/// Agent plan step types.
///
/// Matches `PlanStep` in `AgenticABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PlanStep {
    /// Action (tag 0).
    Action = 0,
    /// Condition (tag 1).
    Condition = 1,
    /// Loop (tag 2).
    Loop = 2,
    /// Branch (tag 3).
    Branch = 3,
    /// Parallel (tag 4).
    Parallel = 4,
    /// Checkpoint (tag 5).
    Checkpoint = 5,
    /// Rollback (tag 6).
    Rollback = 6,
}

impl PlanStep {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Action),
            1 => Some(Self::Condition),
            2 => Some(Self::Loop),
            3 => Some(Self::Branch),
            4 => Some(Self::Parallel),
            5 => Some(Self::Checkpoint),
            6 => Some(Self::Rollback),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PlanStep; 7] = [
        Self::Action, Self::Condition, Self::Loop, Self::Branch, Self::Parallel, Self::Checkpoint, Self::Rollback,
    ];
}

impl fmt::Display for PlanStep {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Coordination (tags 0-5)
// ===========================================================================

/// Multi-agent coordination modes.
///
/// Matches `Coordination` in `AgenticABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Coordination {
    /// Solo (tag 0).
    Solo = 0,
    /// Collaborative (tag 1).
    Collaborative = 1,
    /// Competitive (tag 2).
    Competitive = 2,
    /// Hierarchical (tag 3).
    Hierarchical = 3,
    /// Swarm (tag 4).
    Swarm = 4,
    /// Consensus (tag 5).
    Consensus = 5,
}

impl Coordination {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Solo),
            1 => Some(Self::Collaborative),
            2 => Some(Self::Competitive),
            3 => Some(Self::Hierarchical),
            4 => Some(Self::Swarm),
            5 => Some(Self::Consensus),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Coordination; 6] = [
        Self::Solo, Self::Collaborative, Self::Competitive, Self::Hierarchical, Self::Swarm, Self::Consensus,
    ];
}

impl fmt::Display for Coordination {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SafetyCheck (tags 0-5)
// ===========================================================================

/// Agent safety check results.
///
/// Matches `SafetyCheck` in `AgenticABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SafetyCheck {
    /// Approved (tag 0).
    Approved = 0,
    /// Denied (tag 1).
    Denied = 1,
    /// Escalated (tag 2).
    Escalated = 2,
    /// Timeout (tag 3).
    Timeout = 3,
    /// Sandboxed (tag 4).
    Sandboxed = 4,
    /// HumanRequired (tag 5).
    HumanRequired = 5,
}

impl SafetyCheck {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Approved),
            1 => Some(Self::Denied),
            2 => Some(Self::Escalated),
            3 => Some(Self::Timeout),
            4 => Some(Self::Sandboxed),
            5 => Some(Self::HumanRequired),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the action is approved to proceed.
    pub fn is_safe(self) -> bool {
        matches!(self, Self::Approved | Self::Sandboxed)
    }

    /// All variants of this type.
    pub const ALL: [SafetyCheck; 6] = [
        Self::Approved, Self::Denied, Self::Escalated, Self::Timeout, Self::Sandboxed, Self::HumanRequired,
    ];
}

impl fmt::Display for SafetyCheck {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn agent_state_roundtrip() {
        for v in AgentState::ALL {
            let tag = v.to_tag();
            let decoded = AgentState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AgentState::from_tag(7).is_none());
    }

    #[test]
    fn tool_call_roundtrip() {
        for v in ToolCall::ALL {
            let tag = v.to_tag();
            let decoded = ToolCall::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ToolCall::from_tag(6).is_none());
    }

    #[test]
    fn plan_step_roundtrip() {
        for v in PlanStep::ALL {
            let tag = v.to_tag();
            let decoded = PlanStep::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PlanStep::from_tag(7).is_none());
    }

    #[test]
    fn coordination_roundtrip() {
        for v in Coordination::ALL {
            let tag = v.to_tag();
            let decoded = Coordination::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Coordination::from_tag(6).is_none());
    }

    #[test]
    fn safety_check_roundtrip() {
        for v in SafetyCheck::ALL {
            let tag = v.to_tag();
            let decoded = SafetyCheck::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SafetyCheck::from_tag(6).is_none());
    }

}
