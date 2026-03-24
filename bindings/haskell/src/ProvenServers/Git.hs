-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Git Server types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Git
  (
    gitPort
  , Command(..)
  , commandToTag
  , commandFromTag
  , PacketType(..)
  , packetTypeToTag
  , packetTypeFromTag
  , RefType(..)
  , refTypeToTag
  , refTypeFromTag
  , Capability(..)
  , capabilityToTag
  , capabilityFromTag
  , HookResult(..)
  , hookResultToTag
  , hookResultFromTag
  , ServerState(..)
  , serverStateToTag
  , serverStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard Git daemon port.
gitPort :: Word16
gitPort = 9418

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Standard Git daemon port.
--
-- Tags 0-2 (3 constructors).
data Command
  = UploadPack  -- ^ git-upload-pack (tag 0).
  | ReceivePack  -- ^ git-receive-pack (tag 1).
  | UploadArchive  -- ^ git-upload-archive (tag 2).
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

-- | Git protocol packet types.
--
-- Tags 0-7 (8 constructors).
data PacketType
  = Flush  -- ^ Flush (tag 0).
  | Delimiter  -- ^ Delimiter (tag 1).
  | ResponseEnd  -- ^ ResponseEnd (tag 2).
  | Data  -- ^ Data (tag 3).
  | PktError  -- ^ Error packet (tag 4).
  | SidebandData  -- ^ SidebandData (tag 5).
  | SidebandProgress  -- ^ SidebandProgress (tag 6).
  | SidebandError  -- ^ SidebandError (tag 7).
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

-- | Git reference types.
--
-- Tags 0-4 (5 constructors).
data RefType
  = Branch  -- ^ Branch (tag 0).
  | Tag  -- ^ Tag (tag 1).
  | Head  -- ^ Head (tag 2).
  | Remote  -- ^ Remote (tag 3).
  | GitNote  -- ^ Note (tag 4).
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

-- | Git protocol capabilities.
--
-- Tags 0-8 (9 constructors).
data Capability
  = MultiAck  -- ^ MultiAck (tag 0).
  | ThinPack  -- ^ ThinPack (tag 1).
  | SideBand64k  -- ^ SideBand64k (tag 2).
  | OfsDelta  -- ^ OFS-delta (tag 3).
  | Shallow  -- ^ Shallow (tag 4).
  | DeepenSince  -- ^ DeepenSince (tag 5).
  | DeepenNot  -- ^ DeepenNot (tag 6).
  | FilterSpec  -- ^ FilterSpec (tag 7).
  | ObjectFormat  -- ^ ObjectFormat (tag 8).
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

-- | Git hook results.
--
-- Tags 0-1 (2 constructors).
data HookResult
  = Accept  -- ^ Accept (tag 0).
  | Reject  -- ^ Reject (tag 1).
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

-- | Git server states.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Idle (tag 0).
  | Discovery  -- ^ Discovery (tag 1).
  | Negotiating  -- ^ Negotiating (tag 2).
  | Transfer  -- ^ Transfer (tag 3).
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
