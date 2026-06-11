-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- LogcollectorABI.Layout: C-ABI-compatible numeric representations of
-- log collector types.
--
-- Maps every constructor of the log collector domain types (LogLevel,
-- InputFormat, OutputTarget, FilterOp, PipelineStage) to fixed Bits8
-- values for C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- Tag values here MUST match the C header (generated/abi/logcollector.h)
-- and the Zig FFI enums (ffi/zig/src/logcollector.zig) exactly.

module LogcollectorABI.Layout

import Logcollector.Types

%default total

---------------------------------------------------------------------------
-- LogLevel (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for LogLevel (1 byte).
public export
logLevelSize : Nat
logLevelSize = 1

||| Map LogLevel to its C-ABI byte value.
public export
logLevelToTag : LogLevel -> Bits8
logLevelToTag Trace = 0
logLevelToTag Debug = 1
logLevelToTag Info  = 2
logLevelToTag Warn  = 3
logLevelToTag Error = 4
logLevelToTag Fatal = 5

||| Recover LogLevel from its C-ABI byte value.
public export
tagToLogLevel : Bits8 -> Maybe LogLevel
tagToLogLevel 0 = Just Trace
tagToLogLevel 1 = Just Debug
tagToLogLevel 2 = Just Info
tagToLogLevel 3 = Just Warn
tagToLogLevel 4 = Just Error
tagToLogLevel 5 = Just Fatal
tagToLogLevel _ = Nothing

||| Proof: encoding then decoding LogLevel is the identity.
public export
logLevelRoundtrip : (l : LogLevel) -> tagToLogLevel (logLevelToTag l) = Just l
logLevelRoundtrip Trace = Refl
logLevelRoundtrip Debug = Refl
logLevelRoundtrip Info  = Refl
logLevelRoundtrip Warn  = Refl
logLevelRoundtrip Error = Refl
logLevelRoundtrip Fatal = Refl

---------------------------------------------------------------------------
-- InputFormat (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for InputFormat (1 byte).
public export
inputFormatSize : Nat
inputFormatSize = 1

||| Map InputFormat to its C-ABI byte value.
public export
inputFormatToTag : InputFormat -> Bits8
inputFormatToTag JSON   = 0
inputFormatToTag Logfmt = 1
inputFormatToTag Syslog = 2
inputFormatToTag CEF    = 3
inputFormatToTag GELF   = 4
inputFormatToTag Raw    = 5

||| Recover InputFormat from its C-ABI byte value.
public export
tagToInputFormat : Bits8 -> Maybe InputFormat
tagToInputFormat 0 = Just JSON
tagToInputFormat 1 = Just Logfmt
tagToInputFormat 2 = Just Syslog
tagToInputFormat 3 = Just CEF
tagToInputFormat 4 = Just GELF
tagToInputFormat 5 = Just Raw
tagToInputFormat _ = Nothing

||| Proof: encoding then decoding InputFormat is the identity.
public export
inputFormatRoundtrip : (f : InputFormat) -> tagToInputFormat (inputFormatToTag f) = Just f
inputFormatRoundtrip JSON   = Refl
inputFormatRoundtrip Logfmt = Refl
inputFormatRoundtrip Syslog = Refl
inputFormatRoundtrip CEF    = Refl
inputFormatRoundtrip GELF   = Refl
inputFormatRoundtrip Raw    = Refl

---------------------------------------------------------------------------
-- OutputTarget (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for OutputTarget (1 byte).
public export
outputTargetSize : Nat
outputTargetSize = 1

||| Map OutputTarget to its C-ABI byte value.
public export
outputTargetToTag : OutputTarget -> Bits8
outputTargetToTag File          = 0
outputTargetToTag Elasticsearch = 1
outputTargetToTag S3            = 2
outputTargetToTag Kafka         = 3
outputTargetToTag Stdout        = 4

||| Recover OutputTarget from its C-ABI byte value.
public export
tagToOutputTarget : Bits8 -> Maybe OutputTarget
tagToOutputTarget 0 = Just File
tagToOutputTarget 1 = Just Elasticsearch
tagToOutputTarget 2 = Just S3
tagToOutputTarget 3 = Just Kafka
tagToOutputTarget 4 = Just Stdout
tagToOutputTarget _ = Nothing

||| Proof: encoding then decoding OutputTarget is the identity.
public export
outputTargetRoundtrip : (t : OutputTarget) -> tagToOutputTarget (outputTargetToTag t) = Just t
outputTargetRoundtrip File          = Refl
outputTargetRoundtrip Elasticsearch = Refl
outputTargetRoundtrip S3            = Refl
outputTargetRoundtrip Kafka         = Refl
outputTargetRoundtrip Stdout        = Refl

---------------------------------------------------------------------------
-- FilterOp (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for FilterOp (1 byte).
public export
filterOpSize : Nat
filterOpSize = 1

||| Map FilterOp to its C-ABI byte value.
public export
filterOpToTag : FilterOp -> Bits8
filterOpToTag Include   = 0
filterOpToTag Exclude   = 1
filterOpToTag Transform = 2
filterOpToTag Redact    = 3
filterOpToTag Sample    = 4

||| Recover FilterOp from its C-ABI byte value.
public export
tagToFilterOp : Bits8 -> Maybe FilterOp
tagToFilterOp 0 = Just Include
tagToFilterOp 1 = Just Exclude
tagToFilterOp 2 = Just Transform
tagToFilterOp 3 = Just Redact
tagToFilterOp 4 = Just Sample
tagToFilterOp _ = Nothing

||| Proof: encoding then decoding FilterOp is the identity.
public export
filterOpRoundtrip : (f : FilterOp) -> tagToFilterOp (filterOpToTag f) = Just f
filterOpRoundtrip Include   = Refl
filterOpRoundtrip Exclude   = Refl
filterOpRoundtrip Transform = Refl
filterOpRoundtrip Redact    = Refl
filterOpRoundtrip Sample    = Refl

---------------------------------------------------------------------------
-- PipelineStage (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for PipelineStage (1 byte).
public export
pipelineStageSize : Nat
pipelineStageSize = 1

||| Map PipelineStage to its C-ABI byte value.
public export
pipelineStageToTag : PipelineStage -> Bits8
pipelineStageToTag Input      = 0
pipelineStageToTag Parse      = 1
pipelineStageToTag Filter     = 2
pipelineStageToTag PTransform = 3
pipelineStageToTag Output     = 4

||| Recover PipelineStage from its C-ABI byte value.
public export
tagToPipelineStage : Bits8 -> Maybe PipelineStage
tagToPipelineStage 0 = Just Input
tagToPipelineStage 1 = Just Parse
tagToPipelineStage 2 = Just Filter
tagToPipelineStage 3 = Just PTransform
tagToPipelineStage 4 = Just Output
tagToPipelineStage _ = Nothing

||| Proof: encoding then decoding PipelineStage is the identity.
public export
pipelineStageRoundtrip : (s : PipelineStage) -> tagToPipelineStage (pipelineStageToTag s) = Just s
pipelineStageRoundtrip Input      = Refl
pipelineStageRoundtrip Parse      = Refl
pipelineStageRoundtrip Filter     = Refl
pipelineStageRoundtrip PTransform = Refl
pipelineStageRoundtrip Output     = Refl

---------------------------------------------------------------------------
-- LogcollectorError (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| Error codes for log collector FFI operations.
public export
data LogcollectorError : Type where
  ||| No error.
  LcOk                : LogcollectorError
  ||| Invalid slot index.
  LcInvalidSlot       : LogcollectorError
  ||| Pipeline not active.
  LcNotActive         : LogcollectorError
  ||| Invalid pipeline stage transition.
  LcInvalidTransition : LogcollectorError
  ||| Log level below minimum threshold (dropped).
  LcBelowThreshold    : LogcollectorError
  ||| Pipeline buffer capacity exhausted.
  LcCapacityExhausted : LogcollectorError
  ||| Invalid parameter value.
  LcInvalidParam      : LogcollectorError

public export
Eq LogcollectorError where
  LcOk                == LcOk                = True
  LcInvalidSlot       == LcInvalidSlot       = True
  LcNotActive         == LcNotActive         = True
  LcInvalidTransition == LcInvalidTransition = True
  LcBelowThreshold    == LcBelowThreshold    = True
  LcCapacityExhausted == LcCapacityExhausted = True
  LcInvalidParam      == LcInvalidParam      = True
  _                   == _                   = False

public export
Show LogcollectorError where
  show LcOk                = "Ok"
  show LcInvalidSlot       = "InvalidSlot"
  show LcNotActive         = "NotActive"
  show LcInvalidTransition = "InvalidTransition"
  show LcBelowThreshold    = "BelowThreshold"
  show LcCapacityExhausted = "CapacityExhausted"
  show LcInvalidParam      = "InvalidParam"

||| C-ABI representation size for LogcollectorError (1 byte).
public export
logcollectorErrorSize : Nat
logcollectorErrorSize = 1

||| Map LogcollectorError to its C-ABI byte value.
public export
logcollectorErrorToTag : LogcollectorError -> Bits8
logcollectorErrorToTag LcOk                = 0
logcollectorErrorToTag LcInvalidSlot       = 1
logcollectorErrorToTag LcNotActive         = 2
logcollectorErrorToTag LcInvalidTransition = 3
logcollectorErrorToTag LcBelowThreshold    = 4
logcollectorErrorToTag LcCapacityExhausted = 5
logcollectorErrorToTag LcInvalidParam      = 6

||| Recover LogcollectorError from its C-ABI byte value.
public export
tagToLogcollectorError : Bits8 -> Maybe LogcollectorError
tagToLogcollectorError 0 = Just LcOk
tagToLogcollectorError 1 = Just LcInvalidSlot
tagToLogcollectorError 2 = Just LcNotActive
tagToLogcollectorError 3 = Just LcInvalidTransition
tagToLogcollectorError 4 = Just LcBelowThreshold
tagToLogcollectorError 5 = Just LcCapacityExhausted
tagToLogcollectorError 6 = Just LcInvalidParam
tagToLogcollectorError _ = Nothing

||| Proof: encoding then decoding LogcollectorError is the identity.
public export
logcollectorErrorRoundtrip : (e : LogcollectorError) -> tagToLogcollectorError (logcollectorErrorToTag e) = Just e
logcollectorErrorRoundtrip LcOk                = Refl
logcollectorErrorRoundtrip LcInvalidSlot       = Refl
logcollectorErrorRoundtrip LcNotActive         = Refl
logcollectorErrorRoundtrip LcInvalidTransition = Refl
logcollectorErrorRoundtrip LcBelowThreshold    = Refl
logcollectorErrorRoundtrip LcCapacityExhausted = Refl
logcollectorErrorRoundtrip LcInvalidParam      = Refl
