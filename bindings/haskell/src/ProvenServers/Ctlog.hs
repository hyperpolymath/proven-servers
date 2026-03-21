-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | CT Log protocol types for proven-servers.
--
-- Certificate Transparency log types (RFC 6962), mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Ctlog
  ( -- * ADT types matching Idris2 ABI
      LogEntryType(..)
    , SignatureType(..)
    , MerkleLeafType(..)
    , SubmissionStatus(..)
    , VerificationResult(..)
    , ServerState(..)
    , logEntryTypeToTag
    , logEntryTypeFromTag
    , signatureTypeToTag
    , signatureTypeFromTag
    , merkleLeafTypeToTag
    , merkleLeafTypeFromTag
    , submissionStatusToTag
    , submissionStatusFromTag
    , verificationResultToTag
    , verificationResultFromTag
    , serverStateToTag
    , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- LogEntryType
-- ---------------------------------------------------------------------------

-- | LogEntryType type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data LogEntryType
  = X509Entry  -- ^ Tag 0.
  | PrecertEntry  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LogEntryType' to its ABI tag value.
logEntryTypeToTag :: LogEntryType -> Word8
logEntryTypeToTag = fromIntegral . fromEnum

-- | Decode a 'LogEntryType' from its ABI tag value.
logEntryTypeFromTag :: Word8 -> Maybe LogEntryType
logEntryTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LogEntryType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SignatureType
-- ---------------------------------------------------------------------------

-- | SignatureType type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data SignatureType
  = CertificateTimestamp  -- ^ Tag 0.
  | TreeHash  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SignatureType' to its ABI tag value.
signatureTypeToTag :: SignatureType -> Word8
signatureTypeToTag = fromIntegral . fromEnum

-- | Decode a 'SignatureType' from its ABI tag value.
signatureTypeFromTag :: Word8 -> Maybe SignatureType
signatureTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SignatureType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- MerkleLeafType
-- ---------------------------------------------------------------------------

-- | MerkleLeafType type matching the Idris2 ABI.
--
-- Tags 0-0 (1 constructors).
data MerkleLeafType
  = TimestampedEntry  -- ^ Tag 0.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MerkleLeafType' to its ABI tag value.
merkleLeafTypeToTag :: MerkleLeafType -> Word8
merkleLeafTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MerkleLeafType' from its ABI tag value.
merkleLeafTypeFromTag :: Word8 -> Maybe MerkleLeafType
merkleLeafTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MerkleLeafType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SubmissionStatus
-- ---------------------------------------------------------------------------

-- | SubmissionStatus type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data SubmissionStatus
  = Accepted  -- ^ Tag 0.
  | Duplicate  -- ^ Tag 1.
  | RateLimited  -- ^ Tag 2.
  | Rejected  -- ^ Tag 3.
  | InvalidChain  -- ^ Tag 4.
  | UnknownAnchor  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SubmissionStatus' to its ABI tag value.
submissionStatusToTag :: SubmissionStatus -> Word8
submissionStatusToTag = fromIntegral . fromEnum

-- | Decode a 'SubmissionStatus' from its ABI tag value.
submissionStatusFromTag :: Word8 -> Maybe SubmissionStatus
submissionStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SubmissionStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- VerificationResult
-- ---------------------------------------------------------------------------

-- | VerificationResult type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data VerificationResult
  = ValidProof  -- ^ Tag 0.
  | InvalidProof  -- ^ Tag 1.
  | InconsistentTree  -- ^ Tag 2.
  | StaleSth  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'VerificationResult' to its ABI tag value.
verificationResultToTag :: VerificationResult -> Word8
verificationResultToTag = fromIntegral . fromEnum

-- | Decode a 'VerificationResult' from its ABI tag value.
verificationResultFromTag :: Word8 -> Maybe VerificationResult
verificationResultFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: VerificationResult)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ServerState
-- ---------------------------------------------------------------------------

-- | ServerState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Tag 0.
  | Active  -- ^ Tag 1.
  | Merging  -- ^ Tag 2.
  | Signing  -- ^ Tag 3.
  | Shutdown  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServerState' to its ABI tag value.
serverStateToTag :: ServerState -> Word8
serverStateToTag = fromIntegral . fromEnum

-- | Decode a 'ServerState' from its ABI tag value.
serverStateFromTag :: Word8 -> Maybe ServerState
serverStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
