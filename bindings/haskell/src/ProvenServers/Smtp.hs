-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SMTP protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Smtp
  (
    smtpPort
  , submissionPort
  , smtpsPort
  , SmtpCommand(..)
  , smtpCommandToTag
  , smtpCommandFromTag
  , isEnvelope
  , verb
  , ReplyCategory(..)
  , replyCategoryToTag
  , replyCategoryFromTag
  , isSuccess
  , isError
  , ReplyCode(..)
  , replyCodeToTag
  , replyCodeFromTag
  , AuthMechanism(..)
  , authMechanismToTag
  , authMechanismFromTag
  , requiresTls
  , mechanismName
  , SmtpExtension(..)
  , smtpExtensionToTag
  , smtpExtensionFromTag
  , keyword
  , SmtpSessionState(..)
  , smtpSessionStateToTag
  , smtpSessionStateFromTag
  , smtpSessionStateCanTransitionTo
  ) where

import Data.Word (Word16, Word8)

-- | Standard SMTP submission port.
smtpPort :: Word16
smtpPort = 25

-- | SMTP submission port (RFC 6409).
submissionPort :: Word16
submissionPort = 587

-- | SMTPS (implicit TLS) port.
smtpsPort :: Word16
smtpsPort = 465

-- ---------------------------------------------------------------------------
-- SmtpCommand
-- ---------------------------------------------------------------------------

-- | SMTP submission port (RFC 6409).
--
-- Tags 0-11 (12 constructors).
data SmtpCommand
  = Helo  -- ^ HELO — identify client (RFC 821) (tag 0).
  | Ehlo  -- ^ EHLO — extended HELO (RFC 1869) (tag 1).
  | MailFrom  -- ^ MAIL FROM — specify sender (tag 2).
  | RcptTo  -- ^ RCPT TO — specify recipient (tag 3).
  | Data  -- ^ DATA — begin message body (tag 4).
  | Quit  -- ^ QUIT — close session (tag 5).
  | Rset  -- ^ RSET — reset transaction (tag 6).
  | Noop  -- ^ NOOP — no operation (tag 7).
  | Vrfy  -- ^ VRFY — verify address (tag 8).
  | Expn  -- ^ EXPN — expand mailing list (tag 9).
  | Starttls  -- ^ STARTTLS — upgrade to TLS (RFC 3207) (tag 10).
  | Auth  -- ^ AUTH — SASL authentication (RFC 4954) (tag 11).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SmtpCommand' to its ABI tag value.
smtpCommandToTag :: SmtpCommand -> Word8
smtpCommandToTag = fromIntegral . fromEnum

-- | Decode a 'SmtpCommand' from its ABI tag value.
smtpCommandFromTag :: Word8 -> Maybe SmtpCommand
smtpCommandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SmtpCommand)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this command is part of the mail transaction envelope.
isEnvelope :: SmtpCommand -> Bool
isEnvelope MailFrom = True
isEnvelope RcptTo = True
isEnvelope Data = True
isEnvelope _ = False

-- | The SMTP command verb as a string.
verb :: SmtpCommand -> String
verb Helo = "HELO"
verb Ehlo = "EHLO"
verb MailFrom = "MAIL FROM"
verb RcptTo = "RCPT TO"
verb Data = "DATA"
verb Quit = "QUIT"
verb Rset = "RSET"
verb Noop = "NOOP"
verb Vrfy = "VRFY"
verb Expn = "EXPN"
verb Starttls = "STARTTLS"
verb Auth = "AUTH"

-- ---------------------------------------------------------------------------
-- ReplyCategory
-- ---------------------------------------------------------------------------

