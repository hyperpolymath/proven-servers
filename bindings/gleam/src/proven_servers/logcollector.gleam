//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Log Collector protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `LogcollectorABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// LogLevel
// ===========================================================================

/// Log severity levels.
/// 
/// Matches `LogLevel` in `LogcollectorABI.Types`.
pub type LogLevel {
  /// Trace (tag 0).
  Trace
  /// Debug (tag 1).
  Debug
  /// Info (tag 2).
  Info
  /// Warn (tag 3).
  Warn
  /// Error (tag 4).
  Err
  /// Fatal (tag 5).
  Fatal
}

/// Convert a `LogLevel` to its C-ABI tag value.
pub fn log_level_to_int(value: LogLevel) -> Int {
  case value {
    Trace -> 0
    Debug -> 1
    Info -> 2
    Warn -> 3
    Err -> 4
    Fatal -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn log_level_from_int(tag: Int) -> Result(LogLevel, Nil) {
  case tag {
    0 -> Ok(Trace)
    1 -> Ok(Debug)
    2 -> Ok(Info)
    3 -> Ok(Warn)
    4 -> Ok(Err)
    5 -> Ok(Fatal)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// InputFormat
// ===========================================================================

/// Log input formats.
/// 
/// Matches `InputFormat` in `LogcollectorABI.Types`.
pub type InputFormat {
  /// JSON (tag 0).
  Json
  /// Logfmt (tag 1).
  Logfmt
  /// Syslog (tag 2).
  Syslog
  /// CEF (tag 3).
  Cef
  /// GELF (tag 4).
  Gelf
  /// Raw (tag 5).
  Raw
}

/// Convert a `InputFormat` to its C-ABI tag value.
pub fn input_format_to_int(value: InputFormat) -> Int {
  case value {
    Json -> 0
    Logfmt -> 1
    Syslog -> 2
    Cef -> 3
    Gelf -> 4
    Raw -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn input_format_from_int(tag: Int) -> Result(InputFormat, Nil) {
  case tag {
    0 -> Ok(Json)
    1 -> Ok(Logfmt)
    2 -> Ok(Syslog)
    3 -> Ok(Cef)
    4 -> Ok(Gelf)
    5 -> Ok(Raw)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// OutputTarget
// ===========================================================================

/// Log output targets.
/// 
/// Matches `OutputTarget` in `LogcollectorABI.Types`.
pub type OutputTarget {
  /// File (tag 0).
  File
  /// Elasticsearch (tag 1).
  Elasticsearch
  /// S3 (tag 2).
  S3
  /// Kafka (tag 3).
  Kafka
  /// Stdout (tag 4).
  Stdout
}

/// Convert a `OutputTarget` to its C-ABI tag value.
pub fn output_target_to_int(value: OutputTarget) -> Int {
  case value {
    File -> 0
    Elasticsearch -> 1
    S3 -> 2
    Kafka -> 3
    Stdout -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn output_target_from_int(tag: Int) -> Result(OutputTarget, Nil) {
  case tag {
    0 -> Ok(File)
    1 -> Ok(Elasticsearch)
    2 -> Ok(S3)
    3 -> Ok(Kafka)
    4 -> Ok(Stdout)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// FilterOp
// ===========================================================================

/// Log filter operations.
/// 
/// Matches `FilterOp` in `LogcollectorABI.Types`.
pub type FilterOp {
  /// Include (tag 0).
  Include
  /// Exclude (tag 1).
  Exclude
  /// Transform (tag 2).
  Transform
  /// Redact (tag 3).
  Redact
  /// Sample (tag 4).
  Sample
}

/// Convert a `FilterOp` to its C-ABI tag value.
pub fn filter_op_to_int(value: FilterOp) -> Int {
  case value {
    Include -> 0
    Exclude -> 1
    Transform -> 2
    Redact -> 3
    Sample -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn filter_op_from_int(tag: Int) -> Result(FilterOp, Nil) {
  case tag {
    0 -> Ok(Include)
    1 -> Ok(Exclude)
    2 -> Ok(Transform)
    3 -> Ok(Redact)
    4 -> Ok(Sample)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PipelineStage
// ===========================================================================

/// Log pipeline stages.
/// 
/// Matches `PipelineStage` in `LogcollectorABI.Types`.
pub type PipelineStage {
  /// Input (tag 0).
  Input
  /// Parse (tag 1).
  Parse
  /// Filter (tag 2).
  Filter
  /// Transform (tag 3).
  PipelineTransform
  /// Output (tag 4).
  Output
}

/// Convert a `PipelineStage` to its C-ABI tag value.
pub fn pipeline_stage_to_int(value: PipelineStage) -> Int {
  case value {
    Input -> 0
    Parse -> 1
    Filter -> 2
    PipelineTransform -> 3
    Output -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn pipeline_stage_from_int(tag: Int) -> Result(PipelineStage, Nil) {
  case tag {
    0 -> Ok(Input)
    1 -> Ok(Parse)
    2 -> Ok(Filter)
    3 -> Ok(PipelineTransform)
    4 -> Ok(Output)
    _ -> Error(Nil)
  }
}

