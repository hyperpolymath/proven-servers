-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- BGPABI.Transitions: Valid BGP FSM state transitions and capability proofs.
--
-- The BGP-4 FSM (RFC 4271 Section 8) has 6 states:
--
--   Idle --ManualStart/AutoStart--> Connect --TcpOk--> OpenSent
--     ^        |      ^               |                    |
--     |   ConnRetry   |          TcpFail              BGPOpenRx
--     |        v      |               v                    v
--     +---  Connect  Active        Active              OpenConfirm
--     |                                                    |
--     |                                              KeepAliveMsg
--     |                                                    v
--     +------- any error/stop -------- Established <-------+
--
-- Every arrow has exactly one ValidBGPTransition constructor.
-- Invalid transitions are impossible to construct -- rejected at compile time.

module BGPABI.Transitions

import BGP.FSM
import BGPABI.Layout

%default total

---------------------------------------------------------------------------
-- ValidBGPTransition: exhaustive enumeration of legal state transitions.
---------------------------------------------------------------------------

||| Proof witness that a BGP FSM state transition is valid per RFC 4271.
public export
data ValidBGPTransition : BGPState -> BGPState -> Type where
  -- From Idle
  ||| Idle -> Connect (ManualStart or AutomaticStart).
  IdleToConnect      : ValidBGPTransition Idle Connect

  -- From Connect
  ||| Connect -> OpenSent (TCP connection succeeded).
  ConnectToOpenSent  : ValidBGPTransition Connect OpenSent
  ||| Connect -> Active (TCP connection failed).
  ConnectToActive    : ValidBGPTransition Connect Active
  ||| Connect -> OpenConfirm (BGP OPEN received during connect).
  ConnectToOpenConf  : ValidBGPTransition Connect OpenConfirm
  ||| Connect -> Idle (error or ManualStop).
  ConnectToIdle      : ValidBGPTransition Connect Idle

  -- From Active
  ||| Active -> Connect (connect retry timer expired).
  ActiveToConnect    : ValidBGPTransition Active Connect
  ||| Active -> OpenSent (TCP connection succeeded).
  ActiveToOpenSent   : ValidBGPTransition Active OpenSent
  ||| Active -> OpenConfirm (BGP OPEN received).
  ActiveToOpenConf   : ValidBGPTransition Active OpenConfirm
  ||| Active -> Idle (error or ManualStop).
  ActiveToIdle       : ValidBGPTransition Active Idle

  -- From OpenSent
  ||| OpenSent -> OpenConfirm (BGP OPEN received and valid).
  OpenSentToOpenConf : ValidBGPTransition OpenSent OpenConfirm
  ||| OpenSent -> Active (TCP connection fails).
  OpenSentToActive   : ValidBGPTransition OpenSent Active
  ||| OpenSent -> Idle (error, ManualStop, or HoldTimerExpires).
  OpenSentToIdle     : ValidBGPTransition OpenSent Idle

  -- From OpenConfirm
  ||| OpenConfirm -> Established (KeepAliveMsg received).
  OpenConfToEstab    : ValidBGPTransition OpenConfirm Established
  ||| OpenConfirm -> OpenConfirm (KeepaliveTimerExpires, send keepalive).
  OpenConfToOpenConf : ValidBGPTransition OpenConfirm OpenConfirm
  ||| OpenConfirm -> Idle (error, ManualStop, or HoldTimerExpires).
  OpenConfToIdle     : ValidBGPTransition OpenConfirm Idle

  -- From Established
  ||| Established -> Established (KeepAliveMsg, UpdateMsg, KeepaliveTimerExpires).
  EstabToEstab       : ValidBGPTransition Established Established
  ||| Established -> Idle (error, ManualStop, HoldTimerExpires, NotifMsg).
  EstabToIdle        : ValidBGPTransition Established Idle

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a BGP session can exchange UPDATE messages.
||| Only the Established state allows route exchange.
public export
data CanExchangeRoutes : BGPState -> Type where
  EstablishedCanExchange : CanExchangeRoutes Established

