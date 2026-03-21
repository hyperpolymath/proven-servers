-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SMTP protocol types for proven-servers.
--
-- SMTP protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.SmtpTypes
  ( -- * ADT types matching Idris2 ABI
      SmtpCommand(..)
    , ReplyCategory(..)
    , ReplyCode(..)
    , AuthMechanism(..)
    , SmtpExtension(..)
    , SmtpSessionState(..)
    , smtpCommandToTag
    , smtpCommandFromTag
    , replyCategoryToTag
    , replyCategoryFromTag
    , replyCodeToTag
    , replyCodeFromTag
    , authMechanismToTag
    , authMechanismFromTag
    , smtpExtensionToTag
    , smtpExtensionFromTag
    , smtpSessionStateToTag
    , smtpSessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- SmtpCommand
-- ---------------------------------------------------------------------------

-- | SmtpCommand type matching the Idris2 ABI.
--
-- Tags 0-11 (12 constructors).
data SmtpCommand
  = Helo  -- ^ Tag 0.
  | Ehlo  -- ^ Tag 1.
  | SmtpCommand_MailFrom  -- ^ Tag 2.
  | SmtpCommand_RcptTo  -- ^ Tag 3.
  | SmtpCommand_Data  -- ^ Tag 4.
  | SmtpCommand_Quit  -- ^ Tag 5.
  | Rset  -- ^ Tag 6.
  | Noop  -- ^ Tag 7.
  | Vrfy  -- ^ Tag 8.
  | Expn  -- ^ Tag 9.
  | SmtpCommand_Starttls  -- ^ Tag 10.
  | SmtpCommand_Auth  -- ^ Tag 11.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SmtpCommand' to its ABI tag value.
smtpCommandToTag :: SmtpCommand -> Word8
smtpCommandToTag = fromIntegral . fromEnum

-- | Decode a 'SmtpCommand' from its ABI tag value.
smtpCommandFromTag :: Word8 -> Maybe SmtpCommand
smtpCommandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SmtpCommand)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ReplyCategory
-- ---------------------------------------------------------------------------

-- | ReplyCategory type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ReplyCategory
  = Positive  -- ^ Tag 0.
  | Intermediate  -- ^ Tag 1.
  | TransientNegative  -- ^ Tag 2.
  | PermanentNegative  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ReplyCategory' to its ABI tag value.
replyCategoryToTag :: ReplyCategory -> Word8
replyCategoryToTag = fromIntegral . fromEnum

-- | Decode a 'ReplyCategory' from its ABI tag value.
replyCategoryFromTag :: Word8 -> Maybe ReplyCategory
replyCategoryFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ReplyCategory)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ReplyCode
-- ---------------------------------------------------------------------------

-- | ReplyCode type matching the Idris2 ABI.
--
-- Tags 0-16 (17 constructors).
data ReplyCode
  = ServiceReady  -- ^ Tag 0.
  | ServiceClosing  -- ^ Tag 1.
  | ActionOk  -- ^ Tag 2.
  | WillForward  -- ^ Tag 3.
  | StartMailInput  -- ^ Tag 4.
  | ServiceUnavailable  -- ^ Tag 5.
  | MailboxBusy  -- ^ Tag 6.
  | LocalError  -- ^ Tag 7.
  | InsufficientStorage  -- ^ Tag 8.
  | SyntaxError  -- ^ Tag 9.
  | ParamSyntaxError  -- ^ Tag 10.
  | NotImplemented  -- ^ Tag 11.
  | BadSequence  -- ^ Tag 12.
  | ParamNotImplemented  -- ^ Tag 13.
  | MailboxUnavailable  -- ^ Tag 14.
  | MailboxNameInvalid  -- ^ Tag 15.
  | TransactionFailed  -- ^ Tag 16.
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

-- | AuthMechanism type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data AuthMechanism
  = Plain  -- ^ Tag 0.
  | Login  -- ^ Tag 1.
  | CramMd5  -- ^ Tag 2.
  | Xoauth2  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthMechanism' to its ABI tag value.
authMechanismToTag :: AuthMechanism -> Word8
authMechanismToTag = fromIntegral . fromEnum

-- | Decode a 'AuthMechanism' from its ABI tag value.
authMechanismFromTag :: Word8 -> Maybe AuthMechanism
authMechanismFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthMechanism)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SmtpExtension
-- ---------------------------------------------------------------------------

-- | SmtpExtension type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data SmtpExtension
  = Size  -- ^ Tag 0.
  | Pipelining  -- ^ Tag 1.
  | EightBitMime  -- ^ Tag 2.
  | SmtpExtension_Starttls  -- ^ Tag 3.
  | SmtpExtension_Auth  -- ^ Tag 4.
  | Dsn  -- ^ Tag 5.
  | Chunking  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SmtpExtension' to its ABI tag value.
smtpExtensionToTag :: SmtpExtension -> Word8
smtpExtensionToTag = fromIntegral . fromEnum

-- | Decode a 'SmtpExtension' from its ABI tag value.
smtpExtensionFromTag :: Word8 -> Maybe SmtpExtension
smtpExtensionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SmtpExtension)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SmtpSessionState
-- ---------------------------------------------------------------------------

-- | SmtpSessionState type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data SmtpSessionState
  = Connected  -- ^ Tag 0.
  | Greeted  -- ^ Tag 1.
  | AuthStarted  -- ^ Tag 2.
  | Authenticated  -- ^ Tag 3.
  | SmtpSessionState_MailFrom  -- ^ Tag 4.
  | SmtpSessionState_RcptTo  -- ^ Tag 5.
  | SmtpSessionState_Data  -- ^ Tag 6.
  | MessageReceived  -- ^ Tag 7.
  | SmtpSessionState_Quit  -- ^ Tag 8.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SmtpSessionState' to its ABI tag value.
smtpSessionStateToTag :: SmtpSessionState -> Word8
smtpSessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SmtpSessionState' from its ABI tag value.
smtpSessionStateFromTag :: Word8 -> Maybe SmtpSessionState
smtpSessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SmtpSessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
