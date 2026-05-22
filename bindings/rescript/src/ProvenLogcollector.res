// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Log Collector types for the proven-servers ABI.
//
// Mirrors the Idris2 module LogcollectorABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// LogLevel (tags 0-5)
// ===========================================================================

/// Log severity levels.
type logLevel =
  | @as(0) Trace
  | @as(1) Debug
  | @as(2) Info
  | @as(3) Warn
  | @as(4) Err
  | @as(5) Fatal

/// Decode from the C-ABI tag value.
let logLevelFromTag = (tag: int): option<logLevel> =>
  switch tag {
  | 0 => Some(Trace)
  | 1 => Some(Debug)
  | 2 => Some(Info)
  | 3 => Some(Warn)
  | 4 => Some(Err)
  | 5 => Some(Fatal)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let logLevelToTag = (v: logLevel): int =>
  switch v {
  | Trace => 0
  | Debug => 1
  | Info => 2
  | Warn => 3
  | Err => 4
  | Fatal => 5
  }

// ===========================================================================
// InputFormat (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type inputFormat =
  | @as(0) Json
  | @as(1) Logfmt
  | @as(2) Syslog
  | @as(3) Cef
  | @as(4) Gelf
  | @as(5) Raw

/// Decode from the C-ABI tag value.
let inputFormatFromTag = (tag: int): option<inputFormat> =>
  switch tag {
  | 0 => Some(Json)
  | 1 => Some(Logfmt)
  | 2 => Some(Syslog)
  | 3 => Some(Cef)
  | 4 => Some(Gelf)
  | 5 => Some(Raw)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let inputFormatToTag = (v: inputFormat): int =>
  switch v {
  | Json => 0
  | Logfmt => 1
  | Syslog => 2
  | Cef => 3
  | Gelf => 4
  | Raw => 5
  }

// ===========================================================================
// OutputTarget (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type outputTarget =
  | @as(0) File
  | @as(1) Elasticsearch
  | @as(2) S3
  | @as(3) Kafka
  | @as(4) Stdout

/// Decode from the C-ABI tag value.
let outputTargetFromTag = (tag: int): option<outputTarget> =>
  switch tag {
  | 0 => Some(File)
  | 1 => Some(Elasticsearch)
  | 2 => Some(S3)
  | 3 => Some(Kafka)
  | 4 => Some(Stdout)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let outputTargetToTag = (v: outputTarget): int =>
  switch v {
  | File => 0
  | Elasticsearch => 1
  | S3 => 2
  | Kafka => 3
  | Stdout => 4
  }

// ===========================================================================
// FilterOp (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type filterOp =
  | @as(0) Include
  | @as(1) Exclude
  | @as(2) Transform
  | @as(3) Redact
  | @as(4) Sample

/// Decode from the C-ABI tag value.
let filterOpFromTag = (tag: int): option<filterOp> =>
  switch tag {
  | 0 => Some(Include)
  | 1 => Some(Exclude)
  | 2 => Some(Transform)
  | 3 => Some(Redact)
  | 4 => Some(Sample)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let filterOpToTag = (v: filterOp): int =>
  switch v {
  | Include => 0
  | Exclude => 1
  | Transform => 2
  | Redact => 3
  | Sample => 4
  }

// ===========================================================================
// PipelineStage (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type pipelineStage =
  | @as(0) Input
  | @as(1) Parse
  | @as(2) Filter
  | @as(3) PipelineTransform
  | @as(4) Output

/// Decode from the C-ABI tag value.
let pipelineStageFromTag = (tag: int): option<pipelineStage> =>
  switch tag {
  | 0 => Some(Input)
  | 1 => Some(Parse)
  | 2 => Some(Filter)
  | 3 => Some(PipelineTransform)
  | 4 => Some(Output)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let pipelineStageToTag = (v: pipelineStage): int =>
  switch v {
  | Input => 0
  | Parse => 1
  | Filter => 2
  | PipelineTransform => 3
  | Output => 4
  }

