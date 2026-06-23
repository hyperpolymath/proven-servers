-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| The QUIC connection and stream state machines, as proof-carrying
||| transition relations (RFC 9000 Sections 3.1, 3.2, 9-10).
|||
||| Each `ValidXTransition from to` is inhabited only for legal moves, so a
||| value of that type is a machine-checked certificate that the move is
||| allowed.  Illegal moves are ruled out by the `impossible` proofs.
module Quic.Transitions

import Quic.Types

%default total

---------------------------------------------------------------------------
-- Connection lifecycle
---------------------------------------------------------------------------

public export
data ValidConnTransition : ConnState -> ConnState -> Type where
  BeginHandshake     : ValidConnTransition CInitial     CHandshaking
  HandshakeComplete  : ValidConnTransition CHandshaking CConnected
  CloseInHandshake   : ValidConnTransition CHandshaking CClosing
  DrainInHandshake   : ValidConnTransition CHandshaking CDraining
  LocalClose         : ValidConnTransition CConnected   CClosing
  PeerClose          : ValidConnTransition CConnected   CDraining
  ClosingToDraining  : ValidConnTransition CClosing     CDraining
  ClosingTimeout     : ValidConnTransition CClosing     CClosed
  DrainingTimeout    : ValidConnTransition CDraining    CClosed

public export
validateConnTransition : (from : ConnState) -> (to : ConnState)
                       -> Maybe (ValidConnTransition from to)
validateConnTransition CInitial     CHandshaking = Just BeginHandshake
validateConnTransition CHandshaking CConnected   = Just HandshakeComplete
validateConnTransition CHandshaking CClosing     = Just CloseInHandshake
validateConnTransition CHandshaking CDraining    = Just DrainInHandshake
validateConnTransition CConnected   CClosing     = Just LocalClose
validateConnTransition CConnected   CDraining    = Just PeerClose
validateConnTransition CClosing     CDraining    = Just ClosingToDraining
validateConnTransition CClosing     CClosed      = Just ClosingTimeout
validateConnTransition CDraining    CClosed      = Just DrainingTimeout
validateConnTransition _            _            = Nothing

||| `Closed` is terminal — no transitions leave it.
public export
closedIsTerminal : ValidConnTransition CClosed s -> Void
closedIsTerminal _ impossible

||| A connection cannot regress from `Connected` back to `Initial`.
public export
connectedNeverReinitialises : ValidConnTransition CConnected CInitial -> Void
connectedNeverReinitialises _ impossible

||| A draining connection cannot resurrect into `Connected`.
public export
drainingNeverConnects : ValidConnTransition CDraining CConnected -> Void
drainingNeverConnects _ impossible

---------------------------------------------------------------------------
-- Stream sending part (RFC 9000 Section 3.1)
---------------------------------------------------------------------------

public export
data ValidSendTransition : SendState -> SendState -> Type where
  StartSending  : ValidSendTransition SReady    SSend
  SendFin       : ValidSendTransition SSend     SDataSent
  AllAcked      : ValidSendTransition SDataSent SDataRecvd
  ResetFromReady : ValidSendTransition SReady    SResetSent
  ResetFromSend  : ValidSendTransition SSend     SResetSent
  ResetFromSent  : ValidSendTransition SDataSent SResetSent
  ResetAcked     : ValidSendTransition SResetSent SResetRecvd

public export
validateSendTransition : (from : SendState) -> (to : SendState)
                       -> Maybe (ValidSendTransition from to)
validateSendTransition SReady    SSend       = Just StartSending
validateSendTransition SSend     SDataSent   = Just SendFin
validateSendTransition SDataSent SDataRecvd  = Just AllAcked
validateSendTransition SReady    SResetSent  = Just ResetFromReady
validateSendTransition SSend     SResetSent  = Just ResetFromSend
validateSendTransition SDataSent SResetSent  = Just ResetFromSent
validateSendTransition SResetSent SResetRecvd = Just ResetAcked
validateSendTransition _         _           = Nothing

||| Once all data is acknowledged the sending part is complete and final.
public export
dataRecvdIsTerminal : ValidSendTransition SDataRecvd s -> Void
dataRecvdIsTerminal _ impossible

||| A fully-acknowledged stream cannot subsequently be reset.
public export
cannotResetAfterDataRecvd : ValidSendTransition SDataRecvd SResetSent -> Void
cannotResetAfterDataRecvd _ impossible

||| A reset, once acknowledged, is terminal.
public export
resetRecvdIsTerminal : ValidSendTransition SResetRecvd s -> Void
resetRecvdIsTerminal _ impossible

---------------------------------------------------------------------------
-- Stream receiving part (RFC 9000 Section 3.2)
---------------------------------------------------------------------------

public export
data ValidRecvTransition : RecvState -> RecvState -> Type where
  RecvFin       : ValidRecvTransition RRecv      RSizeKnown
  AllReceived   : ValidRecvTransition RSizeKnown RDataRecvd
  AppReadAll    : ValidRecvTransition RDataRecvd RDataRead
  ResetWhileRecv : ValidRecvTransition RRecv      RResetRecvd
  ResetWhileSize : ValidRecvTransition RSizeKnown RResetRecvd
  AppReadReset   : ValidRecvTransition RResetRecvd RResetRead

public export
validateRecvTransition : (from : RecvState) -> (to : RecvState)
                       -> Maybe (ValidRecvTransition from to)
validateRecvTransition RRecv      RSizeKnown  = Just RecvFin
validateRecvTransition RSizeKnown RDataRecvd  = Just AllReceived
validateRecvTransition RDataRecvd RDataRead   = Just AppReadAll
validateRecvTransition RRecv      RResetRecvd = Just ResetWhileRecv
validateRecvTransition RSizeKnown RResetRecvd = Just ResetWhileSize
validateRecvTransition RResetRecvd RResetRead = Just AppReadReset
validateRecvTransition _          _           = Nothing

||| The application reading all data is the terminal receive state.
public export
dataReadIsTerminal : ValidRecvTransition RDataRead s -> Void
dataReadIsTerminal _ impossible

||| A reset receive stream cannot transition back to ordinary delivery.
public export
resetReadIsTerminal : ValidRecvTransition RResetRead s -> Void
resetReadIsTerminal _ impossible
