-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- GitABI.Types: C-ABI-compatible numeric representations of Git server types.
--
-- Types covered:
--   Command      (3 constructors, tags 0-2)
--   PacketType   (8 constructors, tags 0-7)
--   RefType      (5 constructors, tags 0-4)
--   Capability   (9 constructors, tags 0-8)
--   HookResult   (2 constructors, tags 0-1)
--   ServerState  (5 constructors, tags 0-4)

module GitABI.Types

import Git.Types

%default total

---------------------------------------------------------------------------
-- Command (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
commandToTag : Command -> Bits8
commandToTag UploadPack    = 0
commandToTag ReceivePack   = 1
commandToTag UploadArchive = 2

public export
tagToCommand : Bits8 -> Maybe Command
tagToCommand 0 = Just UploadPack
tagToCommand 1 = Just ReceivePack
tagToCommand 2 = Just UploadArchive
tagToCommand _ = Nothing

public export
commandRoundtrip : (c : Command) -> tagToCommand (commandToTag c) = Just c
commandRoundtrip UploadPack    = Refl
commandRoundtrip ReceivePack   = Refl
commandRoundtrip UploadArchive = Refl

---------------------------------------------------------------------------
-- PacketType (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
packetTypeToTag : PacketType -> Bits8
packetTypeToTag Flush            = 0
packetTypeToTag Delimiter        = 1
packetTypeToTag ResponseEnd      = 2
packetTypeToTag Data             = 3
packetTypeToTag PktError         = 4
packetTypeToTag SidebandData     = 5
packetTypeToTag SidebandProgress = 6
packetTypeToTag SidebandError    = 7

public export
tagToPacketType : Bits8 -> Maybe PacketType
tagToPacketType 0 = Just Flush
tagToPacketType 1 = Just Delimiter
tagToPacketType 2 = Just ResponseEnd
tagToPacketType 3 = Just Data
tagToPacketType 4 = Just PktError
tagToPacketType 5 = Just SidebandData
tagToPacketType 6 = Just SidebandProgress
tagToPacketType 7 = Just SidebandError
tagToPacketType _ = Nothing

public export
packetTypeRoundtrip : (p : PacketType) -> tagToPacketType (packetTypeToTag p) = Just p
packetTypeRoundtrip Flush            = Refl
packetTypeRoundtrip Delimiter        = Refl
packetTypeRoundtrip ResponseEnd      = Refl
packetTypeRoundtrip Data             = Refl
packetTypeRoundtrip PktError         = Refl
packetTypeRoundtrip SidebandData     = Refl
packetTypeRoundtrip SidebandProgress = Refl
packetTypeRoundtrip SidebandError    = Refl

---------------------------------------------------------------------------
-- RefType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
refTypeToTag : RefType -> Bits8
refTypeToTag Branch = 0
refTypeToTag Tag    = 1
refTypeToTag Head   = 2
refTypeToTag Remote = 3
refTypeToTag Note   = 4

public export
tagToRefType : Bits8 -> Maybe RefType
tagToRefType 0 = Just Branch
tagToRefType 1 = Just Tag
tagToRefType 2 = Just Head
tagToRefType 3 = Just Remote
tagToRefType 4 = Just Note
tagToRefType _ = Nothing

public export
refTypeRoundtrip : (r : RefType) -> tagToRefType (refTypeToTag r) = Just r
refTypeRoundtrip Branch = Refl
refTypeRoundtrip Tag    = Refl
refTypeRoundtrip Head   = Refl
refTypeRoundtrip Remote = Refl
refTypeRoundtrip Note   = Refl

---------------------------------------------------------------------------
-- Capability (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
capabilityToTag : Capability -> Bits8
capabilityToTag MultiAck     = 0
capabilityToTag ThinPack     = 1
capabilityToTag SideBand64k  = 2
capabilityToTag OFSDelta     = 3
capabilityToTag Shallow      = 4
capabilityToTag DeepenSince  = 5
capabilityToTag DeepenNot    = 6
capabilityToTag FilterSpec   = 7
capabilityToTag ObjectFormat = 8

public export
tagToCapability : Bits8 -> Maybe Capability
tagToCapability 0 = Just MultiAck
tagToCapability 1 = Just ThinPack
tagToCapability 2 = Just SideBand64k
tagToCapability 3 = Just OFSDelta
tagToCapability 4 = Just Shallow
tagToCapability 5 = Just DeepenSince
tagToCapability 6 = Just DeepenNot
tagToCapability 7 = Just FilterSpec
tagToCapability 8 = Just ObjectFormat
tagToCapability _ = Nothing

public export
capabilityRoundtrip : (c : Capability) -> tagToCapability (capabilityToTag c) = Just c
capabilityRoundtrip MultiAck     = Refl
capabilityRoundtrip ThinPack     = Refl
capabilityRoundtrip SideBand64k  = Refl
capabilityRoundtrip OFSDelta     = Refl
capabilityRoundtrip Shallow      = Refl
capabilityRoundtrip DeepenSince  = Refl
capabilityRoundtrip DeepenNot    = Refl
capabilityRoundtrip FilterSpec   = Refl
capabilityRoundtrip ObjectFormat = Refl

---------------------------------------------------------------------------
-- HookResult (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
hookResultToTag : HookResult -> Bits8
hookResultToTag Accept = 0
hookResultToTag Reject = 1

public export
tagToHookResult : Bits8 -> Maybe HookResult
tagToHookResult 0 = Just Accept
tagToHookResult 1 = Just Reject
tagToHookResult _ = Nothing

public export
hookResultRoundtrip : (h : HookResult) -> tagToHookResult (hookResultToTag h) = Just h
hookResultRoundtrip Accept = Refl
hookResultRoundtrip Reject = Refl

---------------------------------------------------------------------------
-- ServerState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
data ServerState : Type where
  GSIdle        : ServerState
  GSDiscovery   : ServerState
  GSNegotiating : ServerState
  GSTransfer    : ServerState
  GSShutdown    : ServerState

public export
Eq ServerState where
  GSIdle        == GSIdle        = True
  GSDiscovery   == GSDiscovery   = True
  GSNegotiating == GSNegotiating = True
  GSTransfer    == GSTransfer    = True
  GSShutdown    == GSShutdown    = True
  _             == _             = False

public export
Show ServerState where
  show GSIdle        = "Idle"
  show GSDiscovery   = "Discovery"
  show GSNegotiating = "Negotiating"
  show GSTransfer    = "Transfer"
  show GSShutdown    = "Shutdown"

public export
serverStateToTag : ServerState -> Bits8
serverStateToTag GSIdle        = 0
serverStateToTag GSDiscovery   = 1
serverStateToTag GSNegotiating = 2
serverStateToTag GSTransfer    = 3
serverStateToTag GSShutdown    = 4

public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just GSIdle
tagToServerState 1 = Just GSDiscovery
tagToServerState 2 = Just GSNegotiating
tagToServerState 3 = Just GSTransfer
tagToServerState 4 = Just GSShutdown
tagToServerState _ = Nothing

public export
serverStateRoundtrip : (s : ServerState) -> tagToServerState (serverStateToTag s) = Just s
serverStateRoundtrip GSIdle        = Refl
serverStateRoundtrip GSDiscovery   = Refl
serverStateRoundtrip GSNegotiating = Refl
serverStateRoundtrip GSTransfer    = Refl
serverStateRoundtrip GSShutdown    = Refl

public export
data ValidServerTransition : ServerState -> ServerState -> Type where
  ServerStarted      : ValidServerTransition GSIdle GSDiscovery
  BeginNegotiation   : ValidServerTransition GSDiscovery GSNegotiating
  BeginTransfer      : ValidServerTransition GSNegotiating GSTransfer
  TransferDone       : ValidServerTransition GSTransfer GSIdle
  ShutdownFromDisc   : ValidServerTransition GSDiscovery GSShutdown
  ShutdownFromNeg    : ValidServerTransition GSNegotiating GSShutdown
  ShutdownFromXfer   : ValidServerTransition GSTransfer GSShutdown
  CleanupDone        : ValidServerTransition GSShutdown GSIdle

public export
validateServerTransition : (from : ServerState) -> (to : ServerState)
                         -> Maybe (ValidServerTransition from to)
validateServerTransition GSIdle        GSDiscovery   = Just ServerStarted
validateServerTransition GSDiscovery   GSNegotiating = Just BeginNegotiation
validateServerTransition GSNegotiating GSTransfer    = Just BeginTransfer
validateServerTransition GSTransfer    GSIdle        = Just TransferDone
validateServerTransition GSDiscovery   GSShutdown    = Just ShutdownFromDisc
validateServerTransition GSNegotiating GSShutdown    = Just ShutdownFromNeg
validateServerTransition GSTransfer    GSShutdown    = Just ShutdownFromXfer
validateServerTransition GSShutdown    GSIdle        = Just CleanupDone
validateServerTransition _             _             = Nothing

public export
idleCannotTransfer : ValidServerTransition GSIdle GSTransfer -> Void
idleCannotTransfer _ impossible

public export
cannotResumeFromShutdown : ValidServerTransition GSShutdown GSDiscovery -> Void
cannotResumeFromShutdown _ impossible
