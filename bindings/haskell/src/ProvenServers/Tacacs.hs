-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | TACACS+ protocol types for proven-servers.
--
-- TACACS+ authentication types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Tacacs
  ( -- * ADT types matching Idris2 ABI
      PacketType(..)
    , AuthenType(..)
    , AuthenAction(..)
    , AuthenStatus(..)
    , AuthorStatus(..)
    , AcctStatus(..)
    , AcctFlag(..)
    , SessionState(..)
    , packetTypeToTag
    , packetTypeFromTag
    , authenTypeToTag
    , authenTypeFromTag
    , authenActionToTag
    , authenActionFromTag
    , authenStatusToTag
    , authenStatusFromTag
    , authorStatusToTag
    , authorStatusFromTag
    , acctStatusToTag
    , acctStatusFromTag
    , acctFlagToTag
    , acctFlagFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- PacketType
-- ---------------------------------------------------------------------------

-- | PacketType type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data PacketType
  = Authentication  -- ^ Tag 0.
  | Authorization  -- ^ Tag 1.
  | Accounting  -- ^ Tag 2.
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
-- AuthenType
-- ---------------------------------------------------------------------------

-- | AuthenType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data AuthenType
  = Ascii  -- ^ Tag 0.
  | Pap  -- ^ Tag 1.
  | Chap  -- ^ Tag 2.
  | MsChapV1  -- ^ Tag 3.
  | MsChapV2  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthenType' to its ABI tag value.
authenTypeToTag :: AuthenType -> Word8
authenTypeToTag = fromIntegral . fromEnum

-- | Decode a 'AuthenType' from its ABI tag value.
authenTypeFromTag :: Word8 -> Maybe AuthenType
authenTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthenType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AuthenAction
-- ---------------------------------------------------------------------------

-- | AuthenAction type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data AuthenAction
  = Login  -- ^ Tag 0.
  | ChangePass  -- ^ Tag 1.
  | SendAuth  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthenAction' to its ABI tag value.
authenActionToTag :: AuthenAction -> Word8
authenActionToTag = fromIntegral . fromEnum

-- | Decode a 'AuthenAction' from its ABI tag value.
authenActionFromTag :: Word8 -> Maybe AuthenAction
authenActionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthenAction)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AuthenStatus
-- ---------------------------------------------------------------------------

-- | AuthenStatus type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data AuthenStatus
  = Pass  -- ^ Tag 0.
  | AuthenStatus_Fail  -- ^ Tag 1.
  | GetData  -- ^ Tag 2.
  | GetUser  -- ^ Tag 3.
  | GetPass  -- ^ Tag 4.
  | Restart  -- ^ Tag 5.
  | AuthenStatus_Error  -- ^ Tag 6.
  | AuthenStatus_Follow  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthenStatus' to its ABI tag value.
authenStatusToTag :: AuthenStatus -> Word8
authenStatusToTag = fromIntegral . fromEnum

-- | Decode a 'AuthenStatus' from its ABI tag value.
authenStatusFromTag :: Word8 -> Maybe AuthenStatus
authenStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthenStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AuthorStatus
-- ---------------------------------------------------------------------------

-- | AuthorStatus type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data AuthorStatus
  = PassAdd  -- ^ Tag 0.
  | PassRepl  -- ^ Tag 1.
  | AuthorStatus_Fail  -- ^ Tag 2.
  | AuthorStatus_Error  -- ^ Tag 3.
  | AuthorStatus_Follow  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthorStatus' to its ABI tag value.
authorStatusToTag :: AuthorStatus -> Word8
authorStatusToTag = fromIntegral . fromEnum

-- | Decode a 'AuthorStatus' from its ABI tag value.
authorStatusFromTag :: Word8 -> Maybe AuthorStatus
authorStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthorStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AcctStatus
-- ---------------------------------------------------------------------------

-- | AcctStatus type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data AcctStatus
  = Success  -- ^ Tag 0.
  | AcctStatus_Error  -- ^ Tag 1.
  | AcctStatus_Follow  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AcctStatus' to its ABI tag value.
acctStatusToTag :: AcctStatus -> Word8
acctStatusToTag = fromIntegral . fromEnum

-- | Decode a 'AcctStatus' from its ABI tag value.
acctStatusFromTag :: Word8 -> Maybe AcctStatus
acctStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AcctStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AcctFlag
-- ---------------------------------------------------------------------------

-- | AcctFlag type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data AcctFlag
  = Start  -- ^ Tag 0.
  | Stop  -- ^ Tag 1.
  | Watchdog  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AcctFlag' to its ABI tag value.
acctFlagToTag :: AcctFlag -> Word8
acctFlagToTag = fromIntegral . fromEnum

-- | Decode a 'AcctFlag' from its ABI tag value.
acctFlagFromTag :: Word8 -> Maybe AcctFlag
acctFlagFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AcctFlag)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Authenticating  -- ^ Tag 1.
  | Authorizing  -- ^ Tag 2.
  | Active  -- ^ Tag 3.
  | Closing  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
