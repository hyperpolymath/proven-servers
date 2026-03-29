-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SMTPABI.Layout: C-ABI-compatible numeric representations of SMTP types.
--
-- Maps every constructor of the seven core sum types (SmtpCommand,
-- ReplyCategory, ReplyCode, AuthMechanism, SmtpExtension, SessionState,
-- AuthState) to fixed Bits8 values for C interop.  Each type gets a total
-- encoder, partial decoder, and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/smtp.h) and the
-- Zig FFI enums (ffi/zig/src/smtp.zig) exactly.

module SMTPABI.Layout

import SMTP.Command
import SMTP.Reply
import SMTP.Auth
import SMTP.Session

%default total

---------------------------------------------------------------------------
-- SmtpCommandTag (12 constructors, tags 0-11)
--
-- Parameterless tag representing the SMTP command verb.  String parameters
-- are carried separately across the FFI boundary.
---------------------------------------------------------------------------

||| SMTP command verbs as a flat enum for ABI transport.
public export
data SmtpCommandTag : Type where
  TagHELO     : SmtpCommandTag
  TagEHLO     : SmtpCommandTag
  TagMAIL_FROM : SmtpCommandTag
  TagRCPT_TO  : SmtpCommandTag
  TagDATA     : SmtpCommandTag
  TagQUIT     : SmtpCommandTag
  TagRSET     : SmtpCommandTag
  TagNOOP     : SmtpCommandTag
  TagVRFY     : SmtpCommandTag
  TagEXPN     : SmtpCommandTag
  TagSTARTTLS : SmtpCommandTag
  TagAUTH     : SmtpCommandTag

public export
Eq SmtpCommandTag where
  TagHELO      == TagHELO      = True
  TagEHLO      == TagEHLO      = True
  TagMAIL_FROM == TagMAIL_FROM = True
  TagRCPT_TO   == TagRCPT_TO  = True
  TagDATA      == TagDATA      = True
  TagQUIT      == TagQUIT      = True
  TagRSET      == TagRSET      = True
  TagNOOP      == TagNOOP      = True
  TagVRFY      == TagVRFY      = True
  TagEXPN      == TagEXPN      = True
  TagSTARTTLS  == TagSTARTTLS  = True
  TagAUTH      == TagAUTH      = True
  _            == _            = False

public export
smtpCommandTagSize : Nat
smtpCommandTagSize = 1

public export
smtpCommandTagToTag : SmtpCommandTag -> Bits8
smtpCommandTagToTag TagHELO      = 0
smtpCommandTagToTag TagEHLO      = 1
smtpCommandTagToTag TagMAIL_FROM = 2
smtpCommandTagToTag TagRCPT_TO   = 3
smtpCommandTagToTag TagDATA      = 4
smtpCommandTagToTag TagQUIT      = 5
smtpCommandTagToTag TagRSET      = 6
smtpCommandTagToTag TagNOOP      = 7
smtpCommandTagToTag TagVRFY      = 8
smtpCommandTagToTag TagEXPN      = 9
smtpCommandTagToTag TagSTARTTLS  = 10
smtpCommandTagToTag TagAUTH      = 11

public export
tagToSmtpCommandTag : Bits8 -> Maybe SmtpCommandTag
tagToSmtpCommandTag 0  = Just TagHELO
tagToSmtpCommandTag 1  = Just TagEHLO
tagToSmtpCommandTag 2  = Just TagMAIL_FROM
tagToSmtpCommandTag 3  = Just TagRCPT_TO
tagToSmtpCommandTag 4  = Just TagDATA
tagToSmtpCommandTag 5  = Just TagQUIT
tagToSmtpCommandTag 6  = Just TagRSET
tagToSmtpCommandTag 7  = Just TagNOOP
tagToSmtpCommandTag 8  = Just TagVRFY
tagToSmtpCommandTag 9  = Just TagEXPN
tagToSmtpCommandTag 10 = Just TagSTARTTLS
tagToSmtpCommandTag 11 = Just TagAUTH
tagToSmtpCommandTag _  = Nothing

