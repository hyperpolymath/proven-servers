-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SOCKS5 protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Socks
  (
    socksPort
  , AuthMethod(..)
  , authMethodToTag
  , authMethodFromTag
  , Command(..)
  , commandToTag
  , commandFromTag
  , AddressType(..)
  , addressTypeToTag
  , addressTypeFromTag
  , Reply(..)
  , replyToTag
  , replyFromTag
  , isSuccess
  , isNetworkError
  , State(..)
  , stateToTag
  , stateFromTag
  , stateCanTransitionTo
  ) where

import Data.Word (Word16, Word8)

-- | Standard SOCKS5 port (RFC 1928).
socksPort :: Word16
socksPort = 1080

-- ---------------------------------------------------------------------------
-- AuthMethod
-- ---------------------------------------------------------------------------

-- | Standard SOCKS5 port (RFC 1928).
--
-- Tags 0-3 (4 constructors).
data AuthMethod
  = NoAuth  -- ^ No authentication required (tag 0).
  | Gssapi  -- ^ GSSAPI (tag 1).
  | UsernamePassword  -- ^ Username/Password (RFC 1929) (tag 2).
  | NoAcceptable  -- ^ No acceptable methods (tag 3).
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

-- | SOCKS5 commands (RFC 1928).
--
-- Tags 0-2 (3 constructors).
data Command
  = Connect  -- ^ CONNECT — establish TCP connection (tag 0).
  | Bind  -- ^ BIND — listen for incoming connection (tag 1).
  | UdpAssociate  -- ^ UDP ASSOCIATE — set up UDP relay (tag 2).
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

-- | SOCKS5 address types (RFC 1928).
--
-- Tags 0-2 (3 constructors).
data AddressType
  = IPv4  -- ^ IPv4 address (tag 0).
  | DomainName  -- ^ Domain name (tag 1).
  | IPv6  -- ^ IPv6 address (tag 2).
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

-- | SOCKS5 reply codes (RFC 1928).
--
-- Tags 0-8 (9 constructors).
data Reply
  = Succeeded  -- ^ Succeeded (tag 0).
  | GeneralFailure  -- ^ General SOCKS server failure (tag 1).
  | NotAllowed  -- ^ Connection not allowed by ruleset (tag 2).
  | NetworkUnreachable  -- ^ Network unreachable (tag 3).
  | HostUnreachable  -- ^ Host unreachable (tag 4).
  | ConnectionRefused  -- ^ Connection refused (tag 5).
  | TtlExpired  -- ^ TTL expired (tag 6).
  | CommandNotSupported  -- ^ Command not supported (tag 7).
  | AddressTypeNotSupported  -- ^ Address type not supported (tag 8).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Reply' to its ABI tag value.
replyToTag :: Reply -> Word8
replyToTag = fromIntegral . fromEnum

-- | Decode a 'Reply' from its ABI tag value.
replyFromTag :: Word8 -> Maybe Reply
replyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Reply)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this reply indicates success.
isSuccess :: Reply -> Bool
isSuccess Succeeded = True
isSuccess _ = False

-- | Whether this is a network-level error.
isNetworkError :: Reply -> Bool
isNetworkError NetworkUnreachable = True
isNetworkError HostUnreachable = True
isNetworkError ConnectionRefused = True
isNetworkError _ = False

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------

-- | SOCKS5 connection state machine.
--
-- Tags 0-5 (6 constructors).
data State
  = Initial  -- ^ Initial — awaiting method negotiation (tag 0).
  | Authenticating  -- ^ Authenticating (tag 1).
  | Authenticated  -- ^ Authenticated — awaiting command (tag 2).
  | Connecting  -- ^ Connecting to target (tag 3).
  | Established  -- ^ Connection established — relaying data (tag 4).
  | Closed  -- ^ Connection closed (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'State' to its ABI tag value.
stateToTag :: State -> Word8
stateToTag = fromIntegral . fromEnum

-- | Decode a 'State' from its ABI tag value.
stateFromTag :: Word8 -> Maybe State
stateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: State)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Validate whether a state transition is allowed.
stateCanTransitionTo :: State -> State -> Bool
stateCanTransitionTo Initial Authenticating = True
stateCanTransitionTo Initial Authenticated = True
stateCanTransitionTo Authenticating Authenticated = True
stateCanTransitionTo Authenticated Connecting = True
stateCanTransitionTo Connecting Established = True
stateCanTransitionTo Connecting Closed = True
stateCanTransitionTo Established Closed = True
stateCanTransitionTo _ _ = False
