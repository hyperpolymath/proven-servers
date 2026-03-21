-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Log Collector protocol types for proven-servers.
--
-- Log collection/pipeline types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Logcollector
  ( -- * ADT types matching Idris2 ABI
      LogLevel(..)
    , InputFormat(..)
    , OutputTarget(..)
    , FilterOp(..)
    , PipelineStage(..)
    , logLevelToTag
    , logLevelFromTag
    , inputFormatToTag
    , inputFormatFromTag
    , outputTargetToTag
    , outputTargetFromTag
    , filterOpToTag
    , filterOpFromTag
    , pipelineStageToTag
    , pipelineStageFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- LogLevel
-- ---------------------------------------------------------------------------

-- | LogLevel type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data LogLevel
  = Trace  -- ^ Tag 0.
  | Debug  -- ^ Tag 1.
  | Info  -- ^ Tag 2.
  | Warn  -- ^ Tag 3.
  | Err  -- ^ Tag 4.
  | Fatal  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LogLevel' to its ABI tag value.
logLevelToTag :: LogLevel -> Word8
logLevelToTag = fromIntegral . fromEnum

-- | Decode a 'LogLevel' from its ABI tag value.
logLevelFromTag :: Word8 -> Maybe LogLevel
logLevelFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LogLevel)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- InputFormat
-- ---------------------------------------------------------------------------

-- | InputFormat type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data InputFormat
  = Json  -- ^ Tag 0.
  | Logfmt  -- ^ Tag 1.
  | Syslog  -- ^ Tag 2.
  | Cef  -- ^ Tag 3.
  | Gelf  -- ^ Tag 4.
  | Raw  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'InputFormat' to its ABI tag value.
inputFormatToTag :: InputFormat -> Word8
inputFormatToTag = fromIntegral . fromEnum

-- | Decode a 'InputFormat' from its ABI tag value.
inputFormatFromTag :: Word8 -> Maybe InputFormat
inputFormatFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: InputFormat)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- OutputTarget
-- ---------------------------------------------------------------------------

-- | OutputTarget type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data OutputTarget
  = File  -- ^ Tag 0.
  | Elasticsearch  -- ^ Tag 1.
  | S3  -- ^ Tag 2.
  | Kafka  -- ^ Tag 3.
  | Stdout  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'OutputTarget' to its ABI tag value.
outputTargetToTag :: OutputTarget -> Word8
outputTargetToTag = fromIntegral . fromEnum

-- | Decode a 'OutputTarget' from its ABI tag value.
outputTargetFromTag :: Word8 -> Maybe OutputTarget
outputTargetFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: OutputTarget)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- FilterOp
-- ---------------------------------------------------------------------------

-- | FilterOp type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data FilterOp
  = Include  -- ^ Tag 0.
  | Exclude  -- ^ Tag 1.
  | Transform  -- ^ Tag 2.
  | Redact  -- ^ Tag 3.
  | Sample  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'FilterOp' to its ABI tag value.
filterOpToTag :: FilterOp -> Word8
filterOpToTag = fromIntegral . fromEnum

-- | Decode a 'FilterOp' from its ABI tag value.
filterOpFromTag :: Word8 -> Maybe FilterOp
filterOpFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FilterOp)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PipelineStage
-- ---------------------------------------------------------------------------

-- | PipelineStage type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data PipelineStage
  = Input  -- ^ Tag 0.
  | Parse  -- ^ Tag 1.
  | Filter  -- ^ Tag 2.
  | PipelineTransform  -- ^ Tag 3.
  | Output  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PipelineStage' to its ABI tag value.
pipelineStageToTag :: PipelineStage -> Word8
pipelineStageToTag = fromIntegral . fromEnum

-- | Decode a 'PipelineStage' from its ABI tag value.
pipelineStageFromTag :: Word8 -> Maybe PipelineStage
pipelineStageFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PipelineStage)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
