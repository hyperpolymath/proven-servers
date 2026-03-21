-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Git protocol types for proven-servers.
--
-- Git smart protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Git
  ( -- * ADT types matching Idris2 ABI
      Command(..)
    , PacketType(..)
    , RefType(..)
    , Capability(..)
    , HookResult(..)
    , ServerState(..)
    , commandToTag
    , commandFromTag
    , packetTypeToTag
    , packetTypeFromTag
    , refTypeToTag
    , refTypeFromTag
    , capabilityToTag
    , capabilityFromTag
    , hookResultToTag
    , hookResultFromTag
    , serverStateToTag
    , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Command type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data Command
  = UploadPack  -- ^ Tag 0.
  | ReceivePack  -- ^ Tag 1.
  | UploadArchive  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Command' to its ABI tag value.
commandToTag :: Command -> Word8
commandToTag = fromIntegral . fromEnum

-- | Decode a 'Command' from its ABI tag value.
commandFromTag :: Word8 -> Maybe Command
commandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Command)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PacketType
-- ---------------------------------------------------------------------------

-- | PacketType type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data PacketType
  = Flush  -- ^ Tag 0.
  | Delimiter  -- ^ Tag 1.
  | ResponseEnd  -- ^ Tag 2.
  | Data  -- ^ Tag 3.
  | PktError  -- ^ Tag 4.
  | SidebandData  -- ^ Tag 5.
  | SidebandProgress  -- ^ Tag 6.
  | SidebandError  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PacketType' to its ABI tag value.
packetTypeToTag :: PacketType -> Word8
packetTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PacketType' from its ABI tag value.
packetTypeFromTag :: Word8 -> Maybe PacketType
packetTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PacketType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- RefType
-- ---------------------------------------------------------------------------

-- | RefType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data RefType
  = Branch  -- ^ Tag 0.
  | Tag  -- ^ Tag 1.
  | Head  -- ^ Tag 2.
  | Remote  -- ^ Tag 3.
  | GitNote  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RefType' to its ABI tag value.
refTypeToTag :: RefType -> Word8
refTypeToTag = fromIntegral . fromEnum

-- | Decode a 'RefType' from its ABI tag value.
refTypeFromTag :: Word8 -> Maybe RefType
refTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RefType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Capability
-- ---------------------------------------------------------------------------

-- | Capability type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data Capability
  = MultiAck  -- ^ Tag 0.
  | ThinPack  -- ^ Tag 1.
  | SideBand64k  -- ^ Tag 2.
  | OfsDelta  -- ^ Tag 3.
  | Shallow  -- ^ Tag 4.
  | DeepenSince  -- ^ Tag 5.
  | DeepenNot  -- ^ Tag 6.
  | FilterSpec  -- ^ Tag 7.
  | ObjectFormat  -- ^ Tag 8.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Capability' to its ABI tag value.
capabilityToTag :: Capability -> Word8
capabilityToTag = fromIntegral . fromEnum

-- | Decode a 'Capability' from its ABI tag value.
capabilityFromTag :: Word8 -> Maybe Capability
capabilityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Capability)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HookResult
-- ---------------------------------------------------------------------------

-- | HookResult type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data HookResult
  = Accept  -- ^ Tag 0.
  | Reject  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HookResult' to its ABI tag value.
hookResultToTag :: HookResult -> Word8
hookResultToTag = fromIntegral . fromEnum

-- | Decode a 'HookResult' from its ABI tag value.
hookResultFromTag :: Word8 -> Maybe HookResult
hookResultFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HookResult)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ServerState
-- ---------------------------------------------------------------------------

-- | ServerState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Tag 0.
  | Discovery  -- ^ Tag 1.
  | Negotiating  -- ^ Tag 2.
  | Transfer  -- ^ Tag 3.
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
