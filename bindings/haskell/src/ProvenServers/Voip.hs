-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | VoIP/SIP protocol types for proven-servers.
--
-- VoIP/SIP types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Voip
  ( -- * ADT types matching Idris2 ABI
      Method(..)
    , ResponseCode(..)
    , DialogState(..)
    , methodToTag
    , methodFromTag
    , responseCodeToTag
    , responseCodeFromTag
    , dialogStateToTag
    , dialogStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Method
-- ---------------------------------------------------------------------------

-- | Method type matching the Idris2 ABI.
--
-- Tags 0-12 (13 constructors).
data Method
  = Invite  -- ^ Tag 0.
  | Ack  -- ^ Tag 1.
  | Bye  -- ^ Tag 2.
  | Cancel  -- ^ Tag 3.
  | Register  -- ^ Tag 4.
  | Options  -- ^ Tag 5.
  | Info  -- ^ Tag 6.
  | Update  -- ^ Tag 7.
  | Subscribe  -- ^ Tag 8.
  | Notify  -- ^ Tag 9.
  | Refer  -- ^ Tag 10.
  | Message  -- ^ Tag 11.
  | Prack  -- ^ Tag 12.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Method' to its ABI tag value.
methodToTag :: Method -> Word8
methodToTag = fromIntegral . fromEnum

-- | Decode a 'Method' from its ABI tag value.
methodFromTag :: Word8 -> Maybe Method
methodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Method)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ResponseCode
-- ---------------------------------------------------------------------------

-- | ResponseCode type matching the Idris2 ABI.
--
-- Tags 0-16 (17 constructors).
data ResponseCode
  = Trying  -- ^ Tag 0.
  | Ringing  -- ^ Tag 1.
  | SessionProgress  -- ^ Tag 2.
  | Ok  -- ^ Tag 3.
  | MultipleChoices  -- ^ Tag 4.
  | MovedPermanently  -- ^ Tag 5.
  | MovedTemporarily  -- ^ Tag 6.
  | BadRequest  -- ^ Tag 7.
  | Unauthorized  -- ^ Tag 8.
  | Forbidden  -- ^ Tag 9.
  | NotFound  -- ^ Tag 10.
  | MethodNotAllowed  -- ^ Tag 11.
  | RequestTimeout  -- ^ Tag 12.
  | BusyHere  -- ^ Tag 13.
  | Decline  -- ^ Tag 14.
  | ServerInternalError  -- ^ Tag 15.
  | ServiceUnavailable  -- ^ Tag 16.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResponseCode' to its ABI tag value.
responseCodeToTag :: ResponseCode -> Word8
responseCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ResponseCode' from its ABI tag value.
responseCodeFromTag :: Word8 -> Maybe ResponseCode
responseCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResponseCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DialogState
-- ---------------------------------------------------------------------------

-- | DialogState type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data DialogState
  = Early  -- ^ Tag 0.
  | Confirmed  -- ^ Tag 1.
  | Terminated  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DialogState' to its ABI tag value.
dialogStateToTag :: DialogState -> Word8
dialogStateToTag = fromIntegral . fromEnum

-- | Decode a 'DialogState' from its ABI tag value.
dialogStateFromTag :: Word8 -> Maybe DialogState
dialogStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DialogState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
