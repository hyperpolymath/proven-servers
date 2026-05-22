-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LogcollectorABI.Types: C-ABI-compatible numeric representations of Logcollector types.
--
-- Maps every constructor of the core Logcollector sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/logcollector.zig) exactly.
--
-- Types covered:
--   LogLevel                  (6 constructors, tags 0-5)
--   InputFormat               (6 constructors, tags 0-5)
--   OutputTarget              (5 constructors, tags 0-4)
--   FilterOp                  (5 constructors, tags 0-4)
--   PipelineStage             (5 constructors, tags 0-4)
--   LogcollectorError         (7 constructors, tags 0-6)

module LogcollectorABI.Types

%default total

---------------------------------------------------------------------------
-- LogLevel (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
log_levelSize : Nat
log_levelSize = 1

||| LogLevel sum type for ABI encoding.
public export
data LogLevel : Type where
  Trace : LogLevel
  Debug : LogLevel
  Info : LogLevel
  Warn : LogLevel
  Err : LogLevel
  Fatal : LogLevel

||| Encode a LogLevel to its ABI tag value.
public export
log_levelToTag : LogLevel -> Bits8
log_levelToTag Trace = 0
log_levelToTag Debug = 1
log_levelToTag Info = 2
log_levelToTag Warn = 3
log_levelToTag Err = 4
log_levelToTag Fatal = 5

||| Decode an ABI tag to a LogLevel.
public export
tagToLogLevel : Bits8 -> Maybe LogLevel
tagToLogLevel 0 = Just Trace
tagToLogLevel 1 = Just Debug
tagToLogLevel 2 = Just Info
tagToLogLevel 3 = Just Warn
tagToLogLevel 4 = Just Err
tagToLogLevel 5 = Just Fatal
tagToLogLevel _ = Nothing

||| Roundtrip proof: decoding an encoded LogLevel yields the original.
public export
log_levelRoundtrip : (x : LogLevel) -> tagToLogLevel (log_levelToTag x) = Just x
log_levelRoundtrip Trace = Refl
log_levelRoundtrip Debug = Refl
log_levelRoundtrip Info = Refl
log_levelRoundtrip Warn = Refl
log_levelRoundtrip Err = Refl
log_levelRoundtrip Fatal = Refl

---------------------------------------------------------------------------
-- InputFormat (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
input_formatSize : Nat
input_formatSize = 1

||| InputFormat sum type for ABI encoding.
public export
data InputFormat : Type where
  Json : InputFormat
  Logfmt : InputFormat
  Syslog : InputFormat
  Cef : InputFormat
  Gelf : InputFormat
  Raw : InputFormat

||| Encode a InputFormat to its ABI tag value.
public export
input_formatToTag : InputFormat -> Bits8
input_formatToTag Json = 0
input_formatToTag Logfmt = 1
input_formatToTag Syslog = 2
input_formatToTag Cef = 3
input_formatToTag Gelf = 4
input_formatToTag Raw = 5

||| Decode an ABI tag to a InputFormat.
public export
tagToInputFormat : Bits8 -> Maybe InputFormat
tagToInputFormat 0 = Just Json
tagToInputFormat 1 = Just Logfmt
tagToInputFormat 2 = Just Syslog
tagToInputFormat 3 = Just Cef
tagToInputFormat 4 = Just Gelf
tagToInputFormat 5 = Just Raw
tagToInputFormat _ = Nothing

||| Roundtrip proof: decoding an encoded InputFormat yields the original.
public export
input_formatRoundtrip : (x : InputFormat) -> tagToInputFormat (input_formatToTag x) = Just x
input_formatRoundtrip Json = Refl
input_formatRoundtrip Logfmt = Refl
input_formatRoundtrip Syslog = Refl
input_formatRoundtrip Cef = Refl
input_formatRoundtrip Gelf = Refl
input_formatRoundtrip Raw = Refl

---------------------------------------------------------------------------
-- OutputTarget (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
output_targetSize : Nat
output_targetSize = 1

||| OutputTarget sum type for ABI encoding.
public export
data OutputTarget : Type where
  File : OutputTarget
  Elasticsearch : OutputTarget
  S3 : OutputTarget
  Kafka : OutputTarget
  Stdout : OutputTarget

||| Encode a OutputTarget to its ABI tag value.
public export
output_targetToTag : OutputTarget -> Bits8
output_targetToTag File = 0
output_targetToTag Elasticsearch = 1
output_targetToTag S3 = 2
output_targetToTag Kafka = 3
output_targetToTag Stdout = 4

||| Decode an ABI tag to a OutputTarget.
public export
tagToOutputTarget : Bits8 -> Maybe OutputTarget
tagToOutputTarget 0 = Just File
tagToOutputTarget 1 = Just Elasticsearch
tagToOutputTarget 2 = Just S3
tagToOutputTarget 3 = Just Kafka
tagToOutputTarget 4 = Just Stdout
tagToOutputTarget _ = Nothing

||| Roundtrip proof: decoding an encoded OutputTarget yields the original.
public export
output_targetRoundtrip : (x : OutputTarget) -> tagToOutputTarget (output_targetToTag x) = Just x
output_targetRoundtrip File = Refl
output_targetRoundtrip Elasticsearch = Refl
output_targetRoundtrip S3 = Refl
output_targetRoundtrip Kafka = Refl
output_targetRoundtrip Stdout = Refl

---------------------------------------------------------------------------
-- FilterOp (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
filter_opSize : Nat
filter_opSize = 1

||| FilterOp sum type for ABI encoding.
public export
data FilterOp : Type where
  Include : FilterOp
  Exclude : FilterOp
  Transform : FilterOp
  Redact : FilterOp
  Sample : FilterOp

||| Encode a FilterOp to its ABI tag value.
public export
filter_opToTag : FilterOp -> Bits8
filter_opToTag Include = 0
filter_opToTag Exclude = 1
filter_opToTag Transform = 2
filter_opToTag Redact = 3
filter_opToTag Sample = 4

||| Decode an ABI tag to a FilterOp.
public export
tagToFilterOp : Bits8 -> Maybe FilterOp
tagToFilterOp 0 = Just Include
tagToFilterOp 1 = Just Exclude
tagToFilterOp 2 = Just Transform
tagToFilterOp 3 = Just Redact
tagToFilterOp 4 = Just Sample
tagToFilterOp _ = Nothing

||| Roundtrip proof: decoding an encoded FilterOp yields the original.
public export
filter_opRoundtrip : (x : FilterOp) -> tagToFilterOp (filter_opToTag x) = Just x
filter_opRoundtrip Include = Refl
filter_opRoundtrip Exclude = Refl
filter_opRoundtrip Transform = Refl
filter_opRoundtrip Redact = Refl
filter_opRoundtrip Sample = Refl

---------------------------------------------------------------------------
-- PipelineStage (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
pipeline_stageSize : Nat
pipeline_stageSize = 1

||| PipelineStage sum type for ABI encoding.
public export
data PipelineStage : Type where
  Input : PipelineStage
  Parse : PipelineStage
  Filter : PipelineStage
  PipelineTransform : PipelineStage
  Output : PipelineStage

||| Encode a PipelineStage to its ABI tag value.
public export
pipeline_stageToTag : PipelineStage -> Bits8
pipeline_stageToTag Input = 0
pipeline_stageToTag Parse = 1
pipeline_stageToTag Filter = 2
pipeline_stageToTag PipelineTransform = 3
pipeline_stageToTag Output = 4

||| Decode an ABI tag to a PipelineStage.
public export
tagToPipelineStage : Bits8 -> Maybe PipelineStage
tagToPipelineStage 0 = Just Input
tagToPipelineStage 1 = Just Parse
tagToPipelineStage 2 = Just Filter
tagToPipelineStage 3 = Just PipelineTransform
tagToPipelineStage 4 = Just Output
tagToPipelineStage _ = Nothing

||| Roundtrip proof: decoding an encoded PipelineStage yields the original.
public export
pipeline_stageRoundtrip : (x : PipelineStage) -> tagToPipelineStage (pipeline_stageToTag x) = Just x
pipeline_stageRoundtrip Input = Refl
pipeline_stageRoundtrip Parse = Refl
pipeline_stageRoundtrip Filter = Refl
pipeline_stageRoundtrip PipelineTransform = Refl
pipeline_stageRoundtrip Output = Refl

---------------------------------------------------------------------------
-- LogcollectorError (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
logcollector_errorSize : Nat
logcollector_errorSize = 1

||| LogcollectorError sum type for ABI encoding.
public export
data LogcollectorError : Type where
  Ok : LogcollectorError
  InvalidSlot : LogcollectorError
  NotActive : LogcollectorError
  InvalidTransition : LogcollectorError
  BelowThreshold : LogcollectorError
  CapacityExhausted : LogcollectorError
  InvalidParam : LogcollectorError

||| Encode a LogcollectorError to its ABI tag value.
public export
logcollector_errorToTag : LogcollectorError -> Bits8
logcollector_errorToTag Ok = 0
logcollector_errorToTag InvalidSlot = 1
logcollector_errorToTag NotActive = 2
logcollector_errorToTag InvalidTransition = 3
logcollector_errorToTag BelowThreshold = 4
logcollector_errorToTag CapacityExhausted = 5
logcollector_errorToTag InvalidParam = 6

||| Decode an ABI tag to a LogcollectorError.
public export
tagToLogcollectorError : Bits8 -> Maybe LogcollectorError
tagToLogcollectorError 0 = Just Ok
tagToLogcollectorError 1 = Just InvalidSlot
tagToLogcollectorError 2 = Just NotActive
tagToLogcollectorError 3 = Just InvalidTransition
tagToLogcollectorError 4 = Just BelowThreshold
tagToLogcollectorError 5 = Just CapacityExhausted
tagToLogcollectorError 6 = Just InvalidParam
tagToLogcollectorError _ = Nothing

||| Roundtrip proof: decoding an encoded LogcollectorError yields the original.
public export
logcollector_errorRoundtrip : (x : LogcollectorError) -> tagToLogcollectorError (logcollector_errorToTag x) = Just x
logcollector_errorRoundtrip Ok = Refl
logcollector_errorRoundtrip InvalidSlot = Refl
logcollector_errorRoundtrip NotActive = Refl
logcollector_errorRoundtrip InvalidTransition = Refl
logcollector_errorRoundtrip BelowThreshold = Refl
logcollector_errorRoundtrip CapacityExhausted = Refl
logcollector_errorRoundtrip InvalidParam = Refl
