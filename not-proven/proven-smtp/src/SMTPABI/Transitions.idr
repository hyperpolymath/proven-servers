-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SMTPABI.Transitions: Valid SMTP session state transitions.
--
-- Models the SMTP session lifecycle (RFC 5321 + AUTH/STARTTLS):
--
--   Connected --> Greeted --> AuthStarted --> Authenticated --> MailFrom
--   --> RcptTo --> Data --> MessageReceived --> Quit
--
-- With additional edges:
--   Greeted --MAIL_FROM--> MailFrom        (relay-allowed, no auth needed)
--   Authenticated --MAIL_FROM--> MailFrom  (authenticated sender)
--   MessageReceived --RSET--> Greeted      (reset for next message)
--   MessageReceived --RSET--> Authenticated (reset preserving auth)
--   Any pre-Quit state --QUIT--> Quit      (graceful disconnect)
--   Quit is terminal (no outbound edges)
--
-- The key invariants:
--   1. Cannot DATA before at least one RCPT_TO
--   2. Cannot AUTH after already Authenticated
--   3. Once Quit, no transition is possible
--   4. CanSendMail requires Authenticated or relay-allowed (Greeted)

module SMTPABI.Transitions

import SMTPABI.Layout

%default total

---------------------------------------------------------------------------
-- ValidSmtpTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that an SMTP session state transition is valid.
public export
data ValidSmtpTransition : SmtpSessionState -> SmtpSessionState -> Type where
  ||| Connected -> Greeted (HELO/EHLO received).
  Greet              : ValidSmtpTransition SConnected SGreeted
  ||| Greeted -> AuthStarted (AUTH command received).
  StartAuth          : ValidSmtpTransition SGreeted SAuthStarted
  ||| AuthStarted -> Authenticated (credentials accepted).
  AuthSuccess        : ValidSmtpTransition SAuthStarted SAuthenticated
  ||| AuthStarted -> Greeted (credentials rejected, back to greeting).
  AuthFailure        : ValidSmtpTransition SAuthStarted SGreeted
  ||| Authenticated -> MailFrom (MAIL FROM after authentication).
  AuthMailFrom       : ValidSmtpTransition SAuthenticated SMailFrom
  ||| Greeted -> MailFrom (MAIL FROM without auth, relay-allowed).
  RelayMailFrom      : ValidSmtpTransition SGreeted SMailFrom
  ||| MailFrom -> RcptTo (at least one RCPT TO).
  AddRecipient       : ValidSmtpTransition SMailFrom SRcptTo
  ||| RcptTo -> RcptTo (additional RCPT TO).
  AddMoreRecipients  : ValidSmtpTransition SRcptTo SRcptTo
  ||| RcptTo -> Data (DATA command, message body follows).
  BeginData          : ValidSmtpTransition SRcptTo SData
  ||| Data -> MessageReceived (end-of-data marker received).
  FinishData         : ValidSmtpTransition SData SMessageReceived
  ||| MessageReceived -> Greeted (RSET, ready for new transaction).
  ResetToGreeted     : ValidSmtpTransition SMessageReceived SGreeted
  ||| MessageReceived -> Authenticated (RSET preserving auth).
  ResetToAuth        : ValidSmtpTransition SMessageReceived SAuthenticated
  ||| MailFrom -> Greeted (RSET during transaction).
  ResetFromMailFrom  : ValidSmtpTransition SMailFrom SGreeted
  ||| RcptTo -> Greeted (RSET during transaction).
  ResetFromRcptTo    : ValidSmtpTransition SRcptTo SGreeted
  ||| Connected -> Quit (QUIT before greeting).
  QuitFromConnected  : ValidSmtpTransition SConnected SQuit
  ||| Greeted -> Quit (QUIT after greeting).
  QuitFromGreeted    : ValidSmtpTransition SGreeted SQuit
  ||| Authenticated -> Quit (QUIT after auth).
  QuitFromAuth       : ValidSmtpTransition SAuthenticated SQuit
  ||| MailFrom -> Quit (QUIT during transaction).
  QuitFromMailFrom   : ValidSmtpTransition SMailFrom SQuit
  ||| RcptTo -> Quit (QUIT during transaction).
  QuitFromRcptTo     : ValidSmtpTransition SRcptTo SQuit
  ||| MessageReceived -> Quit (QUIT after message).
  QuitFromMsgRecv    : ValidSmtpTransition SMessageReceived SQuit

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a session can initiate a mail transaction (MAIL FROM).
||| Requires either authenticated status or relay-allowed (greeted).
public export
data CanSendMail : SmtpSessionState -> Type where
  ||| Authenticated users can send mail.
  AuthenticatedCanSend : CanSendMail SAuthenticated
  ||| Relay-allowed (greeted without auth) can send mail.
  RelayCanSend         : CanSendMail SGreeted

