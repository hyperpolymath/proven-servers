// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenSmtp protocol bindings.

open ProvenSmtp

let test_smtpCommand_roundtrip = () => {
  assert(smtpCommandFromTag(0) == Some(Helo))
  assert(smtpCommandFromTag(1) == Some(Ehlo))
  assert(smtpCommandFromTag(2) == Some(MailFrom))
  assert(smtpCommandFromTag(3) == Some(RcptTo))
  assert(smtpCommandFromTag(4) == Some(Data))
  assert(smtpCommandFromTag(5) == Some(Quit))
  assert(smtpCommandFromTag(6) == Some(Rset))
  assert(smtpCommandFromTag(7) == Some(Noop))
  assert(smtpCommandFromTag(8) == Some(Vrfy))
  assert(smtpCommandFromTag(9) == Some(Expn))
  assert(smtpCommandFromTag(10) == Some(Starttls))
  assert(smtpCommandFromTag(11) == Some(Auth))
  assert(smtpCommandFromTag(12) == None)
}

let test_smtpCommand_toTag = () => {
  assert(smtpCommandToTag(Helo) == 0)
  assert(smtpCommandToTag(Ehlo) == 1)
  assert(smtpCommandToTag(MailFrom) == 2)
  assert(smtpCommandToTag(RcptTo) == 3)
  assert(smtpCommandToTag(Data) == 4)
  assert(smtpCommandToTag(Quit) == 5)
  assert(smtpCommandToTag(Rset) == 6)
  assert(smtpCommandToTag(Noop) == 7)
  assert(smtpCommandToTag(Vrfy) == 8)
  assert(smtpCommandToTag(Expn) == 9)
  assert(smtpCommandToTag(Starttls) == 10)
  assert(smtpCommandToTag(Auth) == 11)
}

let test_replyCategory_roundtrip = () => {
  assert(replyCategoryFromTag(0) == Some(Positive))
  assert(replyCategoryFromTag(1) == Some(Intermediate))
  assert(replyCategoryFromTag(2) == Some(TransientNegative))
  assert(replyCategoryFromTag(3) == Some(PermanentNegative))
  assert(replyCategoryFromTag(4) == None)
}

let test_replyCategory_toTag = () => {
  assert(replyCategoryToTag(Positive) == 0)
  assert(replyCategoryToTag(Intermediate) == 1)
  assert(replyCategoryToTag(TransientNegative) == 2)
  assert(replyCategoryToTag(PermanentNegative) == 3)
}

let test_replyCode_roundtrip = () => {
  assert(replyCodeFromTag(0) == Some(ServiceReady))
  assert(replyCodeFromTag(1) == Some(ServiceClosing))
  assert(replyCodeFromTag(2) == Some(ActionOk))
  assert(replyCodeFromTag(3) == Some(WillForward))
  assert(replyCodeFromTag(4) == Some(StartMailInput))
  assert(replyCodeFromTag(5) == Some(ServiceUnavailable))
  assert(replyCodeFromTag(6) == Some(MailboxBusy))
  assert(replyCodeFromTag(7) == Some(LocalError))
  assert(replyCodeFromTag(8) == Some(InsufficientStorage))
  assert(replyCodeFromTag(9) == Some(SyntaxError))
  assert(replyCodeFromTag(10) == Some(ParamSyntaxError))
  assert(replyCodeFromTag(11) == Some(NotImplemented))
  assert(replyCodeFromTag(12) == Some(BadSequence))
  assert(replyCodeFromTag(13) == Some(ParamNotImplemented))
  assert(replyCodeFromTag(14) == Some(MailboxUnavailable))
  assert(replyCodeFromTag(15) == Some(MailboxNameInvalid))
  assert(replyCodeFromTag(16) == Some(TransactionFailed))
  assert(replyCodeFromTag(17) == None)
}

