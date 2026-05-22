// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Log Collector types for the proven-servers ABI.
//!
//! Formally verified log collection/pipeline types.
//! Mirrors the Idris2 module `LogcollectorABI.Types`.
//!
//! - `LogLevel` -- Log severity levels.
//! - `InputFormat` -- Log input formats.
//! - `OutputTarget` -- Log output targets.
//! - `FilterOp` -- Log filter operations.
//! - `PipelineStage` -- Log pipeline stages.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// LogLevel (tags 0-5)
// ===========================================================================

/// Log severity levels.
///
/// Matches `LogLevel` in `LogcollectorABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum LogLevel {
    /// Trace (tag 0).
    Trace = 0,
    /// Debug (tag 1).
    Debug = 1,
    /// Info (tag 2).
    Info = 2,
    /// Warn (tag 3).
    Warn = 3,
    /// Error (tag 4).
    Err = 4,
    /// Fatal (tag 5).
    Fatal = 5,
}

impl LogLevel {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Trace),
            1 => Some(Self::Debug),
            2 => Some(Self::Info),
            3 => Some(Self::Warn),
            4 => Some(Self::Err),
            5 => Some(Self::Fatal),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [LogLevel; 6] = [
        Self::Trace, Self::Debug, Self::Info, Self::Warn, Self::Err, Self::Fatal,
    ];
}

impl fmt::Display for LogLevel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// InputFormat (tags 0-5)
// ===========================================================================

/// Log input formats.
///
/// Matches `InputFormat` in `LogcollectorABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum InputFormat {
    /// JSON (tag 0).
    Json = 0,
    /// Logfmt (tag 1).
    Logfmt = 1,
    /// Syslog (tag 2).
    Syslog = 2,
    /// CEF (tag 3).
    Cef = 3,
    /// GELF (tag 4).
    Gelf = 4,
    /// Raw (tag 5).
    Raw = 5,
}

impl InputFormat {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Json),
            1 => Some(Self::Logfmt),
            2 => Some(Self::Syslog),
            3 => Some(Self::Cef),
            4 => Some(Self::Gelf),
            5 => Some(Self::Raw),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [InputFormat; 6] = [
        Self::Json, Self::Logfmt, Self::Syslog, Self::Cef, Self::Gelf, Self::Raw,
    ];
}

impl fmt::Display for InputFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// OutputTarget (tags 0-4)
// ===========================================================================

/// Log output targets.
///
/// Matches `OutputTarget` in `LogcollectorABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum OutputTarget {
    /// File (tag 0).
    File = 0,
    /// Elasticsearch (tag 1).
    Elasticsearch = 1,
    /// S3 (tag 2).
    S3 = 2,
    /// Kafka (tag 3).
    Kafka = 3,
    /// Stdout (tag 4).
    Stdout = 4,
}

impl OutputTarget {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::File),
            1 => Some(Self::Elasticsearch),
            2 => Some(Self::S3),
            3 => Some(Self::Kafka),
            4 => Some(Self::Stdout),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [OutputTarget; 5] = [
        Self::File, Self::Elasticsearch, Self::S3, Self::Kafka, Self::Stdout,
    ];
}

impl fmt::Display for OutputTarget {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// FilterOp (tags 0-4)
// ===========================================================================

/// Log filter operations.
///
/// Matches `FilterOp` in `LogcollectorABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum FilterOp {
    /// Include (tag 0).
    Include = 0,
    /// Exclude (tag 1).
    Exclude = 1,
    /// Transform (tag 2).
    Transform = 2,
    /// Redact (tag 3).
    Redact = 3,
    /// Sample (tag 4).
    Sample = 4,
}

impl FilterOp {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Include),
            1 => Some(Self::Exclude),
            2 => Some(Self::Transform),
            3 => Some(Self::Redact),
            4 => Some(Self::Sample),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [FilterOp; 5] = [
        Self::Include, Self::Exclude, Self::Transform, Self::Redact, Self::Sample,
    ];
}

impl fmt::Display for FilterOp {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PipelineStage (tags 0-4)
// ===========================================================================

/// Log pipeline stages.
///
/// Matches `PipelineStage` in `LogcollectorABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PipelineStage {
    /// Input (tag 0).
    Input = 0,
    /// Parse (tag 1).
    Parse = 1,
    /// Filter (tag 2).
    Filter = 2,
    /// Transform (tag 3).
    PipelineTransform = 3,
    /// Output (tag 4).
    Output = 4,
}

impl PipelineStage {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Input),
            1 => Some(Self::Parse),
            2 => Some(Self::Filter),
            3 => Some(Self::PipelineTransform),
            4 => Some(Self::Output),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PipelineStage; 5] = [
        Self::Input, Self::Parse, Self::Filter, Self::PipelineTransform, Self::Output,
    ];
}

impl fmt::Display for PipelineStage {
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
    fn log_level_roundtrip() {
        for v in LogLevel::ALL {
            let tag = v.to_tag();
            let decoded = LogLevel::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(LogLevel::from_tag(6).is_none());
    }

    #[test]
    fn input_format_roundtrip() {
        for v in InputFormat::ALL {
            let tag = v.to_tag();
            let decoded = InputFormat::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(InputFormat::from_tag(6).is_none());
    }

    #[test]
    fn output_target_roundtrip() {
        for v in OutputTarget::ALL {
            let tag = v.to_tag();
            let decoded = OutputTarget::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(OutputTarget::from_tag(5).is_none());
    }

    #[test]
    fn filter_op_roundtrip() {
        for v in FilterOp::ALL {
            let tag = v.to_tag();
            let decoded = FilterOp::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(FilterOp::from_tag(5).is_none());
    }

    #[test]
    fn pipeline_stage_roundtrip() {
        for v in PipelineStage::ALL {
            let tag = v.to_tag();
            let decoded = PipelineStage::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PipelineStage::from_tag(5).is_none());
    }

}