||| Proof that a session can begin DATA transfer.
||| Requires at least one recipient (RcptTo state).
public export
data CanBeginData : SmtpSessionState -> Type where
  HasRecipients : CanBeginData SRcptTo

||| Proof that a session can be reset (RSET).
public export
data CanReset : SmtpSessionState -> Type where
  ResetFromMF  : CanReset SMailFrom
  ResetFromRT  : CanReset SRcptTo
  ResetFromMR  : CanReset SMessageReceived

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot leave the Quit state -- it is terminal.
public export
quitIsTerminal : ValidSmtpTransition SQuit s -> Void
quitIsTerminal _ impossible

||| Cannot DATA before RCPT_TO (must be in RcptTo state).
public export
cannotDataFromMailFrom : ValidSmtpTransition SMailFrom SData -> Void
cannotDataFromMailFrom _ impossible

||| Cannot DATA from Connected (no greeting, no sender, no recipients).
public export
cannotDataFromConnected : ValidSmtpTransition SConnected SData -> Void
cannotDataFromConnected _ impossible

||| Cannot AUTH after already authenticated (double-auth).
public export
cannotReAuth : ValidSmtpTransition SAuthenticated SAuthStarted -> Void
cannotReAuth _ impossible

||| Cannot skip from Connected directly to MailFrom (must greet first).
public export
cannotSkipGreeting : ValidSmtpTransition SConnected SMailFrom -> Void
cannotSkipGreeting _ impossible

||| Cannot send data from Data state (only FinishData allowed).
public export
cannotBeginDataFromData : CanBeginData SData -> Void
cannotBeginDataFromData _ impossible

||| Cannot send mail from Connected state (no greeting yet).
public export
cannotSendMailFromConnected : CanSendMail SConnected -> Void
cannotSendMailFromConnected _ impossible

||| Cannot go backwards from MessageReceived to Data.
public export
cannotGoBackToData : ValidSmtpTransition SMessageReceived SData -> Void
cannotGoBackToData _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether an SMTP session state transition is valid.
public export
validateSmtpTransition : (from : SmtpSessionState) -> (to : SmtpSessionState)
                       -> Maybe (ValidSmtpTransition from to)
validateSmtpTransition SConnected       SGreeted         = Just Greet
validateSmtpTransition SGreeted         SAuthStarted     = Just StartAuth
validateSmtpTransition SAuthStarted     SAuthenticated   = Just AuthSuccess
validateSmtpTransition SAuthStarted     SGreeted         = Just AuthFailure
validateSmtpTransition SAuthenticated   SMailFrom        = Just AuthMailFrom
validateSmtpTransition SGreeted         SMailFrom        = Just RelayMailFrom
validateSmtpTransition SMailFrom        SRcptTo          = Just AddRecipient
validateSmtpTransition SRcptTo          SRcptTo          = Just AddMoreRecipients
validateSmtpTransition SRcptTo          SData            = Just BeginData
validateSmtpTransition SData            SMessageReceived = Just FinishData
validateSmtpTransition SMessageReceived SGreeted         = Just ResetToGreeted
validateSmtpTransition SMessageReceived SAuthenticated   = Just ResetToAuth
validateSmtpTransition SMailFrom        SGreeted         = Just ResetFromMailFrom
validateSmtpTransition SRcptTo          SGreeted         = Just ResetFromRcptTo
validateSmtpTransition SConnected       SQuit            = Just QuitFromConnected
validateSmtpTransition SGreeted         SQuit            = Just QuitFromGreeted
validateSmtpTransition SAuthenticated   SQuit            = Just QuitFromAuth
validateSmtpTransition SMailFrom        SQuit            = Just QuitFromMailFrom
validateSmtpTransition SRcptTo          SQuit            = Just QuitFromRcptTo
validateSmtpTransition SMessageReceived SQuit            = Just QuitFromMsgRecv
validateSmtpTransition _                _                = Nothing
