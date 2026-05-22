-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | BGP protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Bgp
  (
    bgpPort
  , BgpState(..)
  , bgpStateToTag
  , bgpStateFromTag
  , isRouteExchange
  , hasConnection
  , BgpEvent(..)
  , bgpEventToTag
  , bgpEventFromTag
  , isTimerEvent
  , isErrorEvent
  , MessageType(..)
  , messageTypeToTag
  , messageTypeFromTag
  , ErrorCode(..)
  , errorCodeToTag
  , errorCodeFromTag
  , isFatal
  , Origin(..)
  , originToTag
  , originFromTag
  , AsPathSegmentType(..)
  , asPathSegmentTypeToTag
  , asPathSegmentTypeFromTag
  , PathAttrType(..)
  , pathAttrTypeToTag
  , pathAttrTypeFromTag
  , isMandatory
  ) where

import Data.Word (Word16, Word8)

-- | Standard BGP port (RFC 4271).
bgpPort :: Word16
bgpPort = 179

-- ---------------------------------------------------------------------------
-- BgpState
-- ---------------------------------------------------------------------------

-- | Standard BGP port (RFC 4271).
--
-- Tags 0-5 (6 constructors).
data BgpState
  = Idle  -- ^ Idle — initial state, no connection (tag 0).
  | Connect  -- ^ Connect — waiting for TCP connection (tag 1).
  | Active  -- ^ Active — retrying TCP connection (tag 2).
  | OpenSent  -- ^ OpenSent — OPEN message sent, awaiting OPEN (tag 3).
  | OpenConfirm  -- ^ OpenConfirm — OPEN received, awaiting KEEPALIVE (tag 4).
  | Established  -- ^ Established — peers exchanging UPDATE messages (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BgpState' to its ABI tag value.
bgpStateToTag :: BgpState -> Word8
bgpStateToTag = fromIntegral . fromEnum

-- | Decode a 'BgpState' from its ABI tag value.
bgpStateFromTag :: Word8 -> Maybe BgpState
bgpStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BgpState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether routes can be exchanged in this state.
isRouteExchange :: BgpState -> Bool
isRouteExchange Established = True
isRouteExchange _ = False

-- | Whether a TCP connection exists in this state.
hasConnection :: BgpState -> Bool
hasConnection OpenSent = True
hasConnection OpenConfirm = True
hasConnection Established = True
hasConnection _ = False

-- ---------------------------------------------------------------------------
-- BgpEvent
-- ---------------------------------------------------------------------------

-- | BGP FSM events (RFC 4271 Section 8.1).
--
-- Tags 0-18 (19 constructors).
data BgpEvent
  = ManualStart  -- ^ ManualStart — administrative start (tag 0).
  | ManualStop  -- ^ ManualStop — administrative stop (tag 1).
  | AutomaticStart  -- ^ AutomaticStart — automatic restart (tag 2).
  | ConnectRetryTimerExpires  -- ^ ConnectRetryTimer_Expires (tag 3).
  | HoldTimerExpires  -- ^ HoldTimer_Expires (tag 4).
  | KeepaliveTimerExpires  -- ^ KeepaliveTimer_Expires (tag 5).
  | DelayOpenTimerExpires  -- ^ DelayOpenTimer_Expires (tag 6).
  | TcpConnectionValid  -- ^ Tcp_CR_Valid — valid incoming TCP connection (tag 7).
  | TcpCrAcked  -- ^ Tcp_CR_Acked — outgoing TCP connection acknowledged (tag 8).
  | TcpConnectionConfirmed  -- ^ TcpConnectionConfirmed (tag 9).
  | TcpConnectionFails  -- ^ TcpConnectionFails (tag 10).
  | BgpOpenReceived  -- ^ BGPOpen received (tag 11).
  | BgpHeaderErr  -- ^ BGPHeaderErr — bad header received (tag 12).
  | BgpOpenMsgErr  -- ^ BGPOpenMsgErr — bad OPEN received (tag 13).
  | NotifMsgVerErr  -- ^ NotifMsgVerErr — NOTIFICATION version error (tag 14).
  | NotifMsg  -- ^ NotifMsg — NOTIFICATION received (tag 15).
  | KeepaliveMsg  -- ^ KeepaliveMsg — KEEPALIVE received (tag 16).
  | UpdateMsg  -- ^ UpdateMsg — UPDATE received (tag 17).
  | UpdateMsgErr  -- ^ UpdateMsgErr — bad UPDATE received (tag 18).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BgpEvent' to its ABI tag value.
bgpEventToTag :: BgpEvent -> Word8
bgpEventToTag = fromIntegral . fromEnum

-- | Decode a 'BgpEvent' from its ABI tag value.
bgpEventFromTag :: Word8 -> Maybe BgpEvent
bgpEventFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BgpEvent)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this event is a timer expiry.
isTimerEvent :: BgpEvent -> Bool
isTimerEvent ConnectRetryTimerExpires = True
isTimerEvent HoldTimerExpires = True
isTimerEvent KeepaliveTimerExpires = True
isTimerEvent DelayOpenTimerExpires = True
isTimerEvent _ = False

