-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SmtpABI.Types: C-ABI-compatible numeric representations of Smtp types.
--
-- Maps every constructor of the core Smtp sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/smtp.zig) exactly.
--
-- Types covered:
--   SmtpCommandTag            (12 constructors, tags 0-11)
--   ReplyCategory             (4 constructors, tags 0-3)
--   ReplyCode                 (17 constructors, tags 0-16)
--   AuthMechTag               (4 constructors, tags 0-3)
--   SmtpExtension             (7 constructors, tags 0-6)
--   SmtpSessionState          (9 constructors, tags 0-8)

module SmtpABI.Types

%default total

---------------------------------------------------------------------------
-- SmtpCommandTag (12 constructors, tags 0-11)
---------------------------------------------------------------------------

public export
smtp_command_tagSize : Nat
smtp_command_tagSize = 1

||| SmtpCommandTag sum type for ABI encoding.
public export
data SmtpCommandTag : Type where
  Helo : SmtpCommandTag
  Ehlo : SmtpCommandTag
  MailFrom : SmtpCommandTag
  RcptTo : SmtpCommandTag
  Data : SmtpCommandTag
  Quit : SmtpCommandTag
  Rset : SmtpCommandTag
  Noop : SmtpCommandTag
  Vrfy : SmtpCommandTag
  Expn : SmtpCommandTag
  Starttls : SmtpCommandTag
  Auth : SmtpCommandTag

||| Encode a SmtpCommandTag to its ABI tag value.
public export
smtp_command_tagToTag : SmtpCommandTag -> Bits8
smtp_command_tagToTag Helo = 0
smtp_command_tagToTag Ehlo = 1
smtp_command_tagToTag MailFrom = 2
smtp_command_tagToTag RcptTo = 3
smtp_command_tagToTag Data = 4
smtp_command_tagToTag Quit = 5
smtp_command_tagToTag Rset = 6
smtp_command_tagToTag Noop = 7
smtp_command_tagToTag Vrfy = 8
smtp_command_tagToTag Expn = 9
smtp_command_tagToTag Starttls = 10
smtp_command_tagToTag Auth = 11

||| Decode an ABI tag to a SmtpCommandTag.
public export
tagToSmtpCommandTag : Bits8 -> Maybe SmtpCommandTag
tagToSmtpCommandTag 0 = Just Helo
tagToSmtpCommandTag 1 = Just Ehlo
tagToSmtpCommandTag 2 = Just MailFrom
tagToSmtpCommandTag 3 = Just RcptTo
tagToSmtpCommandTag 4 = Just Data
tagToSmtpCommandTag 5 = Just Quit
tagToSmtpCommandTag 6 = Just Rset
tagToSmtpCommandTag 7 = Just Noop
tagToSmtpCommandTag 8 = Just Vrfy
tagToSmtpCommandTag 9 = Just Expn
tagToSmtpCommandTag 10 = Just Starttls
tagToSmtpCommandTag 11 = Just Auth
tagToSmtpCommandTag _ = Nothing

||| Roundtrip proof: decoding an encoded SmtpCommandTag yields the original.
public export
smtp_command_tagRoundtrip : (x : SmtpCommandTag) -> tagToSmtpCommandTag (smtp_command_tagToTag x) = Just x
smtp_command_tagRoundtrip Helo = Refl
smtp_command_tagRoundtrip Ehlo = Refl
smtp_command_tagRoundtrip MailFrom = Refl
smtp_command_tagRoundtrip RcptTo = Refl
smtp_command_tagRoundtrip Data = Refl
smtp_command_tagRoundtrip Quit = Refl
smtp_command_tagRoundtrip Rset = Refl
smtp_command_tagRoundtrip Noop = Refl
smtp_command_tagRoundtrip Vrfy = Refl
smtp_command_tagRoundtrip Expn = Refl
smtp_command_tagRoundtrip Starttls = Refl
smtp_command_tagRoundtrip Auth = Refl

