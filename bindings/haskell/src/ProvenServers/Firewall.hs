-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Firewall protocol bindings for proven-servers.
--
-- Wraps the C-ABI functions from
-- @protocols\/proven-firewall\/ffi\/zig\/src\/firewall.zig@.
-- Provides Haskell ADTs for firewall actions, packet lifecycle states,
-- and connection tracking states.

{-# LANGUAGE ForeignFunctionInterface #-}

module ProvenServers.Firewall
  ( -- * ADTs matching Idris2 ABI
    FirewallAction(..)
  , PacketState(..)
  , ConntrackState(..)
    -- * Context lifecycle
  , abiVersion
  , createContext
  , destroyContext
    -- * State queries
  , packetState
  , conntrackState
  , getDecision
  , ruleCount
  , packetProto
  , packetChain
  , packetSrcIp
  , packetDstIp
  , packetSrcPort
  , packetDstPort
    -- * Packet classification
  , classifyPacket
    -- * Chain evaluation
  , beginChain
  , addRule
  , setDefaultAction
  , evaluateRules
  , commit
    -- * Connection tracking
  , beginTracking
  , completeTracking
  , expireConn
    -- * Transition queries
  , canTransition
  , canConntrackTransition
  ) where

import Data.Word (Word8, Word16, Word32)
import Foreign.C.Types (CInt(..))
import ProvenServers.Error (ProvenError, fromSlot, fromStatus)

-- ---------------------------------------------------------------------------
-- ADTs matching Idris2 ABI enums
-- ---------------------------------------------------------------------------

-- | Firewall rule actions matching @Action@ in firewall.zig.
data FirewallAction
  = FwAccept     -- ^ Accept the packet.
  | FwDrop       -- ^ Silently drop the packet.
  | FwReject     -- ^ Reject with ICMP error.
  | FwLog        -- ^ Log and continue processing.
  | FwRedirect   -- ^ Redirect to a different destination.
  | FwDnat       -- ^ Destination NAT.
  | FwSnat       -- ^ Source NAT.
  | FwMasquerade -- ^ IP masquerading.
  deriving (Show, Eq, Ord, Enum, Bounded)

fwActionToTag :: FirewallAction -> Word8
fwActionToTag = fromIntegral . fromEnum

fwActionFromTag :: Word8 -> Maybe FirewallAction
fwActionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FirewallAction)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Firewall packet lifecycle states.
data PacketState
  = PktIdle       -- ^ No packet classified yet.
  | PktClassified -- ^ Packet classified (protocol, IPs, ports set).
  | PktEvaluating -- ^ Chain evaluation in progress.
  | PktDecided    -- ^ Decision made.
  | PktCommitted  -- ^ Committed (final).
  deriving (Show, Eq, Ord, Enum, Bounded)

pktStateToTag :: PacketState -> Word8
pktStateToTag = fromIntegral . fromEnum

pktStateFromTag :: Word8 -> Maybe PacketState
pktStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PacketState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Connection tracking states.
data ConntrackState
  = CtNone        -- ^ No connection tracking.
  | CtTracking    -- ^ Tracking in progress.
  | CtEstablished -- ^ Connection established.
  | CtRelated     -- ^ Related connection.
  | CtExpired     -- ^ Connection expired.
  deriving (Show, Eq, Ord, Enum, Bounded)

ctStateToTag :: ConntrackState -> Word8
ctStateToTag = fromIntegral . fromEnum

ctStateFromTag :: Word8 -> Maybe ConntrackState
ctStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ConntrackState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Foreign imports
-- ---------------------------------------------------------------------------

foreign import ccall unsafe "fw_abi_version"           c_fw_abi_version           :: IO Word32
foreign import ccall unsafe "fw_create_context"        c_fw_create_context        :: IO CInt
foreign import ccall unsafe "fw_destroy_context"       c_fw_destroy_context       :: CInt -> IO ()
foreign import ccall unsafe "fw_packet_state"          c_fw_packet_state          :: CInt -> IO Word8
foreign import ccall unsafe "fw_conntrack_state"       c_fw_conntrack_state       :: CInt -> IO Word8
foreign import ccall unsafe "fw_get_decision"          c_fw_get_decision          :: CInt -> IO Word8
foreign import ccall unsafe "fw_rule_count"            c_fw_rule_count            :: CInt -> IO Word16
foreign import ccall unsafe "fw_packet_proto"          c_fw_packet_proto          :: CInt -> IO Word8
foreign import ccall unsafe "fw_packet_chain"          c_fw_packet_chain          :: CInt -> IO Word8
foreign import ccall unsafe "fw_packet_src_ip"         c_fw_packet_src_ip         :: CInt -> IO Word32
foreign import ccall unsafe "fw_packet_dst_ip"         c_fw_packet_dst_ip         :: CInt -> IO Word32
foreign import ccall unsafe "fw_packet_src_port"       c_fw_packet_src_port       :: CInt -> IO Word16
foreign import ccall unsafe "fw_packet_dst_port"       c_fw_packet_dst_port       :: CInt -> IO Word16
foreign import ccall unsafe "fw_classify_packet"       c_fw_classify_packet       :: CInt -> Word8 -> Word8 -> Word32 -> Word32 -> Word16 -> Word16 -> IO Word8
foreign import ccall unsafe "fw_begin_chain"           c_fw_begin_chain           :: CInt -> IO Word8
foreign import ccall unsafe "fw_add_rule"              c_fw_add_rule              :: CInt -> Word8 -> Word32 -> Word8 -> Word16 -> IO Word8
foreign import ccall unsafe "fw_set_default_action"    c_fw_set_default_action    :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "fw_evaluate_rules"        c_fw_evaluate_rules        :: CInt -> IO Word8
foreign import ccall unsafe "fw_commit"                c_fw_commit                :: CInt -> IO Word8
foreign import ccall unsafe "fw_begin_tracking"        c_fw_begin_tracking        :: CInt -> IO Word8
foreign import ccall unsafe "fw_complete_tracking"     c_fw_complete_tracking     :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "fw_expire_conn"           c_fw_expire_conn           :: CInt -> IO Word8
foreign import ccall unsafe "fw_can_transition"        c_fw_can_transition        :: Word8 -> Word8 -> IO Word8
foreign import ccall unsafe "fw_can_conntrack_transition" c_fw_can_conntrack_transition :: Word8 -> Word8 -> IO Word8

