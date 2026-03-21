-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | BGP protocol types for proven-servers.
--
-- BGP (Border Gateway Protocol) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Bgp
  ( -- * ADT types matching Idris2 ABI
      BgpState(..)
    , BgpEvent(..)
    , MessageType(..)
    , ErrorCode(..)
    , Origin(..)
    , AsPathSegmentType(..)
    , PathAttrType(..)
    , bgpStateToTag
    , bgpStateFromTag
    , bgpEventToTag
    , bgpEventFromTag
    , messageTypeToTag
    , messageTypeFromTag
    , errorCodeToTag
    , errorCodeFromTag
    , originToTag
    , originFromTag
    , asPathSegmentTypeToTag
    , asPathSegmentTypeFromTag
    , pathAttrTypeToTag
    , pathAttrTypeFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- BgpState
-- ---------------------------------------------------------------------------

-- | BgpState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data BgpState
  = Idle  -- ^ Tag 0.
  | Connect  -- ^ Tag 1.
  | Active  -- ^ Tag 2.
  | OpenSent  -- ^ Tag 3.
  | OpenConfirm  -- ^ Tag 4.
  | Established  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BgpState' to its ABI tag value.
bgpStateToTag :: BgpState -> Word8
bgpStateToTag = fromIntegral . fromEnum

-- | Decode a 'BgpState' from its ABI tag value.
bgpStateFromTag :: Word8 -> Maybe BgpState
bgpStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BgpState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- BgpEvent
-- ---------------------------------------------------------------------------

-- | BgpEvent type matching the Idris2 ABI.
--
-- Tags 0-18 (19 constructors).
data BgpEvent
  = ManualStart  -- ^ Tag 0.
  | ManualStop  -- ^ Tag 1.
  | AutomaticStart  -- ^ Tag 2.
  | ConnectRetryTimerExpires  -- ^ Tag 3.
  | HoldTimerExpires  -- ^ Tag 4.
  | KeepaliveTimerExpires  -- ^ Tag 5.
  | DelayOpenTimerExpires  -- ^ Tag 6.
  | TcpConnectionValid  -- ^ Tag 7.
  | TcpCrAcked  -- ^ Tag 8.
  | TcpConnectionConfirmed  -- ^ Tag 9.
  | TcpConnectionFails  -- ^ Tag 10.
  | BgpOpenReceived  -- ^ Tag 11.
  | BgpHeaderErr  -- ^ Tag 12.
  | BgpOpenMsgErr  -- ^ Tag 13.
  | NotifMsgVerErr  -- ^ Tag 14.
  | NotifMsg  -- ^ Tag 15.
  | KeepaliveMsg  -- ^ Tag 16.
  | UpdateMsg  -- ^ Tag 17.
  | UpdateMsgErr  -- ^ Tag 18.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BgpEvent' to its ABI tag value.
bgpEventToTag :: BgpEvent -> Word8
bgpEventToTag = fromIntegral . fromEnum

-- | Decode a 'BgpEvent' from its ABI tag value.
bgpEventFromTag :: Word8 -> Maybe BgpEvent
bgpEventFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BgpEvent)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | MessageType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data MessageType
  = Open  -- ^ Tag 0.
  | Update  -- ^ Tag 1.
  | Notification  -- ^ Tag 2.
  | Keepalive  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MessageType' to its ABI tag value.
messageTypeToTag :: MessageType -> Word8
messageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MessageType' from its ABI tag value.
messageTypeFromTag :: Word8 -> Maybe MessageType
messageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorCode
-- ---------------------------------------------------------------------------

-- | ErrorCode type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ErrorCode
  = MessageHeaderError  -- ^ Tag 0.
  | OpenMessageError  -- ^ Tag 1.
  | UpdateMessageError  -- ^ Tag 2.
  | HoldTimerExpired  -- ^ Tag 3.
  | FsmError  -- ^ Tag 4.
  | Cease  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCode' to its ABI tag value.
errorCodeToTag :: ErrorCode -> Word8
errorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCode' from its ABI tag value.
errorCodeFromTag :: Word8 -> Maybe ErrorCode
errorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Origin
-- ---------------------------------------------------------------------------

-- | Origin type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data Origin
  = Igp  -- ^ Tag 0.
  | Egp  -- ^ Tag 1.
  | Incomplete  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Origin' to its ABI tag value.
originToTag :: Origin -> Word8
originToTag = fromIntegral . fromEnum

-- | Decode a 'Origin' from its ABI tag value.
originFromTag :: Word8 -> Maybe Origin
originFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Origin)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AsPathSegmentType
-- ---------------------------------------------------------------------------

-- | AsPathSegmentType type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data AsPathSegmentType
  = AsSet  -- ^ Tag 0.
  | AsSequence  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AsPathSegmentType' to its ABI tag value.
asPathSegmentTypeToTag :: AsPathSegmentType -> Word8
asPathSegmentTypeToTag = fromIntegral . fromEnum

-- | Decode a 'AsPathSegmentType' from its ABI tag value.
asPathSegmentTypeFromTag :: Word8 -> Maybe AsPathSegmentType
asPathSegmentTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AsPathSegmentType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PathAttrType
-- ---------------------------------------------------------------------------

-- | PathAttrType type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data PathAttrType
  = Origin  -- ^ Tag 0.
  | AsPath  -- ^ Tag 1.
  | NextHop  -- ^ Tag 2.
  | Med  -- ^ Tag 3.
  | LocalPref  -- ^ Tag 4.
  | AtomicAggr  -- ^ Tag 5.
  | Aggregator  -- ^ Tag 6.
  | Unknown  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PathAttrType' to its ABI tag value.
pathAttrTypeToTag :: PathAttrType -> Word8
pathAttrTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PathAttrType' from its ABI tag value.
pathAttrTypeFromTag :: Word8 -> Maybe PathAttrType
pathAttrTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PathAttrType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
