// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Log Collector protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// LogLevel represents the LogLevel type (Idris2 ABI tags).
type LogLevel uint8

const (
	LogLevelTrace LogLevel = iota
	LogLevelDebug
	LogLevelInfo
	LogLevelWarn
	LogLevelErr
	LogLevelFatal
)

// InputFormat represents the InputFormat type (Idris2 ABI tags).
type InputFormat uint8

const (
	InputFormatJson InputFormat = iota
	InputFormatLogfmt
	InputFormatSyslog
	InputFormatCef
	InputFormatGelf
	InputFormatRaw
)

// OutputTarget represents the OutputTarget type (Idris2 ABI tags).
type OutputTarget uint8

const (
	OutputTargetFile OutputTarget = iota
	OutputTargetElasticsearch
	OutputTargetS3
	OutputTargetKafka
	OutputTargetStdout
)

// FilterOp represents the FilterOp type (Idris2 ABI tags).
type FilterOp uint8

const (
	FilterOpInclude FilterOp = iota
	FilterOpExclude
	FilterOpTransform
	FilterOpRedact
	FilterOpSample
)

// PipelineStage represents the PipelineStage type (Idris2 ABI tags).
type PipelineStage uint8

const (
	PipelineStageInput PipelineStage = iota
	PipelineStageParse
	PipelineStageFilter
	PipelineStagePipelineTransform
	PipelineStageOutput
)