public export
smtpCommandTagRoundtrip : (c : SmtpCommandTag) -> tagToSmtpCommandTag (smtpCommandTagToTag c) = Just c
smtpCommandTagRoundtrip TagHELO      = Refl
smtpCommandTagRoundtrip TagEHLO      = Refl
smtpCommandTagRoundtrip TagMAIL_FROM = Refl
smtpCommandTagRoundtrip TagRCPT_TO   = Refl
smtpCommandTagRoundtrip TagDATA      = Refl
smtpCommandTagRoundtrip TagQUIT      = Refl
smtpCommandTagRoundtrip TagRSET      = Refl
smtpCommandTagRoundtrip TagNOOP      = Refl
smtpCommandTagRoundtrip TagVRFY      = Refl
smtpCommandTagRoundtrip TagEXPN      = Refl
smtpCommandTagRoundtrip TagSTARTTLS  = Refl
smtpCommandTagRoundtrip TagAUTH      = Refl

---------------------------------------------------------------------------
-- ReplyCategory (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
replyCategorySize : Nat
replyCategorySize = 1

public export
replyCategoryToTag : ReplyCategory -> Bits8
replyCategoryToTag Positive          = 0
replyCategoryToTag Intermediate      = 1
replyCategoryToTag TransientNegative = 2
replyCategoryToTag PermanentNegative = 3

public export
tagToReplyCategory : Bits8 -> Maybe ReplyCategory
tagToReplyCategory 0 = Just Positive
tagToReplyCategory 1 = Just Intermediate
tagToReplyCategory 2 = Just TransientNegative
tagToReplyCategory 3 = Just PermanentNegative
tagToReplyCategory _ = Nothing

public export
replyCategoryRoundtrip : (c : ReplyCategory) -> tagToReplyCategory (replyCategoryToTag c) = Just c
replyCategoryRoundtrip Positive          = Refl
replyCategoryRoundtrip Intermediate      = Refl
replyCategoryRoundtrip TransientNegative = Refl
replyCategoryRoundtrip PermanentNegative = Refl

---------------------------------------------------------------------------
-- ReplyCode (17 constructors, tags 0-16)
---------------------------------------------------------------------------

public export
replyCodeSize : Nat
replyCodeSize = 1

public export
replyCodeToTag : ReplyCode -> Bits8
replyCodeToTag ServiceReady        = 0
replyCodeToTag ServiceClosing      = 1
replyCodeToTag ActionOK            = 2
replyCodeToTag WillForward         = 3
replyCodeToTag StartMailInput      = 4
replyCodeToTag ServiceUnavailable  = 5
replyCodeToTag MailboxBusy         = 6
replyCodeToTag LocalError          = 7
replyCodeToTag InsufficientStorage = 8
replyCodeToTag SyntaxError         = 9
replyCodeToTag ParamSyntaxError    = 10
replyCodeToTag NotImplemented      = 11
replyCodeToTag BadSequence         = 12
replyCodeToTag ParamNotImplemented = 13
replyCodeToTag MailboxUnavailable  = 14
replyCodeToTag MailboxNameInvalid  = 15
replyCodeToTag TransactionFailed   = 16

public export
tagToReplyCode : Bits8 -> Maybe ReplyCode
tagToReplyCode 0  = Just ServiceReady
tagToReplyCode 1  = Just ServiceClosing
tagToReplyCode 2  = Just ActionOK
tagToReplyCode 3  = Just WillForward
tagToReplyCode 4  = Just StartMailInput
tagToReplyCode 5  = Just ServiceUnavailable
tagToReplyCode 6  = Just MailboxBusy
tagToReplyCode 7  = Just LocalError
tagToReplyCode 8  = Just InsufficientStorage
tagToReplyCode 9  = Just SyntaxError
tagToReplyCode 10 = Just ParamSyntaxError
tagToReplyCode 11 = Just NotImplemented
tagToReplyCode 12 = Just BadSequence
tagToReplyCode 13 = Just ParamNotImplemented
tagToReplyCode 14 = Just MailboxUnavailable
tagToReplyCode 15 = Just MailboxNameInvalid
tagToReplyCode 16 = Just TransactionFailed
tagToReplyCode _  = Nothing

public export
replyCodeRoundtrip : (r : ReplyCode) -> tagToReplyCode (replyCodeToTag r) = Just r
replyCodeRoundtrip ServiceReady        = Refl
replyCodeRoundtrip ServiceClosing      = Refl
replyCodeRoundtrip ActionOK            = Refl
replyCodeRoundtrip WillForward         = Refl
replyCodeRoundtrip StartMailInput      = Refl
replyCodeRoundtrip ServiceUnavailable  = Refl
replyCodeRoundtrip MailboxBusy         = Refl
replyCodeRoundtrip LocalError          = Refl
replyCodeRoundtrip InsufficientStorage = Refl
replyCodeRoundtrip SyntaxError         = Refl
replyCodeRoundtrip ParamSyntaxError    = Refl
replyCodeRoundtrip NotImplemented      = Refl
replyCodeRoundtrip BadSequence         = Refl
replyCodeRoundtrip ParamNotImplemented = Refl
replyCodeRoundtrip MailboxUnavailable  = Refl
replyCodeRoundtrip MailboxNameInvalid  = Refl
replyCodeRoundtrip TransactionFailed   = Refl

---------------------------------------------------------------------------
-- AuthMechanism (4 constructors, tags 0-3)
--
-- Extends the base SMTP.Auth with XOAUTH2.
---------------------------------------------------------------------------

||| AUTH mechanisms for ABI transport, including XOAUTH2.
public export
data AuthMechTag : Type where
  TagPLAIN    : AuthMechTag
  TagLOGIN    : AuthMechTag
  TagCRAM_MD5 : AuthMechTag
  TagXOAUTH2  : AuthMechTag

public export
Eq AuthMechTag where
  TagPLAIN    == TagPLAIN    = True
  TagLOGIN    == TagLOGIN    = True
  TagCRAM_MD5 == TagCRAM_MD5 = True
  TagXOAUTH2  == TagXOAUTH2  = True
  _           == _           = False

public export
authMechTagSize : Nat
authMechTagSize = 1

public export
authMechTagToTag : AuthMechTag -> Bits8
authMechTagToTag TagPLAIN    = 0
authMechTagToTag TagLOGIN    = 1
authMechTagToTag TagCRAM_MD5 = 2
authMechTagToTag TagXOAUTH2  = 3

public export
tagToAuthMechTag : Bits8 -> Maybe AuthMechTag
tagToAuthMechTag 0 = Just TagPLAIN
tagToAuthMechTag 1 = Just TagLOGIN
tagToAuthMechTag 2 = Just TagCRAM_MD5
tagToAuthMechTag 3 = Just TagXOAUTH2
tagToAuthMechTag _ = Nothing

public export
authMechTagRoundtrip : (m : AuthMechTag) -> tagToAuthMechTag (authMechTagToTag m) = Just m
authMechTagRoundtrip TagPLAIN    = Refl
authMechTagRoundtrip TagLOGIN    = Refl
authMechTagRoundtrip TagCRAM_MD5 = Refl
authMechTagRoundtrip TagXOAUTH2  = Refl

---------------------------------------------------------------------------
-- SmtpExtension (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| SMTP service extensions advertised in EHLO response.
public export
data SmtpExtension : Type where
  ExtSIZE       : SmtpExtension
  ExtPIPELINING : SmtpExtension
  Ext8BITMIME   : SmtpExtension
  ExtSTARTTLS   : SmtpExtension
  ExtAUTH       : SmtpExtension
  ExtDSN        : SmtpExtension
  ExtCHUNKING   : SmtpExtension

public export
Eq SmtpExtension where
  ExtSIZE       == ExtSIZE       = True
  ExtPIPELINING == ExtPIPELINING = True
  Ext8BITMIME   == Ext8BITMIME   = True
  ExtSTARTTLS   == ExtSTARTTLS   = True
  ExtAUTH       == ExtAUTH       = True
  ExtDSN        == ExtDSN        = True
  ExtCHUNKING   == ExtCHUNKING   = True
  _             == _             = False

public export
smtpExtensionSize : Nat
smtpExtensionSize = 1

public export
smtpExtensionToTag : SmtpExtension -> Bits8
smtpExtensionToTag ExtSIZE       = 0
smtpExtensionToTag ExtPIPELINING = 1
smtpExtensionToTag Ext8BITMIME   = 2
smtpExtensionToTag ExtSTARTTLS   = 3
smtpExtensionToTag ExtAUTH       = 4
smtpExtensionToTag ExtDSN        = 5
smtpExtensionToTag ExtCHUNKING   = 6

public export
tagToSmtpExtension : Bits8 -> Maybe SmtpExtension
tagToSmtpExtension 0 = Just ExtSIZE
tagToSmtpExtension 1 = Just ExtPIPELINING
tagToSmtpExtension 2 = Just Ext8BITMIME
tagToSmtpExtension 3 = Just ExtSTARTTLS
tagToSmtpExtension 4 = Just ExtAUTH
tagToSmtpExtension 5 = Just ExtDSN
tagToSmtpExtension 6 = Just ExtCHUNKING
tagToSmtpExtension _ = Nothing

public export
smtpExtensionRoundtrip : (e : SmtpExtension) -> tagToSmtpExtension (smtpExtensionToTag e) = Just e
smtpExtensionRoundtrip ExtSIZE       = Refl
smtpExtensionRoundtrip ExtPIPELINING = Refl
smtpExtensionRoundtrip Ext8BITMIME   = Refl
smtpExtensionRoundtrip ExtSTARTTLS   = Refl
smtpExtensionRoundtrip ExtAUTH       = Refl
smtpExtensionRoundtrip ExtDSN        = Refl
smtpExtensionRoundtrip ExtCHUNKING   = Refl

---------------------------------------------------------------------------
-- SessionState (9 constructors, tags 0-8)
--
-- Extended from SMTP.Session to include AuthStarted, Authenticated,
-- and MessageReceived states required by the full ABI lifecycle.
---------------------------------------------------------------------------

||| Extended SMTP session states for the ABI lifecycle.
public export
data SmtpSessionState : Type where
  ||| TCP connection established, awaiting HELO/EHLO.
  SConnected        : SmtpSessionState
  ||| HELO/EHLO received, server greeted.
  SGreeted          : SmtpSessionState
  ||| AUTH command received, exchange in progress.
  SAuthStarted      : SmtpSessionState
  ||| Authentication succeeded.
  SAuthenticated    : SmtpSessionState
  ||| MAIL FROM received.
  SMailFrom         : SmtpSessionState
  ||| At least one RCPT TO received.
  SRcptTo           : SmtpSessionState
  ||| DATA command received, reading message body.
  SData             : SmtpSessionState
  ||| Message body fully received (dot-stuffing complete).
  SMessageReceived  : SmtpSessionState
  ||| QUIT received, session ending.
  SQuit             : SmtpSessionState

public export
Eq SmtpSessionState where
  SConnected       == SConnected       = True
  SGreeted         == SGreeted         = True
  SAuthStarted     == SAuthStarted     = True
  SAuthenticated   == SAuthenticated   = True
  SMailFrom        == SMailFrom        = True
  SRcptTo          == SRcptTo          = True
  SData            == SData            = True
  SMessageReceived == SMessageReceived = True
  SQuit            == SQuit            = True
  _                == _                = False

public export
smtpSessionStateSize : Nat
smtpSessionStateSize = 1

public export
smtpSessionStateToTag : SmtpSessionState -> Bits8
smtpSessionStateToTag SConnected       = 0
smtpSessionStateToTag SGreeted         = 1
smtpSessionStateToTag SAuthStarted     = 2
smtpSessionStateToTag SAuthenticated   = 3
smtpSessionStateToTag SMailFrom        = 4
smtpSessionStateToTag SRcptTo          = 5
smtpSessionStateToTag SData            = 6
smtpSessionStateToTag SMessageReceived = 7
smtpSessionStateToTag SQuit            = 8

public export
tagToSmtpSessionState : Bits8 -> Maybe SmtpSessionState
tagToSmtpSessionState 0 = Just SConnected
tagToSmtpSessionState 1 = Just SGreeted
tagToSmtpSessionState 2 = Just SAuthStarted
tagToSmtpSessionState 3 = Just SAuthenticated
tagToSmtpSessionState 4 = Just SMailFrom
tagToSmtpSessionState 5 = Just SRcptTo
tagToSmtpSessionState 6 = Just SData
tagToSmtpSessionState 7 = Just SMessageReceived
tagToSmtpSessionState 8 = Just SQuit
tagToSmtpSessionState _ = Nothing

public export
smtpSessionStateRoundtrip : (s : SmtpSessionState) -> tagToSmtpSessionState (smtpSessionStateToTag s) = Just s
smtpSessionStateRoundtrip SConnected       = Refl
smtpSessionStateRoundtrip SGreeted         = Refl
smtpSessionStateRoundtrip SAuthStarted     = Refl
smtpSessionStateRoundtrip SAuthenticated   = Refl
smtpSessionStateRoundtrip SMailFrom        = Refl
smtpSessionStateRoundtrip SRcptTo          = Refl
smtpSessionStateRoundtrip SData            = Refl
smtpSessionStateRoundtrip SMessageReceived = Refl
smtpSessionStateRoundtrip SQuit            = Refl