let test_replyCode_toTag = () => {
  assert(replyCodeToTag(ServiceReady) == 0)
  assert(replyCodeToTag(ServiceClosing) == 1)
  assert(replyCodeToTag(ActionOk) == 2)
  assert(replyCodeToTag(WillForward) == 3)
  assert(replyCodeToTag(StartMailInput) == 4)
  assert(replyCodeToTag(ServiceUnavailable) == 5)
  assert(replyCodeToTag(MailboxBusy) == 6)
  assert(replyCodeToTag(LocalError) == 7)
  assert(replyCodeToTag(InsufficientStorage) == 8)
  assert(replyCodeToTag(SyntaxError) == 9)
  assert(replyCodeToTag(ParamSyntaxError) == 10)
  assert(replyCodeToTag(NotImplemented) == 11)
  assert(replyCodeToTag(BadSequence) == 12)
  assert(replyCodeToTag(ParamNotImplemented) == 13)
  assert(replyCodeToTag(MailboxUnavailable) == 14)
  assert(replyCodeToTag(MailboxNameInvalid) == 15)
  assert(replyCodeToTag(TransactionFailed) == 16)
}

let test_authMechanism_roundtrip = () => {
  assert(authMechanismFromTag(0) == Some(Plain))
  assert(authMechanismFromTag(1) == Some(Login))
  assert(authMechanismFromTag(2) == Some(CramMd5))
  assert(authMechanismFromTag(3) == Some(Xoauth2))
  assert(authMechanismFromTag(4) == None)
}

let test_authMechanism_toTag = () => {
  assert(authMechanismToTag(Plain) == 0)
  assert(authMechanismToTag(Login) == 1)
  assert(authMechanismToTag(CramMd5) == 2)
  assert(authMechanismToTag(Xoauth2) == 3)
}

let test_smtpExtension_roundtrip = () => {
  assert(smtpExtensionFromTag(0) == Some(Size))
  assert(smtpExtensionFromTag(1) == Some(Pipelining))
  assert(smtpExtensionFromTag(2) == Some(EightBitMime))
  assert(smtpExtensionFromTag(3) == Some(Starttls))
  assert(smtpExtensionFromTag(4) == Some(Auth))
  assert(smtpExtensionFromTag(5) == Some(Dsn))
  assert(smtpExtensionFromTag(6) == Some(Chunking))
  assert(smtpExtensionFromTag(7) == None)
}

let test_smtpExtension_toTag = () => {
  assert(smtpExtensionToTag(Size) == 0)
  assert(smtpExtensionToTag(Pipelining) == 1)
  assert(smtpExtensionToTag(EightBitMime) == 2)
  assert(smtpExtensionToTag(Starttls) == 3)
  assert(smtpExtensionToTag(Auth) == 4)
  assert(smtpExtensionToTag(Dsn) == 5)
  assert(smtpExtensionToTag(Chunking) == 6)
}

let test_smtpSessionState_roundtrip = () => {
  assert(smtpSessionStateFromTag(0) == Some(Connected))
  assert(smtpSessionStateFromTag(1) == Some(Greeted))
  assert(smtpSessionStateFromTag(2) == Some(AuthStarted))
  assert(smtpSessionStateFromTag(3) == Some(Authenticated))
  assert(smtpSessionStateFromTag(4) == Some(MailFrom))
  assert(smtpSessionStateFromTag(5) == Some(RcptTo))
  assert(smtpSessionStateFromTag(6) == Some(Data))
  assert(smtpSessionStateFromTag(7) == Some(MessageReceived))
  assert(smtpSessionStateFromTag(8) == Some(Quit))
  assert(smtpSessionStateFromTag(9) == None)
}

let test_smtpSessionState_toTag = () => {
  assert(smtpSessionStateToTag(Connected) == 0)
  assert(smtpSessionStateToTag(Greeted) == 1)
  assert(smtpSessionStateToTag(AuthStarted) == 2)
  assert(smtpSessionStateToTag(Authenticated) == 3)
  assert(smtpSessionStateToTag(MailFrom) == 4)
  assert(smtpSessionStateToTag(RcptTo) == 5)
  assert(smtpSessionStateToTag(Data) == 6)
  assert(smtpSessionStateToTag(MessageReceived) == 7)
  assert(smtpSessionStateToTag(Quit) == 8)
}

// Run all tests
test_smtpCommand_roundtrip()
test_smtpCommand_toTag()
test_replyCategory_roundtrip()
test_replyCategory_toTag()
test_replyCode_roundtrip()
test_replyCode_toTag()
test_authMechanism_roundtrip()
test_authMechanism_toTag()
test_smtpExtension_roundtrip()
test_smtpExtension_toTag()
test_smtpSessionState_roundtrip()
test_smtpSessionState_toTag()