-- | SMTP reply severity categories (RFC 5321 Section 4.2).
--
-- Tags 0-3 (4 constructors).
data ReplyCategory
  = Positive  -- ^ Positive completion (2xx) (tag 0).
  | Intermediate  -- ^ Positive intermediate (3xx) (tag 1).
  | TransientNegative  -- ^ Transient negative (4xx) — retry may succeed (tag 2).
  | PermanentNegative  -- ^ Permanent negative (5xx) — do not retry (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ReplyCategory' to its ABI tag value.
replyCategoryToTag :: ReplyCategory -> Word8
replyCategoryToTag = fromIntegral . fromEnum

-- | Decode a 'ReplyCategory' from its ABI tag value.
replyCategoryFromTag :: Word8 -> Maybe ReplyCategory
replyCategoryFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ReplyCategory)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this category indicates success.
isSuccess :: ReplyCategory -> Bool
isSuccess Positive = True
isSuccess _ = False

-- | Whether this category indicates an error.
isError :: ReplyCategory -> Bool
isError TransientNegative = True
isError PermanentNegative = True
isError _ = False

-- ---------------------------------------------------------------------------
-- ReplyCode
-- ---------------------------------------------------------------------------

-- | SMTP reply codes (RFC 5321).
--
-- Tags 0-16 (17 constructors).
data ReplyCode
  = ServiceReady  -- ^ 220 — Service ready (tag 0).
  | ServiceClosing  -- ^ 221 — Service closing transmission channel (tag 1).
  | ActionOk  -- ^ 250 — Requested action OK, completed (tag 2).
  | WillForward  -- ^ 251 — User not local, will forward (tag 3).
  | StartMailInput  -- ^ 354 — Start mail input (tag 4).
  | ServiceUnavailable  -- ^ 421 — Service unavailable (tag 5).
  | MailboxBusy  -- ^ 450 — Mailbox busy (tag 6).
  | LocalError  -- ^ 451 — Local error in processing (tag 7).
  | InsufficientStorage  -- ^ 452 — Insufficient storage (tag 8).
  | SyntaxError  -- ^ 500 — Syntax error, command unrecognised (tag 9).
  | ParamSyntaxError  -- ^ 501 — Syntax error in parameters (tag 10).
  | NotImplemented  -- ^ 502 — Command not implemented (tag 11).
  | BadSequence  -- ^ 503 — Bad sequence of commands (tag 12).
  | ParamNotImplemented  -- ^ 504 — Parameter not implemented (tag 13).
  | MailboxUnavailable  -- ^ 550 — Mailbox unavailable (tag 14).
  | MailboxNameInvalid  -- ^ 553 — Mailbox name not allowed (tag 15).
  | TransactionFailed  -- ^ 554 — Transaction failed (tag 16).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ReplyCode' to its ABI tag value.
replyCodeToTag :: ReplyCode -> Word8
replyCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ReplyCode' from its ABI tag value.
replyCodeFromTag :: Word8 -> Maybe ReplyCode
replyCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ReplyCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AuthMechanism
-- ---------------------------------------------------------------------------

-- | SMTP SASL authentication mechanisms (RFC 4954).
--
-- Tags 0-3 (4 constructors).
data AuthMechanism
  = Plain  -- ^ PLAIN (RFC 4616) (tag 0).
  | Login  -- ^ LOGIN (non-standard but widely used) (tag 1).
  | CramMd5  -- ^ CRAM-MD5 (RFC 2195) (tag 2).
  | Xoauth2  -- ^ XOAUTH2 (Google extension) (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthMechanism' to its ABI tag value.
authMechanismToTag :: AuthMechanism -> Word8
authMechanismToTag = fromIntegral . fromEnum

-- | Decode a 'AuthMechanism' from its ABI tag value.
authMechanismFromTag :: Word8 -> Maybe AuthMechanism
authMechanismFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthMechanism)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | (requires TLS for security).
requiresTls :: AuthMechanism -> Bool
requiresTls Plain = True
requiresTls Login = True
requiresTls _ = False

-- | The SASL mechanism name string.
mechanismName :: AuthMechanism -> String
mechanismName Plain = "PLAIN"
mechanismName Login = "LOGIN"
mechanismName CramMd5 = "CRAM-MD5"
mechanismName Xoauth2 = "XOAUTH2"

