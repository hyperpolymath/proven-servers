-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | OPC UA (OPC Unified Architecture) types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Opcua
  (
    opcuaPort
  , opcuaTlsPort
  , ServiceType(..)
  , serviceTypeToTag
  , serviceTypeFromTag
  , isWrite
  , isSessionManagement
  , isSubscriptionRelated
  , NodeClass(..)
  , nodeClassToTag
  , nodeClassFromTag
  , isInstance
  , isType
  , StatusCode(..)
  , statusCodeToTag
  , statusCodeFromTag
  , isGood
  , isBad
  , isSecurityRelated
  , SecurityMode(..)
  , securityModeToTag
  , securityModeFromTag
  , isSigned
  , isEncrypted
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  , canService
  , isTransient
  ) where

import Data.Word (Word16, Word8)

-- | Standard OPC UA TCP port.
opcuaPort :: Word16
opcuaPort = 4840

-- | Standard OPC UA TCP/TLS port.
opcuaTlsPort :: Word16
opcuaTlsPort = 4843

-- ---------------------------------------------------------------------------
-- ServiceType
-- ---------------------------------------------------------------------------

-- | Standard OPC UA TCP port.
--
-- Tags 0-10 (11 constructors).
data ServiceType
  = Read  -- ^ Read attribute values from nodes (tag 0).
  | Write  -- ^ Write attribute values to nodes (tag 1).
  | Browse  -- ^ Browse the address space (tag 2).
  | Subscribe  -- ^ Create a monitored item subscription (tag 3).
  | Publish  -- ^ Publish subscription notifications (tag 4).
  | Call  -- ^ Call a method on a node (tag 5).
  | CreateSession  -- ^ Create a new session (tag 6).
  | ActivateSession  -- ^ Activate an existing session (tag 7).
  | CloseSession  -- ^ Close a session (tag 8).
  | CreateSubscription  -- ^ Create a new subscription (tag 9).
  | DeleteSubscription  -- ^ Delete a subscription (tag 10).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServiceType' to its ABI tag value.
serviceTypeToTag :: ServiceType -> Word8
serviceTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ServiceType' from its ABI tag value.
serviceTypeFromTag :: Word8 -> Maybe ServiceType
serviceTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServiceType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this service modifies server state.
isWrite :: ServiceType -> Bool
isWrite Write = True
isWrite Call = True
isWrite _ = False

-- | Whether this service is a session management operation.
isSessionManagement :: ServiceType -> Bool
isSessionManagement CreateSession = True
isSessionManagement ActivateSession = True
isSessionManagement CloseSession = True
isSessionManagement _ = False

-- | Whether this service relates to subscriptions.
isSubscriptionRelated :: ServiceType -> Bool
isSubscriptionRelated Subscribe = True
isSubscriptionRelated Publish = True
isSubscriptionRelated CreateSubscription = True
isSubscriptionRelated DeleteSubscription = True
isSubscriptionRelated _ = False

-- ---------------------------------------------------------------------------
-- NodeClass
-- ---------------------------------------------------------------------------

-- | OPC UA node classes (OPC 10000 Part 3).
--
-- Tags 0-7 (8 constructors).
data NodeClass
  = Object  -- ^ Object instance node (tag 0).
  | Variable  -- ^ Variable node holding a value (tag 1).
  | Method  -- ^ Method node that can be called (tag 2).
  | ObjectType  -- ^ Object type definition (tag 3).
  | VariableType  -- ^ Variable type definition (tag 4).
  | ReferenceType  -- ^ Reference type definition (tag 5).
  | DataType  -- ^ Data type definition (tag 6).
  | View  -- ^ View node for address space subsets (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NodeClass' to its ABI tag value.
nodeClassToTag :: NodeClass -> Word8
nodeClassToTag = fromIntegral . fromEnum

-- | Decode a 'NodeClass' from its ABI tag value.
nodeClassFromTag :: Word8 -> Maybe NodeClass
nodeClassFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NodeClass)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this node class is an instance node (not a type definition).
isInstance :: NodeClass -> Bool
isInstance Object = True
isInstance Variable = True
isInstance Method = True
isInstance View = True
isInstance _ = False

