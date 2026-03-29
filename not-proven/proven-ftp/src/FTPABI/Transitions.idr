-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FTPABI.Transitions: Valid FTP session state transitions.
--
-- Models the FTP session lifecycle (RFC 959 Section 4.1):
--
--   Connected --USER--> UserOk --PASS--> Authenticated
--   Authenticated --RNFR--> Renaming --RNTO--> Authenticated
--   Authenticated --file ops--> Authenticated
--   Any state --QUIT--> Quit
--
-- Key invariants:
--   - Cannot transfer files before authentication (CanTransfer requires Authenticated)
--   - Cannot RETR/STOR/LIST/NLST without authentication
--   - Quit is terminal (no outbound edges)
--   - Renaming requires RNTO before any other command
--   - PASS is only valid from UserOk

module FTPABI.Transitions

import FTP.Session

%default total

---------------------------------------------------------------------------
-- ValidSessionTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that an FTP session state transition is valid.
public export
data ValidSessionTransition : SessionState -> SessionState -> Type where
  ||| Connected -> UserOk (USER accepted, awaiting PASS).
  AcceptUser      : ValidSessionTransition Connected UserOk
  ||| UserOk -> Authenticated (PASS accepted, login complete).
  AcceptPass      : ValidSessionTransition UserOk Authenticated
  ||| UserOk -> UserOk (re-USER to change username before PASS).
  ReUser          : ValidSessionTransition UserOk UserOk
  ||| Authenticated -> Authenticated (file operations, NOOP, SYST, TYPE, etc.).
  FileOp          : ValidSessionTransition Authenticated Authenticated
  ||| Authenticated -> Renaming (RNFR accepted, awaiting RNTO).
  BeginRename     : ValidSessionTransition Authenticated Renaming
  ||| Renaming -> Authenticated (RNTO accepted, rename complete).
  CompleteRename  : ValidSessionTransition Renaming Authenticated
  ||| Renaming -> Renaming (NOOP during rename).
  RenamingNoop    : ValidSessionTransition Renaming Renaming
  ||| Authenticated -> UserOk (re-login with USER).
  ReLogin         : ValidSessionTransition Authenticated UserOk
  ||| Connected -> Quit (QUIT before login).
  QuitConnected   : ValidSessionTransition Connected Quit
  ||| UserOk -> Quit (QUIT during login).
  QuitUserOk      : ValidSessionTransition UserOk Quit
  ||| Authenticated -> Quit (QUIT after login).
  QuitAuth        : ValidSessionTransition Authenticated Quit
  ||| Renaming -> Quit (QUIT during rename).
  QuitRenaming    : ValidSessionTransition Renaming Quit

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a session can perform file transfers (RETR, STOR, LIST, NLST).
public export
data CanTransfer : SessionState -> Type where
  AuthenticatedCanTransfer : CanTransfer Authenticated

||| Proof that a session can change directories (CWD, CDUP).
public export
data CanNavigate : SessionState -> Type where
  AuthenticatedCanNavigate : CanNavigate Authenticated

||| Proof that a session can modify the filesystem (DELE, MKD, RMD).
public export
data CanModify : SessionState -> Type where
  AuthenticatedCanModify : CanModify Authenticated

||| Proof that a session can set transfer parameters (TYPE, PORT, PASV).
public export
data CanSetParams : SessionState -> Type where
  AuthenticatedCanSetParams : CanSetParams Authenticated

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot leave the Quit state -- it is terminal.
public export
quitIsTerminal : ValidSessionTransition Quit s -> Void
quitIsTerminal _ impossible

||| Cannot transfer files from Connected state.
public export
cannotTransferFromConnected : CanTransfer Connected -> Void
cannotTransferFromConnected _ impossible

||| Cannot transfer files from UserOk state.
public export
cannotTransferFromUserOk : CanTransfer UserOk -> Void
cannotTransferFromUserOk _ impossible

||| Cannot transfer files from Renaming state.
public export
cannotTransferFromRenaming : CanTransfer Renaming -> Void
cannotTransferFromRenaming _ impossible

||| Cannot transfer files from Quit state.
public export
cannotTransferFromQuit : CanTransfer Quit -> Void
cannotTransferFromQuit _ impossible

||| Cannot skip from Connected directly to Authenticated (must USER then PASS).
public export
cannotSkipLogin : ValidSessionTransition Connected Authenticated -> Void
cannotSkipLogin _ impossible

||| Cannot go from Connected directly to Renaming.
public export
cannotRenameFromConnected : ValidSessionTransition Connected Renaming -> Void
cannotRenameFromConnected _ impossible

||| Cannot PASS from Connected (must USER first).
public export
cannotPassFromConnected : ValidSessionTransition Connected Authenticated -> Void
cannotPassFromConnected _ impossible

||| Cannot navigate from UserOk.
public export
cannotNavigateFromUserOk : CanNavigate UserOk -> Void
cannotNavigateFromUserOk _ impossible

||| Cannot modify from Connected.
public export
cannotModifyFromConnected : CanModify Connected -> Void
cannotModifyFromConnected _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether an FTP session state transition is valid.
public export
validateSessionTransition : (from : SessionState) -> (to : SessionState)
                         -> Maybe (ValidSessionTransition from to)
validateSessionTransition Connected     UserOk        = Just AcceptUser
validateSessionTransition Connected     Quit          = Just QuitConnected
validateSessionTransition UserOk        Authenticated = Just AcceptPass
validateSessionTransition UserOk        UserOk        = Just ReUser
validateSessionTransition UserOk        Quit          = Just QuitUserOk
validateSessionTransition Authenticated Authenticated = Just FileOp
validateSessionTransition Authenticated Renaming      = Just BeginRename
validateSessionTransition Authenticated UserOk        = Just ReLogin
validateSessionTransition Authenticated Quit          = Just QuitAuth
validateSessionTransition Renaming      Authenticated = Just CompleteRename
validateSessionTransition Renaming      Renaming      = Just RenamingNoop
validateSessionTransition Renaming      Quit          = Just QuitRenaming
validateSessionTransition _             _             = Nothing