-- ---------------------------------------------------------------------------
-- Safe wrappers
-- ---------------------------------------------------------------------------

-- | Return the ABI version.
abiVersion :: IO Word32
abiVersion = c_fw_abi_version

-- | Create a new firewall context.
createContext :: IO (Either ProvenError CInt)
createContext = fromSlot . fromIntegral <$> c_fw_create_context

-- | Destroy a firewall context.
destroyContext :: CInt -> IO ()
destroyContext = c_fw_destroy_context

-- | Get the current packet lifecycle state.
packetState :: CInt -> IO (Maybe PacketState)
packetState slot = pktStateFromTag <$> c_fw_packet_state slot

-- | Get the current connection tracking state.
conntrackState :: CInt -> IO (Maybe ConntrackState)
conntrackState slot = ctStateFromTag <$> c_fw_conntrack_state slot

-- | Get the decision action (only meaningful after evaluation).
getDecision :: CInt -> IO (Maybe FirewallAction)
getDecision slot = fwActionFromTag <$> c_fw_get_decision slot

-- | Get the number of rules in the chain.
ruleCount :: CInt -> IO Word16
ruleCount = c_fw_rule_count

-- | Get the classified packet protocol tag.
packetProto :: CInt -> IO Word8
packetProto = c_fw_packet_proto

-- | Get the classified packet chain tag.
packetChain :: CInt -> IO Word8
packetChain = c_fw_packet_chain

-- | Get the source IP (as a raw u32 in network order).
packetSrcIp :: CInt -> IO Word32
packetSrcIp = c_fw_packet_src_ip

-- | Get the destination IP.
packetDstIp :: CInt -> IO Word32
packetDstIp = c_fw_packet_dst_ip

-- | Get the source port.
packetSrcPort :: CInt -> IO Word16
packetSrcPort = c_fw_packet_src_port

-- | Get the destination port.
packetDstPort :: CInt -> IO Word16
packetDstPort = c_fw_packet_dst_port

-- | Classify a packet. Transitions Idle -> Classified.
classifyPacket :: CInt -> Word8 -> Word8 -> Word32 -> Word32 -> Word16 -> Word16 -> IO (Either ProvenError ())
classifyPacket slot proto chain srcIp dstIp srcPort dstPort =
  fromStatus <$> c_fw_classify_packet slot proto chain srcIp dstIp srcPort dstPort

-- | Begin chain evaluation. Transitions Classified -> Evaluating.
beginChain :: CInt -> IO (Either ProvenError ())
beginChain slot = fromStatus <$> c_fw_begin_chain slot

-- | Add a rule to the evaluation chain.
addRule :: CInt -> Word8 -> Word32 -> FirewallAction -> Word16 -> IO (Either ProvenError ())
addRule slot matchType matchValue action priority =
  fromStatus <$> c_fw_add_rule slot matchType matchValue (fwActionToTag action) priority

-- | Set the default action (applied when no rules match).
setDefaultAction :: CInt -> FirewallAction -> IO (Either ProvenError ())
setDefaultAction slot action = fromStatus <$> c_fw_set_default_action slot (fwActionToTag action)

-- | Evaluate rules against the classified packet. Transitions Evaluating -> Decided.
evaluateRules :: CInt -> IO (Either ProvenError ())
evaluateRules slot = fromStatus <$> c_fw_evaluate_rules slot

-- | Commit the decision. Transitions Decided -> Committed.
commit :: CInt -> IO (Either ProvenError ())
commit slot = fromStatus <$> c_fw_commit slot

-- | Begin connection tracking. Transitions None -> Tracking.
beginTracking :: CInt -> IO (Either ProvenError ())
beginTracking slot = fromStatus <$> c_fw_begin_tracking slot

-- | Complete connection tracking with a state.
completeTracking :: CInt -> ConntrackState -> IO (Either ProvenError ())
completeTracking slot connState = fromStatus <$> c_fw_complete_tracking slot (ctStateToTag connState)

-- | Expire a connection. Transitions Established\/Related -> Expired.
expireConn :: CInt -> IO (Either ProvenError ())
expireConn slot = fromStatus <$> c_fw_expire_conn slot

-- | Stateless query: check whether a packet state transition is valid.
canTransition :: PacketState -> PacketState -> IO Bool
canTransition from to =
  (== 1) <$> c_fw_can_transition (pktStateToTag from) (pktStateToTag to)

-- | Stateless query: check whether a conntrack state transition is valid.
canConntrackTransition :: ConntrackState -> ConntrackState -> IO Bool
canConntrackTransition from to =
  (== 1) <$> c_fw_can_conntrack_transition (ctStateToTag from) (ctStateToTag to)