-- ---------------------------------------------------------------------------
-- SmtpExtension
-- ---------------------------------------------------------------------------

-- | ESMTP extensions advertised via EHLO response.
--
-- Tags 0-6 (7 constructors).
data SmtpExtension
  = Size  -- ^ SIZE — message size declaration (RFC 1870) (tag 0).
  | Pipelining  -- ^ PIPELINING — command pipelining (RFC 2920) (tag 1).
  | EightBitMime  -- ^ 8BITMIME — 8-bit MIME support (RFC 6152) (tag 2).
  | Starttls  -- ^ STARTTLS — TLS upgrade (RFC 3207) (tag 3).
  | Auth  -- ^ AUTH — SASL authentication (RFC 4954) (tag 4).
  | Dsn  -- ^ DSN — delivery status notifications (RFC 3461) (tag 5).
  | Chunking  -- ^ CHUNKING — binary data chunking (RFC 3030) (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SmtpExtension' to its ABI tag value.
smtpExtensionToTag :: SmtpExtension -> Word8
smtpExtensionToTag = fromIntegral . fromEnum

-- | Decode a 'SmtpExtension' from its ABI tag value.
smtpExtensionFromTag :: Word8 -> Maybe SmtpExtension
smtpExtensionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SmtpExtension)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | The ESMTP keyword for this extension.
keyword :: SmtpExtension -> String
keyword Size = "SIZE"
keyword Pipelining = "PIPELINING"
keyword EightBitMime = "8BITMIME"
keyword Starttls = "STARTTLS"
keyword Auth = "AUTH"
keyword Dsn = "DSN"
keyword Chunking = "CHUNKING"

-- ---------------------------------------------------------------------------
-- SmtpSessionState
-- ---------------------------------------------------------------------------

-- | SMTP session state machine (RFC 5321).
--
-- Tags 0-8 (9 constructors).
data SmtpSessionState
  = Connected  -- ^ TCP connection established, awaiting greeting (tag 0).
  | Greeted  -- ^ EHLO/HELO completed, session identified (tag 1).
  | AuthStarted  -- ^ AUTH command sent, awaiting challenge/response (tag 2).
  | Authenticated  -- ^ Authentication completed successfully (tag 3).
  | MailFrom  -- ^ MAIL FROM accepted, sender specified (tag 4).
  | RcptTo  -- ^ At least one RCPT TO accepted (tag 5).
  | Data  -- ^ DATA command accepted, receiving message body (tag 6).
  | MessageReceived  -- ^ Message body received and accepted (tag 7).
  | Quit  -- ^ QUIT sent, session ending (tag 8).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SmtpSessionState' to its ABI tag value.
smtpSessionStateToTag :: SmtpSessionState -> Word8
smtpSessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SmtpSessionState' from its ABI tag value.
smtpSessionStateFromTag :: Word8 -> Maybe SmtpSessionState
smtpSessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SmtpSessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Validate whether a state transition is allowed in the SMTP state machine.
smtpSessionStateCanTransitionTo :: SmtpSessionState -> SmtpSessionState -> Bool
smtpSessionStateCanTransitionTo Connected Greeted = True
smtpSessionStateCanTransitionTo Greeted AuthStarted = True
smtpSessionStateCanTransitionTo Greeted MailFrom = True
smtpSessionStateCanTransitionTo AuthStarted Authenticated = True
smtpSessionStateCanTransitionTo AuthStarted Greeted = True
smtpSessionStateCanTransitionTo Authenticated MailFrom = True
smtpSessionStateCanTransitionTo MailFrom RcptTo = True
smtpSessionStateCanTransitionTo RcptTo RcptTo = True
smtpSessionStateCanTransitionTo RcptTo Data = True
smtpSessionStateCanTransitionTo Data MessageReceived = True
smtpSessionStateCanTransitionTo MessageReceived MailFrom = True
smtpSessionStateCanTransitionTo _ Quit = True
smtpSessionStateCanTransitionTo _ _ = False
