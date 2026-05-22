-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Log Collector types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Logcollector
  (
    LogLevel(..)
  , logLevelToTag
  , logLevelFromTag
  , InputFormat(..)
  , inputFormatToTag
  , inputFormatFromTag
  , OutputTarget(..)
  , outputTargetToTag
  , outputTargetFromTag
  , FilterOp(..)
  , filterOpToTag
  , filterOpFromTag
  , PipelineStage(..)
  , pipelineStageToTag
  , pipelineStageFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- LogLevel
-- ---------------------------------------------------------------------------

-- | Log severity levels.
--
-- Tags 0-5 (6 constructors).
data LogLevel
  = Trace  -- ^ Trace (tag 0).
  | Debug  -- ^ Debug (tag 1).
  | Info  -- ^ Info (tag 2).
  | Warn  -- ^ Warn (tag 3).
  | Err  -- ^ Error (tag 4).
  | Fatal  -- ^ Fatal (tag 5).
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

-- | Log input formats.
--
-- Tags 0-5 (6 constructors).
data InputFormat
  = Json  -- ^ JSON (tag 0).
  | Logfmt  -- ^ Logfmt (tag 1).
  | Syslog  -- ^ Syslog (tag 2).
  | Cef  -- ^ CEF (tag 3).
  | Gelf  -- ^ GELF (tag 4).
  | Raw  -- ^ Raw (tag 5).
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

-- | Log output targets.
--
-- Tags 0-4 (5 constructors).
data OutputTarget
  = File  -- ^ File (tag 0).
  | Elasticsearch  -- ^ Elasticsearch (tag 1).
  | S3  -- ^ S3 (tag 2).
  | Kafka  -- ^ Kafka (tag 3).
  | Stdout  -- ^ Stdout (tag 4).
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

-- | Log filter operations.
--
-- Tags 0-4 (5 constructors).
data FilterOp
  = Include  -- ^ Include (tag 0).
  | Exclude  -- ^ Exclude (tag 1).
  | Transform  -- ^ Transform (tag 2).
  | Redact  -- ^ Redact (tag 3).
  | Sample  -- ^ Sample (tag 4).
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

-- | Log pipeline stages.
--
-- Tags 0-4 (5 constructors).
data PipelineStage
  = Input  -- ^ Input (tag 0).
  | Parse  -- ^ Parse (tag 1).
  | Filter  -- ^ Filter (tag 2).
  | PipelineTransform  -- ^ Transform (tag 3).
  | Output  -- ^ Output (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PipelineStage' to its ABI tag value.
pipelineStageToTag :: PipelineStage -> Word8
pipelineStageToTag = fromIntegral . fromEnum

-- | Decode a 'PipelineStage' from its ABI tag value.
pipelineStageFromTag :: Word8 -> Maybe PipelineStage
pipelineStageFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PipelineStage)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
