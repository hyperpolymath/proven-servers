// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenLogcollector protocol bindings.

open ProvenLogcollector

let test_logLevel_roundtrip = () => {
  assert(logLevelFromTag(0) == Some(Trace))
  assert(logLevelFromTag(1) == Some(Debug))
  assert(logLevelFromTag(2) == Some(Info))
  assert(logLevelFromTag(3) == Some(Warn))
  assert(logLevelFromTag(4) == Some(Err))
  assert(logLevelFromTag(5) == Some(Fatal))
  assert(logLevelFromTag(6) == None)
}

let test_logLevel_toTag = () => {
  assert(logLevelToTag(Trace) == 0)
  assert(logLevelToTag(Debug) == 1)
  assert(logLevelToTag(Info) == 2)
  assert(logLevelToTag(Warn) == 3)
  assert(logLevelToTag(Err) == 4)
  assert(logLevelToTag(Fatal) == 5)
}

let test_inputFormat_roundtrip = () => {
  assert(inputFormatFromTag(0) == Some(Json))
  assert(inputFormatFromTag(1) == Some(Logfmt))
  assert(inputFormatFromTag(2) == Some(Syslog))
  assert(inputFormatFromTag(3) == Some(Cef))
  assert(inputFormatFromTag(4) == Some(Gelf))
  assert(inputFormatFromTag(5) == Some(Raw))
  assert(inputFormatFromTag(6) == None)
}

let test_inputFormat_toTag = () => {
  assert(inputFormatToTag(Json) == 0)
  assert(inputFormatToTag(Logfmt) == 1)
  assert(inputFormatToTag(Syslog) == 2)
  assert(inputFormatToTag(Cef) == 3)
  assert(inputFormatToTag(Gelf) == 4)
  assert(inputFormatToTag(Raw) == 5)
}

let test_outputTarget_roundtrip = () => {
  assert(outputTargetFromTag(0) == Some(File))
  assert(outputTargetFromTag(1) == Some(Elasticsearch))
  assert(outputTargetFromTag(2) == Some(S3))
  assert(outputTargetFromTag(3) == Some(Kafka))
  assert(outputTargetFromTag(4) == Some(Stdout))
  assert(outputTargetFromTag(5) == None)
}

let test_outputTarget_toTag = () => {
  assert(outputTargetToTag(File) == 0)
  assert(outputTargetToTag(Elasticsearch) == 1)
  assert(outputTargetToTag(S3) == 2)
  assert(outputTargetToTag(Kafka) == 3)
  assert(outputTargetToTag(Stdout) == 4)
}

let test_filterOp_roundtrip = () => {
  assert(filterOpFromTag(0) == Some(Include))
  assert(filterOpFromTag(1) == Some(Exclude))
  assert(filterOpFromTag(2) == Some(Transform))
  assert(filterOpFromTag(3) == Some(Redact))
  assert(filterOpFromTag(4) == Some(Sample))
  assert(filterOpFromTag(5) == None)
}

let test_filterOp_toTag = () => {
  assert(filterOpToTag(Include) == 0)
  assert(filterOpToTag(Exclude) == 1)
  assert(filterOpToTag(Transform) == 2)
  assert(filterOpToTag(Redact) == 3)
  assert(filterOpToTag(Sample) == 4)
}

let test_pipelineStage_roundtrip = () => {
  assert(pipelineStageFromTag(0) == Some(Input))
  assert(pipelineStageFromTag(1) == Some(Parse))
  assert(pipelineStageFromTag(2) == Some(Filter))
  assert(pipelineStageFromTag(3) == Some(PipelineTransform))
  assert(pipelineStageFromTag(4) == Some(Output))
  assert(pipelineStageFromTag(5) == None)
}

let test_pipelineStage_toTag = () => {
  assert(pipelineStageToTag(Input) == 0)
  assert(pipelineStageToTag(Parse) == 1)
  assert(pipelineStageToTag(Filter) == 2)
  assert(pipelineStageToTag(PipelineTransform) == 3)
  assert(pipelineStageToTag(Output) == 4)
}

// Run all tests
test_logLevel_roundtrip()
test_logLevel_toTag()
test_inputFormat_roundtrip()
test_inputFormat_toTag()
test_outputTarget_roundtrip()
test_outputTarget_toTag()
test_filterOp_roundtrip()
test_filterOp_toTag()
test_pipelineStage_roundtrip()
test_pipelineStage_toTag()