-- | Whether this event indicates an error.
isErrorEvent :: BgpEvent -> Bool
isErrorEvent TcpConnectionFails = True
isErrorEvent BgpHeaderErr = True
isErrorEvent BgpOpenMsgErr = True
isErrorEvent NotifMsgVerErr = True
isErrorEvent UpdateMsgErr = True
isErrorEvent _ = False

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | BGP message types (RFC 4271 Section 4).
--
-- Tags 0-3 (4 constructors).
data MessageType
  = Open  -- ^ OPEN — establish BGP session (tag 0).
  | Update  -- ^ UPDATE — advertise/withdraw routes (tag 1).
  | Notification  -- ^ NOTIFICATION — report error (tag 2).
  | Keepalive  -- ^ KEEPALIVE — maintain session (tag 3).
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

-- | BGP NOTIFICATION error codes (RFC 4271 Section 4.5).
--
-- Tags 0-5 (6 constructors).
data ErrorCode
  = MessageHeaderError  -- ^ Message Header Error (tag 0).
  | OpenMessageError  -- ^ OPEN Message Error (tag 1).
  | UpdateMessageError  -- ^ UPDATE Message Error (tag 2).
  | HoldTimerExpired  -- ^ Hold Timer Expired (tag 3).
  | FsmError  -- ^ Finite State Machine Error (tag 4).
  | Cease  -- ^ Cease (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCode' to its ABI tag value.
errorCodeToTag :: ErrorCode -> Word8
errorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCode' from its ABI tag value.
errorCodeFromTag :: Word8 -> Maybe ErrorCode
errorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this error is fatal (always terminates session).
isFatal :: ErrorCode -> Bool
isFatal _ = True

-- ---------------------------------------------------------------------------
-- Origin
-- ---------------------------------------------------------------------------

-- | BGP ORIGIN path attribute values (RFC 4271 Section 4.3).
--
-- Tags 0-2 (3 constructors).
data Origin
  = Igp  -- ^ IGP — route originated within the AS (tag 0).
  | Egp  -- ^ EGP — route learned via EGP (tag 1).
  | Incomplete  -- ^ Incomplete — origin unknown (tag 2).
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

-- | BGP AS_PATH segment types (RFC 4271 Section 4.3).
--
-- Tags 0-1 (2 constructors).
data AsPathSegmentType
  = AsSet  -- ^ AS_SET — unordered set of ASes (tag 0).
  | AsSequence  -- ^ AS_SEQUENCE — ordered sequence of ASes (tag 1).
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

-- | BGP path attribute types (RFC 4271 Section 5).
--
-- Tags 0-7 (8 constructors).
data PathAttrType
  = Origin  -- ^ ORIGIN (tag 0).
  | AsPath  -- ^ AS_PATH (tag 1).
  | NextHop  -- ^ NEXT_HOP (tag 2).
  | Med  -- ^ MULTI_EXIT_DISC (tag 3).
  | LocalPref  -- ^ LOCAL_PREF (tag 4).
  | AtomicAggr  -- ^ ATOMIC_AGGREGATE (tag 5).
  | Aggregator  -- ^ AGGREGATOR (tag 6).
  | Unknown  -- ^ Unknown/vendor-specific (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PathAttrType' to its ABI tag value.
pathAttrTypeToTag :: PathAttrType -> Word8
pathAttrTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PathAttrType' from its ABI tag value.
pathAttrTypeFromTag :: Word8 -> Maybe PathAttrType
pathAttrTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PathAttrType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this attribute is mandatory (well-known mandatory per RFC 4271).
isMandatory :: PathAttrType -> Bool
isMandatory Origin = True
isMandatory AsPath = True
isMandatory NextHop = True
isMandatory _ = False
