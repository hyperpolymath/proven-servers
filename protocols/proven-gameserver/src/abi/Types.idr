-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GameserverABI.Types: C-ABI-compatible numeric representations of
-- game server types.
--
-- Maps every constructor of the core Gameserver sum types to fixed Bits8
-- values for C interop. Each type gets a total encoder, partial decoder,
-- and roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/gameserver.zig)
-- exactly.
--
-- Types covered:
--   PacketType       (9 constructors,  tags 0-8)
--   PlayerState      (5 constructors,  tags 0-4)
--   GameState        (6 constructors,  tags 0-5)
--   SyncStrategy     (4 constructors,  tags 0-3)
--   DisconnectReason (5 constructors,  tags 0-4)
--   ServerState      (5 constructors,  tags 0-4)

module GameserverABI.Types

import Gameserver.Types

%default total

---------------------------------------------------------------------------
-- PacketType (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
packetTypeToTag : PacketType -> Bits8
packetTypeToTag Connect     = 0
packetTypeToTag Disconnect  = 1
packetTypeToTag Input       = 2
packetTypeToTag StateUpdate = 3
packetTypeToTag Chat        = 4
packetTypeToTag Ping        = 5
packetTypeToTag Pong        = 6
packetTypeToTag Sync        = 7
packetTypeToTag Event       = 8

public export
tagToPacketType : Bits8 -> Maybe PacketType
tagToPacketType 0 = Just Connect
tagToPacketType 1 = Just Disconnect
tagToPacketType 2 = Just Input
tagToPacketType 3 = Just StateUpdate
tagToPacketType 4 = Just Chat
tagToPacketType 5 = Just Ping
tagToPacketType 6 = Just Pong
tagToPacketType 7 = Just Sync
tagToPacketType 8 = Just Event
tagToPacketType _ = Nothing

public export
packetTypeRoundtrip : (p : PacketType) -> tagToPacketType (packetTypeToTag p) = Just p
packetTypeRoundtrip Connect     = Refl
packetTypeRoundtrip Disconnect  = Refl
packetTypeRoundtrip Input       = Refl
packetTypeRoundtrip StateUpdate = Refl
packetTypeRoundtrip Chat        = Refl
packetTypeRoundtrip Ping        = Refl
packetTypeRoundtrip Pong        = Refl
packetTypeRoundtrip Sync        = Refl
packetTypeRoundtrip Event       = Refl

---------------------------------------------------------------------------
-- PlayerState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
playerStateToTag : PlayerState -> Bits8
playerStateToTag Connecting   = 0
playerStateToTag Lobby        = 1
playerStateToTag InGame       = 2
playerStateToTag Spectating   = 3
playerStateToTag Disconnected = 4

public export
tagToPlayerState : Bits8 -> Maybe PlayerState
tagToPlayerState 0 = Just Connecting
tagToPlayerState 1 = Just Lobby
tagToPlayerState 2 = Just InGame
tagToPlayerState 3 = Just Spectating
tagToPlayerState 4 = Just Disconnected
tagToPlayerState _ = Nothing

public export
playerStateRoundtrip : (p : PlayerState) -> tagToPlayerState (playerStateToTag p) = Just p
playerStateRoundtrip Connecting   = Refl
playerStateRoundtrip Lobby        = Refl
playerStateRoundtrip InGame       = Refl
playerStateRoundtrip Spectating   = Refl
playerStateRoundtrip Disconnected = Refl

---------------------------------------------------------------------------
-- GameState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
gameStateToTag : GameState -> Bits8
gameStateToTag Waiting  = 0
gameStateToTag Starting = 1
gameStateToTag Running  = 2
gameStateToTag Paused   = 3
gameStateToTag Ending   = 4
gameStateToTag Finished = 5

public export
tagToGameState : Bits8 -> Maybe GameState
tagToGameState 0 = Just Waiting
tagToGameState 1 = Just Starting
tagToGameState 2 = Just Running
tagToGameState 3 = Just Paused
tagToGameState 4 = Just Ending
tagToGameState 5 = Just Finished
tagToGameState _ = Nothing

public export
gameStateRoundtrip : (g : GameState) -> tagToGameState (gameStateToTag g) = Just g
gameStateRoundtrip Waiting  = Refl
gameStateRoundtrip Starting = Refl
gameStateRoundtrip Running  = Refl
gameStateRoundtrip Paused   = Refl
gameStateRoundtrip Ending   = Refl
gameStateRoundtrip Finished = Refl

---------------------------------------------------------------------------
-- SyncStrategy (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
syncStrategyToTag : SyncStrategy -> Bits8
syncStrategyToTag Lockstep         = 0
syncStrategyToTag Rollback         = 1
syncStrategyToTag ServerAuth       = 2
syncStrategyToTag ClientPrediction = 3

public export
tagToSyncStrategy : Bits8 -> Maybe SyncStrategy
tagToSyncStrategy 0 = Just Lockstep
tagToSyncStrategy 1 = Just Rollback
tagToSyncStrategy 2 = Just ServerAuth
tagToSyncStrategy 3 = Just ClientPrediction
tagToSyncStrategy _ = Nothing

public export
syncStrategyRoundtrip : (s : SyncStrategy) -> tagToSyncStrategy (syncStrategyToTag s) = Just s
syncStrategyRoundtrip Lockstep         = Refl
syncStrategyRoundtrip Rollback         = Refl
syncStrategyRoundtrip ServerAuth       = Refl
syncStrategyRoundtrip ClientPrediction = Refl

---------------------------------------------------------------------------
-- DisconnectReason (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
disconnectReasonToTag : DisconnectReason -> Bits8
disconnectReasonToTag Timeout        = 0
disconnectReasonToTag Kicked         = 1
disconnectReasonToTag Quit           = 2
disconnectReasonToTag Error          = 3
disconnectReasonToTag ServerShutdown = 4

public export
tagToDisconnectReason : Bits8 -> Maybe DisconnectReason
tagToDisconnectReason 0 = Just Timeout
tagToDisconnectReason 1 = Just Kicked
tagToDisconnectReason 2 = Just Quit
tagToDisconnectReason 3 = Just Error
tagToDisconnectReason 4 = Just ServerShutdown
tagToDisconnectReason _ = Nothing

public export
disconnectReasonRoundtrip : (d : DisconnectReason) -> tagToDisconnectReason (disconnectReasonToTag d) = Just d
disconnectReasonRoundtrip Timeout        = Refl
disconnectReasonRoundtrip Kicked         = Refl
disconnectReasonRoundtrip Quit           = Refl
disconnectReasonRoundtrip Error          = Refl
disconnectReasonRoundtrip ServerShutdown = Refl

---------------------------------------------------------------------------
-- ServerState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| Game server lifecycle states.
public export
data ServerState : Type where
  ||| Server not started. Initial and terminal state.
  GSSIdle      : ServerState
  ||| Server lobby open, accepting players.
  GSSLobby     : ServerState
  ||| Game running.
  GSSRunning   : ServerState
  ||| Game paused.
  GSSPaused    : ServerState
  ||| Server shutting down.
  GSSShutdown  : ServerState

public export
Eq ServerState where
  GSSIdle     == GSSIdle     = True
  GSSLobby    == GSSLobby    = True
  GSSRunning  == GSSRunning  = True
  GSSPaused   == GSSPaused   = True
  GSSShutdown == GSSShutdown = True
  _           == _           = False

public export
Show ServerState where
  show GSSIdle     = "Idle"
  show GSSLobby    = "Lobby"
  show GSSRunning  = "Running"
  show GSSPaused   = "Paused"
  show GSSShutdown = "Shutdown"

public export
serverStateToTag : ServerState -> Bits8
serverStateToTag GSSIdle     = 0
serverStateToTag GSSLobby    = 1
serverStateToTag GSSRunning  = 2
serverStateToTag GSSPaused   = 3
serverStateToTag GSSShutdown = 4

public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just GSSIdle
tagToServerState 1 = Just GSSLobby
tagToServerState 2 = Just GSSRunning
tagToServerState 3 = Just GSSPaused
tagToServerState 4 = Just GSSShutdown
tagToServerState _ = Nothing

public export
serverStateRoundtrip : (s : ServerState) -> tagToServerState (serverStateToTag s) = Just s
serverStateRoundtrip GSSIdle     = Refl
serverStateRoundtrip GSSLobby    = Refl
serverStateRoundtrip GSSRunning  = Refl
serverStateRoundtrip GSSPaused   = Refl
serverStateRoundtrip GSSShutdown = Refl

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

public export
data ValidServerTransition : ServerState -> ServerState -> Type where
  ServerStarted        : ValidServerTransition GSSIdle GSSLobby
  GameStarted          : ValidServerTransition GSSLobby GSSRunning
  GamePaused           : ValidServerTransition GSSRunning GSSPaused
  GameResumed          : ValidServerTransition GSSPaused GSSRunning
  GameEnded            : ValidServerTransition GSSRunning GSSLobby
  ShutdownFromLobby    : ValidServerTransition GSSLobby GSSShutdown
  ShutdownFromRunning  : ValidServerTransition GSSRunning GSSShutdown
  ShutdownFromPaused   : ValidServerTransition GSSPaused GSSShutdown
  CleanupDone          : ValidServerTransition GSSShutdown GSSIdle

public export
validateServerTransition : (from : ServerState) -> (to : ServerState)
                         -> Maybe (ValidServerTransition from to)
validateServerTransition GSSIdle     GSSLobby    = Just ServerStarted
validateServerTransition GSSLobby    GSSRunning  = Just GameStarted
validateServerTransition GSSRunning  GSSPaused   = Just GamePaused
validateServerTransition GSSPaused   GSSRunning  = Just GameResumed
validateServerTransition GSSRunning  GSSLobby    = Just GameEnded
validateServerTransition GSSLobby    GSSShutdown = Just ShutdownFromLobby
validateServerTransition GSSRunning  GSSShutdown = Just ShutdownFromRunning
validateServerTransition GSSPaused   GSSShutdown = Just ShutdownFromPaused
validateServerTransition GSSShutdown GSSIdle     = Just CleanupDone
validateServerTransition _           _           = Nothing

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot start game from Idle (must go through Lobby).
public export
idleCannotRun : ValidServerTransition GSSIdle GSSRunning -> Void
idleCannotRun _ impossible

||| Cannot go from Shutdown back to Lobby directly.
public export
cannotResumeFromShutdown : ValidServerTransition GSSShutdown GSSLobby -> Void
cannotResumeFromShutdown _ impossible