---------------------------------------------------------------------------
-- ReplyCategory (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
reply_categorySize : Nat
reply_categorySize = 1

||| ReplyCategory sum type for ABI encoding.
public export
data ReplyCategory : Type where
  Positive : ReplyCategory
  Intermediate : ReplyCategory
  TransientNegative : ReplyCategory
  PermanentNegative : ReplyCategory

||| Encode a ReplyCategory to its ABI tag value.
public export
reply_categoryToTag : ReplyCategory -> Bits8
reply_categoryToTag Positive = 0
reply_categoryToTag Intermediate = 1
reply_categoryToTag TransientNegative = 2
reply_categoryToTag PermanentNegative = 3

||| Decode an ABI tag to a ReplyCategory.
public export
tagToReplyCategory : Bits8 -> Maybe ReplyCategory
tagToReplyCategory 0 = Just Positive
tagToReplyCategory 1 = Just Intermediate
tagToReplyCategory 2 = Just TransientNegative
tagToReplyCategory 3 = Just PermanentNegative
tagToReplyCategory _ = Nothing

||| Roundtrip proof: decoding an encoded ReplyCategory yields the original.
public export
reply_categoryRoundtrip : (x : ReplyCategory) -> tagToReplyCategory (reply_categoryToTag x) = Just x
reply_categoryRoundtrip Positive = Refl
reply_categoryRoundtrip Intermediate = Refl
reply_categoryRoundtrip TransientNegative = Refl
reply_categoryRoundtrip PermanentNegative = Refl

---------------------------------------------------------------------------
-- ReplyCode (17 constructors, tags 0-16)
---------------------------------------------------------------------------

public export
reply_codeSize : Nat
reply_codeSize = 1

||| ReplyCode sum type for ABI encoding.
public export
data ReplyCode : Type where
  ServiceReady : ReplyCode
  ServiceClosing : ReplyCode
  ActionOk : ReplyCode
  WillForward : ReplyCode
  StartMailInput : ReplyCode
  ServiceUnavailable : ReplyCode
  MailboxBusy : ReplyCode
  LocalError : ReplyCode
  InsufficientStorage : ReplyCode
  SyntaxError : ReplyCode
  ParamSyntaxError : ReplyCode
  NotImplemented : ReplyCode
  BadSequence : ReplyCode
  ParamNotImplemented : ReplyCode
  MailboxUnavailable : ReplyCode
  MailboxNameInvalid : ReplyCode
  TransactionFailed : ReplyCode

||| Encode a ReplyCode to its ABI tag value.
public export
reply_codeToTag : ReplyCode -> Bits8
reply_codeToTag ServiceReady = 0
reply_codeToTag ServiceClosing = 1
reply_codeToTag ActionOk = 2
reply_codeToTag WillForward = 3
reply_codeToTag StartMailInput = 4
reply_codeToTag ServiceUnavailable = 5
reply_codeToTag MailboxBusy = 6
reply_codeToTag LocalError = 7
reply_codeToTag InsufficientStorage = 8
reply_codeToTag SyntaxError = 9
reply_codeToTag ParamSyntaxError = 10
reply_codeToTag NotImplemented = 11
reply_codeToTag BadSequence = 12
reply_codeToTag ParamNotImplemented = 13
reply_codeToTag MailboxUnavailable = 14
reply_codeToTag MailboxNameInvalid = 15
reply_codeToTag TransactionFailed = 16

||| Decode an ABI tag to a ReplyCode.
public export
tagToReplyCode : Bits8 -> Maybe ReplyCode
tagToReplyCode 0 = Just ServiceReady
tagToReplyCode 1 = Just ServiceClosing
tagToReplyCode 2 = Just ActionOk
tagToReplyCode 3 = Just WillForward
tagToReplyCode 4 = Just StartMailInput
tagToReplyCode 5 = Just ServiceUnavailable
tagToReplyCode 6 = Just MailboxBusy
tagToReplyCode 7 = Just LocalError
tagToReplyCode 8 = Just InsufficientStorage
tagToReplyCode 9 = Just SyntaxError
tagToReplyCode 10 = Just ParamSyntaxError
tagToReplyCode 11 = Just NotImplemented
tagToReplyCode 12 = Just BadSequence
tagToReplyCode 13 = Just ParamNotImplemented
tagToReplyCode 14 = Just MailboxUnavailable
tagToReplyCode 15 = Just MailboxNameInvalid
tagToReplyCode 16 = Just TransactionFailed
tagToReplyCode _ = Nothing

||| Roundtrip proof: decoding an encoded ReplyCode yields the original.
public export
reply_codeRoundtrip : (x : ReplyCode) -> tagToReplyCode (reply_codeToTag x) = Just x
reply_codeRoundtrip ServiceReady = Refl
reply_codeRoundtrip ServiceClosing = Refl
reply_codeRoundtrip ActionOk = Refl
reply_codeRoundtrip WillForward = Refl
reply_codeRoundtrip StartMailInput = Refl
reply_codeRoundtrip ServiceUnavailable = Refl
reply_codeRoundtrip MailboxBusy = Refl
reply_codeRoundtrip LocalError = Refl
reply_codeRoundtrip InsufficientStorage = Refl
reply_codeRoundtrip SyntaxError = Refl
reply_codeRoundtrip ParamSyntaxError = Refl
reply_codeRoundtrip NotImplemented = Refl
reply_codeRoundtrip BadSequence = Refl
reply_codeRoundtrip ParamNotImplemented = Refl
reply_codeRoundtrip MailboxUnavailable = Refl
reply_codeRoundtrip MailboxNameInvalid = Refl
reply_codeRoundtrip TransactionFailed = Refl

---------------------------------------------------------------------------
-- AuthMechTag (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
auth_mech_tagSize : Nat
auth_mech_tagSize = 1

||| AuthMechTag sum type for ABI encoding.
public export
data AuthMechTag : Type where
  Plain : AuthMechTag
  Login : AuthMechTag
  CramMd5 : AuthMechTag
  Xoauth2 : AuthMechTag

||| Encode a AuthMechTag to its ABI tag value.
public export
auth_mech_tagToTag : AuthMechTag -> Bits8
auth_mech_tagToTag Plain = 0
auth_mech_tagToTag Login = 1
auth_mech_tagToTag CramMd5 = 2
auth_mech_tagToTag Xoauth2 = 3

||| Decode an ABI tag to a AuthMechTag.
public export
tagToAuthMechTag : Bits8 -> Maybe AuthMechTag
tagToAuthMechTag 0 = Just Plain
tagToAuthMechTag 1 = Just Login
tagToAuthMechTag 2 = Just CramMd5
tagToAuthMechTag 3 = Just Xoauth2
tagToAuthMechTag _ = Nothing

||| Roundtrip proof: decoding an encoded AuthMechTag yields the original.
public export
auth_mech_tagRoundtrip : (x : AuthMechTag) -> tagToAuthMechTag (auth_mech_tagToTag x) = Just x
auth_mech_tagRoundtrip Plain = Refl
auth_mech_tagRoundtrip Login = Refl
auth_mech_tagRoundtrip CramMd5 = Refl
auth_mech_tagRoundtrip Xoauth2 = Refl

---------------------------------------------------------------------------
-- SmtpExtension (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
smtp_extensionSize : Nat
smtp_extensionSize = 1

||| SmtpExtension sum type for ABI encoding.
public export
data SmtpExtension : Type where
  Size : SmtpExtension
  Pipelining : SmtpExtension
  EightBitMime : SmtpExtension
  Starttls : SmtpExtension
  Auth : SmtpExtension
  Dsn : SmtpExtension
  Chunking : SmtpExtension

||| Encode a SmtpExtension to its ABI tag value.
public export
smtp_extensionToTag : SmtpExtension -> Bits8
smtp_extensionToTag Size = 0
smtp_extensionToTag Pipelining = 1
smtp_extensionToTag EightBitMime = 2
smtp_extensionToTag Starttls = 3
smtp_extensionToTag Auth = 4
smtp_extensionToTag Dsn = 5
smtp_extensionToTag Chunking = 6

||| Decode an ABI tag to a SmtpExtension.
public export
tagToSmtpExtension : Bits8 -> Maybe SmtpExtension
tagToSmtpExtension 0 = Just Size
tagToSmtpExtension 1 = Just Pipelining
tagToSmtpExtension 2 = Just EightBitMime
tagToSmtpExtension 3 = Just Starttls
tagToSmtpExtension 4 = Just Auth
tagToSmtpExtension 5 = Just Dsn
tagToSmtpExtension 6 = Just Chunking
tagToSmtpExtension _ = Nothing

||| Roundtrip proof: decoding an encoded SmtpExtension yields the original.
public export
smtp_extensionRoundtrip : (x : SmtpExtension) -> tagToSmtpExtension (smtp_extensionToTag x) = Just x
smtp_extensionRoundtrip Size = Refl
smtp_extensionRoundtrip Pipelining = Refl
smtp_extensionRoundtrip EightBitMime = Refl
smtp_extensionRoundtrip Starttls = Refl
smtp_extensionRoundtrip Auth = Refl
smtp_extensionRoundtrip Dsn = Refl
smtp_extensionRoundtrip Chunking = Refl

---------------------------------------------------------------------------
-- SmtpSessionState (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
smtp_session_stateSize : Nat
smtp_session_stateSize = 1

||| SmtpSessionState sum type for ABI encoding.
public export
data SmtpSessionState : Type where
  Connected : SmtpSessionState
  Greeted : SmtpSessionState
  AuthStarted : SmtpSessionState
  Authenticated : SmtpSessionState
  MailFrom : SmtpSessionState
  RcptTo : SmtpSessionState
  Data : SmtpSessionState
  MessageReceived : SmtpSessionState
  Quit : SmtpSessionState

||| Encode a SmtpSessionState to its ABI tag value.
public export
smtp_session_stateToTag : SmtpSessionState -> Bits8
smtp_session_stateToTag Connected = 0
smtp_session_stateToTag Greeted = 1
smtp_session_stateToTag AuthStarted = 2
smtp_session_stateToTag Authenticated = 3
smtp_session_stateToTag MailFrom = 4
smtp_session_stateToTag RcptTo = 5
smtp_session_stateToTag Data = 6
smtp_session_stateToTag MessageReceived = 7
smtp_session_stateToTag Quit = 8

||| Decode an ABI tag to a SmtpSessionState.
public export
tagToSmtpSessionState : Bits8 -> Maybe SmtpSessionState
tagToSmtpSessionState 0 = Just Connected
tagToSmtpSessionState 1 = Just Greeted
tagToSmtpSessionState 2 = Just AuthStarted
tagToSmtpSessionState 3 = Just Authenticated
tagToSmtpSessionState 4 = Just MailFrom
tagToSmtpSessionState 5 = Just RcptTo
tagToSmtpSessionState 6 = Just Data
tagToSmtpSessionState 7 = Just MessageReceived
tagToSmtpSessionState 8 = Just Quit
tagToSmtpSessionState _ = Nothing

||| Roundtrip proof: decoding an encoded SmtpSessionState yields the original.
public export
smtp_session_stateRoundtrip : (x : SmtpSessionState) -> tagToSmtpSessionState (smtp_session_stateToTag x) = Just x
smtp_session_stateRoundtrip Connected = Refl
smtp_session_stateRoundtrip Greeted = Refl
smtp_session_stateRoundtrip AuthStarted = Refl
smtp_session_stateRoundtrip Authenticated = Refl
smtp_session_stateRoundtrip MailFrom = Refl
smtp_session_stateRoundtrip RcptTo = Refl
smtp_session_stateRoundtrip Data = Refl
smtp_session_stateRoundtrip MessageReceived = Refl
smtp_session_stateRoundtrip Quit = Refl