-- | Whether this node class is a type definition.
isType :: NodeClass -> Bool
isType ObjectType = True
isType VariableType = True
isType ReferenceType = True
isType DataType = True
isType _ = False

-- ---------------------------------------------------------------------------
-- StatusCode
-- ---------------------------------------------------------------------------

-- | OPC UA status codes (OPC 10000 Part 4).
--
-- Tags 0-11 (12 constructors).
data StatusCode
  = Good  -- ^ Good — operation succeeded (tag 0).
  | Uncertain  -- ^ Uncertain — result is not fully reliable (tag 1).
  | Bad  -- ^ Bad — generic failure (tag 2).
  | BadNodeIdUnknown  -- ^ NodeId does not exist (tag 3).
  | BadAttributeIdInvalid  -- ^ Attribute ID is invalid for this node (tag 4).
  | BadNotReadable  -- ^ Attribute is not readable (tag 5).
  | BadNotWritable  -- ^ Attribute is not writable (tag 6).
  | BadOutOfRange  -- ^ Value is out of range (tag 7).
  | BadTypeMismatch  -- ^ Data type mismatch (tag 8).
  | BadSessionIdInvalid  -- ^ Session ID is invalid (tag 9).
  | BadSubscriptionIdInvalid  -- ^ Subscription ID is invalid (tag 10).
  | BadTimeout  -- ^ Operation timed out (tag 11).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StatusCode' to its ABI tag value.
statusCodeToTag :: StatusCode -> Word8
statusCodeToTag = fromIntegral . fromEnum

-- | Decode a 'StatusCode' from its ABI tag value.
statusCodeFromTag :: Word8 -> Maybe StatusCode
statusCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StatusCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this status code indicates success.
isGood :: StatusCode -> Bool
isGood Good = True
isGood _ = False

-- | Whether this status code indicates a definite failure.
isBad :: StatusCode -> Bool
isBad Good = False
isBad Uncertain = False
isBad _ = True

-- | Whether this status code relates to security/session issues.
isSecurityRelated :: StatusCode -> Bool
isSecurityRelated BadSessionIdInvalid = True
isSecurityRelated _ = False

-- ---------------------------------------------------------------------------
-- SecurityMode
-- ---------------------------------------------------------------------------

-- | OPC UA message security modes (OPC 10000 Part 4).
--
-- Tags 0-2 (3 constructors).
data SecurityMode
  = None  -- ^ No security (tag 0).
  | Sign  -- ^ Messages are signed but not encrypted (tag 1).
  | SignAndEncrypt  -- ^ Messages are signed and encrypted (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SecurityMode' to its ABI tag value.
securityModeToTag :: SecurityMode -> Word8
securityModeToTag = fromIntegral . fromEnum

-- | Decode a 'SecurityMode' from its ABI tag value.
securityModeFromTag :: Word8 -> Maybe SecurityMode
securityModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SecurityMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether messages are signed.
isSigned :: SecurityMode -> Bool
isSigned Sign = True
isSigned SignAndEncrypt = True
isSigned _ = False

-- | Whether messages are encrypted.
isEncrypted :: SecurityMode -> Bool
isEncrypted SignAndEncrypt = True
isEncrypted _ = False

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | OPC UA session lifecycle states for the FFI layer.
--
-- Tags 0-5 (6 constructors).
data SessionState
  = Idle  -- ^ No session (tag 0).
  | Connected  -- ^ Secure channel established (tag 1).
  | Created  -- ^ Session created, awaiting activation (tag 2).
  | Activated  -- ^ Session activated, ready for service requests (tag 3).
  | Monitoring  -- ^ Subscription active, monitoring nodes (tag 4).
  | Closing  -- ^ Session closing (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the session can accept service requests.
canService :: SessionState -> Bool
canService Activated = True
canService Monitoring = True
canService _ = False

-- | Whether the session is in a transient state.
isTransient :: SessionState -> Bool
isTransient Connected = True
isTransient Created = True
isTransient Closing = True
isTransient _ = False
