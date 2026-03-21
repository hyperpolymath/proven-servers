-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SOCKS5 protocol types for proven-servers.
--
-- SOCKS5 proxy protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Socks
  ( -- * ADT types matching Idris2 ABI
      AuthMethod(..)
    , Command(..)
    , AddressType(..)
    , Reply(..)
    , State(..)
    , authMethodToTag
    , authMethodFromTag
    , commandToTag
    , commandFromTag
    , addressTypeToTag
    , addressTypeFromTag
    , replyToTag
    , replyFromTag
    , stateToTag
    , stateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- AuthMethod
-- ---------------------------------------------------------------------------

-- | AuthMethod type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data AuthMethod
  = NoAuth  -- ^ Tag 0.
  | Gssapi  -- ^ Tag 1.
  | UsernamePassword  -- ^ Tag 2.
  | NoAcceptable  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthMethod' to its ABI tag value.
authMethodToTag :: AuthMethod -> Word8
authMethodToTag = fromIntegral . fromEnum

-- | Decode a 'AuthMethod' from its ABI tag value.
authMethodFromTag :: Word8 -> Maybe AuthMethod
authMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Command type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data Command
  = Connect  -- ^ Tag 0.
  | Bind  -- ^ Tag 1.
  | UdpAssociate  -- ^ Tag 2.
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
-- AddressType
-- ---------------------------------------------------------------------------

-- | AddressType type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data AddressType
  = IPv4  -- ^ Tag 0.
  | DomainName  -- ^ Tag 1.
  | IPv6  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AddressType' to its ABI tag value.
addressTypeToTag :: AddressType -> Word8
addressTypeToTag = fromIntegral . fromEnum

-- | Decode a 'AddressType' from its ABI tag value.
addressTypeFromTag :: Word8 -> Maybe AddressType
addressTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AddressType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Reply
-- ---------------------------------------------------------------------------

-- | Reply type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data Reply
  = Succeeded  -- ^ Tag 0.
  | GeneralFailure  -- ^ Tag 1.
  | NotAllowed  -- ^ Tag 2.
  | NetworkUnreachable  -- ^ Tag 3.
  | HostUnreachable  -- ^ Tag 4.
  | ConnectionRefused  -- ^ Tag 5.
  | TtlExpired  -- ^ Tag 6.
  | CommandNotSupported  -- ^ Tag 7.
  | AddressTypeNotSupported  -- ^ Tag 8.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Reply' to its ABI tag value.
replyToTag :: Reply -> Word8
replyToTag = fromIntegral . fromEnum

-- | Decode a 'Reply' from its ABI tag value.
replyFromTag :: Word8 -> Maybe Reply
replyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Reply)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------

-- | State type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data State
  = Initial  -- ^ Tag 0.
  | Authenticating  -- ^ Tag 1.
  | Authenticated  -- ^ Tag 2.
  | Connecting  -- ^ Tag 3.
  | Established  -- ^ Tag 4.
  | Closed  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'State' to its ABI tag value.
stateToTag :: State -> Word8
stateToTag = fromIntegral . fromEnum

-- | Decode a 'State' from its ABI tag value.
stateFromTag :: Word8 -> Maybe State
stateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: State)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
