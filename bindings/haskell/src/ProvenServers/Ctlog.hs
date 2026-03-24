-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | CT Log types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Ctlog
  (
    LogEntryType(..)
  , logEntryTypeToTag
  , logEntryTypeFromTag
  , SignatureType(..)
  , signatureTypeToTag
  , signatureTypeFromTag
  , MerkleLeafType(..)
  , merkleLeafTypeToTag
  , merkleLeafTypeFromTag
  , SubmissionStatus(..)
  , submissionStatusToTag
  , submissionStatusFromTag
  , VerificationResult(..)
  , verificationResultToTag
  , verificationResultFromTag
  , ServerState(..)
  , serverStateToTag
  , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- LogEntryType
-- ---------------------------------------------------------------------------

-- | CT log entry types.
--
-- Tags 0-1 (2 constructors).
data LogEntryType
  = X509Entry  -- ^ X509Entry (tag 0).
  | PrecertEntry  -- ^ PrecertEntry (tag 1).
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

-- | CT signature types.
--
-- Tags 0-1 (2 constructors).
data SignatureType
  = CertificateTimestamp  -- ^ CertificateTimestamp (tag 0).
  | TreeHash  -- ^ TreeHash (tag 1).
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

-- | Merkle tree leaf types.
--
-- Tags 0-0 (1 constructors).
data MerkleLeafType
  = TimestampedEntry  -- ^ TimestampedEntry (tag 0).
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

-- | Certificate submission status.
--
-- Tags 0-5 (6 constructors).
data SubmissionStatus
  = Accepted  -- ^ Accepted (tag 0).
  | Duplicate  -- ^ Duplicate (tag 1).
  | RateLimited  -- ^ RateLimited (tag 2).
  | Rejected  -- ^ Rejected (tag 3).
  | InvalidChain  -- ^ InvalidChain (tag 4).
  | UnknownAnchor  -- ^ UnknownAnchor (tag 5).
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

-- | Proof verification results.
--
-- Tags 0-3 (4 constructors).
data VerificationResult
  = ValidProof  -- ^ ValidProof (tag 0).
  | InvalidProof  -- ^ InvalidProof (tag 1).
  | InconsistentTree  -- ^ InconsistentTree (tag 2).
  | StaleSth  -- ^ Stale STH (tag 3).
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

-- | CT log server states.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Idle (tag 0).
  | Active  -- ^ Active (tag 1).
  | Merging  -- ^ Merging (tag 2).
  | Signing  -- ^ Signing (tag 3).
  | Shutdown  -- ^ Shutdown (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServerState' to its ABI tag value.
serverStateToTag :: ServerState -> Word8
serverStateToTag = fromIntegral . fromEnum

-- | Decode a 'ServerState' from its ABI tag value.
serverStateFromTag :: Word8 -> Maybe ServerState
serverStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