||| Proof that a BGP session can send KEEPALIVE messages.
||| Requires OpenConfirm or Established state.
public export
data CanSendKeepalive : BGPState -> Type where
  OpenConfCanKeepalive : CanSendKeepalive OpenConfirm
  EstabCanKeepalive    : CanSendKeepalive Established

||| Proof that a BGP session can initiate a TCP connection.
||| Requires Idle or Connect state.
public export
data CanInitiateTcp : BGPState -> Type where
  IdleCanInitiate    : CanInitiateTcp Idle
  ConnectCanInitiate : CanInitiateTcp Connect
  ActiveCanInitiate  : CanInitiateTcp Active

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot exchange routes from Idle.
public export
idleCannotExchange : CanExchangeRoutes Idle -> Void
idleCannotExchange _ impossible

||| Cannot exchange routes from Connect.
public export
connectCannotExchange : CanExchangeRoutes Connect -> Void
connectCannotExchange _ impossible

||| Cannot exchange routes from Active.
public export
activeCannotExchange : CanExchangeRoutes Active -> Void
activeCannotExchange _ impossible

||| Cannot exchange routes from OpenSent.
public export
openSentCannotExchange : CanExchangeRoutes OpenSent -> Void
openSentCannotExchange _ impossible

||| Cannot exchange routes from OpenConfirm.
public export
openConfirmCannotExchange : CanExchangeRoutes OpenConfirm -> Void
openConfirmCannotExchange _ impossible

||| Cannot transition from Idle directly to Established (must go through FSM).
public export
cannotSkipToEstablished : ValidBGPTransition Idle Established -> Void
cannotSkipToEstablished _ impossible

||| Cannot transition from Idle to OpenSent directly.
public export
cannotSkipToOpenSent : ValidBGPTransition Idle OpenSent -> Void
cannotSkipToOpenSent _ impossible

||| Cannot transition from Established to Connect.
public export
cannotEstabToConnect : ValidBGPTransition Established Connect -> Void
cannotEstabToConnect _ impossible

||| Cannot transition from Established to Active.
public export
cannotEstabToActive : ValidBGPTransition Established Active -> Void
cannotEstabToActive _ impossible

---------------------------------------------------------------------------
-- Decidability: runtime decision procedures for capabilities.
---------------------------------------------------------------------------

||| Decide at runtime whether a given state permits route exchange.
public export
canExchangeRoutes : (s : BGPState) -> Dec (CanExchangeRoutes s)
canExchangeRoutes Idle        = No idleCannotExchange
canExchangeRoutes Connect     = No connectCannotExchange
canExchangeRoutes Active      = No activeCannotExchange
canExchangeRoutes OpenSent    = No openSentCannotExchange
canExchangeRoutes OpenConfirm = No openConfirmCannotExchange
canExchangeRoutes Established = Yes EstablishedCanExchange

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a BGP state transition is valid.
public export
validateBGPTransition : (from : BGPState) -> (to : BGPState)
                     -> Maybe (ValidBGPTransition from to)
validateBGPTransition Idle        Connect     = Just IdleToConnect
validateBGPTransition Connect     OpenSent    = Just ConnectToOpenSent
validateBGPTransition Connect     Active      = Just ConnectToActive
validateBGPTransition Connect     OpenConfirm = Just ConnectToOpenConf
validateBGPTransition Connect     Idle        = Just ConnectToIdle
validateBGPTransition Active      Connect     = Just ActiveToConnect
validateBGPTransition Active      OpenSent    = Just ActiveToOpenSent
validateBGPTransition Active      OpenConfirm = Just ActiveToOpenConf
validateBGPTransition Active      Idle        = Just ActiveToIdle
validateBGPTransition OpenSent    OpenConfirm = Just OpenSentToOpenConf
validateBGPTransition OpenSent    Active      = Just OpenSentToActive
validateBGPTransition OpenSent    Idle        = Just OpenSentToIdle
validateBGPTransition OpenConfirm Established = Just OpenConfToEstab
validateBGPTransition OpenConfirm OpenConfirm = Just OpenConfToOpenConf
validateBGPTransition OpenConfirm Idle        = Just OpenConfToIdle
validateBGPTransition Established Established = Just EstabToEstab
validateBGPTransition Established Idle        = Just EstabToIdle
validateBGPTransition _           _           = Nothing
