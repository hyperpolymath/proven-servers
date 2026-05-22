-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FtpABI.Types: C-ABI-compatible numeric representations of Ftp types.
--
-- Maps every constructor of the core Ftp sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/ftp.zig) exactly.
--
-- Types covered:
--   SessionState              (5 constructors, tags 0-4)
--   TransferType              (2 constructors, tags 0-1)
--   DataModeTag               (2 constructors, tags 0-1)
--   TransferStateTag          (4 constructors, tags 0-3)
--   ReplyCategory             (5 constructors, tags 0-4)
--   CommandTag                (23 constructors, tags 0-22)

module FtpABI.Types

%default total

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
session_stateSize : Nat
session_stateSize = 1

||| SessionState sum type for ABI encoding.
public export
data SessionState : Type where
  Connected : SessionState
  UserOk : SessionState
  Authenticated : SessionState
  Renaming : SessionState
  Quit : SessionState

||| Encode a SessionState to its ABI tag value.
public export
session_stateToTag : SessionState -> Bits8
session_stateToTag Connected = 0
session_stateToTag UserOk = 1
session_stateToTag Authenticated = 2
session_stateToTag Renaming = 3
session_stateToTag Quit = 4

||| Decode an ABI tag to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Connected
tagToSessionState 1 = Just UserOk
tagToSessionState 2 = Just Authenticated
tagToSessionState 3 = Just Renaming
tagToSessionState 4 = Just Quit
tagToSessionState _ = Nothing

||| Roundtrip proof: decoding an encoded SessionState yields the original.
public export
session_stateRoundtrip : (x : SessionState) -> tagToSessionState (session_stateToTag x) = Just x
session_stateRoundtrip Connected = Refl
session_stateRoundtrip UserOk = Refl
session_stateRoundtrip Authenticated = Refl
session_stateRoundtrip Renaming = Refl
session_stateRoundtrip Quit = Refl

---------------------------------------------------------------------------
-- TransferType (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
transfer_typeSize : Nat
transfer_typeSize = 1

||| TransferType sum type for ABI encoding.
public export
data TransferType : Type where
  Ascii : TransferType
  Binary : TransferType

||| Encode a TransferType to its ABI tag value.
public export
transfer_typeToTag : TransferType -> Bits8
transfer_typeToTag Ascii = 0
transfer_typeToTag Binary = 1

||| Decode an ABI tag to a TransferType.
public export
tagToTransferType : Bits8 -> Maybe TransferType
tagToTransferType 0 = Just Ascii
tagToTransferType 1 = Just Binary
tagToTransferType _ = Nothing

||| Roundtrip proof: decoding an encoded TransferType yields the original.
public export
transfer_typeRoundtrip : (x : TransferType) -> tagToTransferType (transfer_typeToTag x) = Just x
transfer_typeRoundtrip Ascii = Refl
transfer_typeRoundtrip Binary = Refl

---------------------------------------------------------------------------
-- DataModeTag (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
data_mode_tagSize : Nat
data_mode_tagSize = 1

||| DataModeTag sum type for ABI encoding.
public export
data DataModeTag : Type where
  Active : DataModeTag
  Passive : DataModeTag

||| Encode a DataModeTag to its ABI tag value.
public export
data_mode_tagToTag : DataModeTag -> Bits8
data_mode_tagToTag Active = 0
data_mode_tagToTag Passive = 1

||| Decode an ABI tag to a DataModeTag.
public export
tagToDataModeTag : Bits8 -> Maybe DataModeTag
tagToDataModeTag 0 = Just Active
tagToDataModeTag 1 = Just Passive
tagToDataModeTag _ = Nothing

||| Roundtrip proof: decoding an encoded DataModeTag yields the original.
public export
data_mode_tagRoundtrip : (x : DataModeTag) -> tagToDataModeTag (data_mode_tagToTag x) = Just x
data_mode_tagRoundtrip Active = Refl
data_mode_tagRoundtrip Passive = Refl

---------------------------------------------------------------------------
-- TransferStateTag (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
transfer_state_tagSize : Nat
transfer_state_tagSize = 1

||| TransferStateTag sum type for ABI encoding.
public export
data TransferStateTag : Type where
  Idle : TransferStateTag
  InProgress : TransferStateTag
  Completed : TransferStateTag
  Aborted : TransferStateTag

||| Encode a TransferStateTag to its ABI tag value.
public export
transfer_state_tagToTag : TransferStateTag -> Bits8
transfer_state_tagToTag Idle = 0
transfer_state_tagToTag InProgress = 1
transfer_state_tagToTag Completed = 2
transfer_state_tagToTag Aborted = 3

||| Decode an ABI tag to a TransferStateTag.
public export
tagToTransferStateTag : Bits8 -> Maybe TransferStateTag
tagToTransferStateTag 0 = Just Idle
tagToTransferStateTag 1 = Just InProgress
tagToTransferStateTag 2 = Just Completed
tagToTransferStateTag 3 = Just Aborted
tagToTransferStateTag _ = Nothing

||| Roundtrip proof: decoding an encoded TransferStateTag yields the original.
public export
transfer_state_tagRoundtrip : (x : TransferStateTag) -> tagToTransferStateTag (transfer_state_tagToTag x) = Just x
transfer_state_tagRoundtrip Idle = Refl
transfer_state_tagRoundtrip InProgress = Refl
transfer_state_tagRoundtrip Completed = Refl
transfer_state_tagRoundtrip Aborted = Refl

---------------------------------------------------------------------------
-- ReplyCategory (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
reply_categorySize : Nat
reply_categorySize = 1

||| ReplyCategory sum type for ABI encoding.
public export
data ReplyCategory : Type where
  Preliminary : ReplyCategory
  Completion : ReplyCategory
  Intermediate : ReplyCategory
  TransientNeg : ReplyCategory
  PermanentNeg : ReplyCategory

||| Encode a ReplyCategory to its ABI tag value.
public export
reply_categoryToTag : ReplyCategory -> Bits8
reply_categoryToTag Preliminary = 0
reply_categoryToTag Completion = 1
reply_categoryToTag Intermediate = 2
reply_categoryToTag TransientNeg = 3
reply_categoryToTag PermanentNeg = 4

||| Decode an ABI tag to a ReplyCategory.
public export
tagToReplyCategory : Bits8 -> Maybe ReplyCategory
tagToReplyCategory 0 = Just Preliminary
tagToReplyCategory 1 = Just Completion
tagToReplyCategory 2 = Just Intermediate
tagToReplyCategory 3 = Just TransientNeg
tagToReplyCategory 4 = Just PermanentNeg
tagToReplyCategory _ = Nothing

||| Roundtrip proof: decoding an encoded ReplyCategory yields the original.
public export
reply_categoryRoundtrip : (x : ReplyCategory) -> tagToReplyCategory (reply_categoryToTag x) = Just x
reply_categoryRoundtrip Preliminary = Refl
reply_categoryRoundtrip Completion = Refl
reply_categoryRoundtrip Intermediate = Refl
reply_categoryRoundtrip TransientNeg = Refl
reply_categoryRoundtrip PermanentNeg = Refl

---------------------------------------------------------------------------
-- CommandTag (23 constructors, tags 0-22)
---------------------------------------------------------------------------

public export
command_tagSize : Nat
command_tagSize = 1

||| CommandTag sum type for ABI encoding.
public export
data CommandTag : Type where
  User : CommandTag
  Pass : CommandTag
  Acct : CommandTag
  Cwd : CommandTag
  Cdup : CommandTag
  Quit : CommandTag
  Pasv : CommandTag
  Port : CommandTag
  TypeCmd : CommandTag
  Retr : CommandTag
  Stor : CommandTag
  Dele : CommandTag
  Rmd : CommandTag
  Mkd : CommandTag
  Pwd : CommandTag
  List : CommandTag
  Nlst : CommandTag
  Syst : CommandTag
  Stat : CommandTag
  Noop : CommandTag
  Rnfr : CommandTag
  Rnto : CommandTag
  Size : CommandTag

||| Encode a CommandTag to its ABI tag value.
public export
command_tagToTag : CommandTag -> Bits8
command_tagToTag User = 0
command_tagToTag Pass = 1
command_tagToTag Acct = 2
command_tagToTag Cwd = 3
command_tagToTag Cdup = 4
command_tagToTag Quit = 5
command_tagToTag Pasv = 6
command_tagToTag Port = 7
command_tagToTag TypeCmd = 8
command_tagToTag Retr = 9
command_tagToTag Stor = 10
command_tagToTag Dele = 11
command_tagToTag Rmd = 12
command_tagToTag Mkd = 13
command_tagToTag Pwd = 14
command_tagToTag List = 15
command_tagToTag Nlst = 16
command_tagToTag Syst = 17
command_tagToTag Stat = 18
command_tagToTag Noop = 19
command_tagToTag Rnfr = 20
command_tagToTag Rnto = 21
command_tagToTag Size = 22

||| Decode an ABI tag to a CommandTag.
public export
tagToCommandTag : Bits8 -> Maybe CommandTag
tagToCommandTag 0 = Just User
tagToCommandTag 1 = Just Pass
tagToCommandTag 2 = Just Acct
tagToCommandTag 3 = Just Cwd
tagToCommandTag 4 = Just Cdup
tagToCommandTag 5 = Just Quit
tagToCommandTag 6 = Just Pasv
tagToCommandTag 7 = Just Port
tagToCommandTag 8 = Just TypeCmd
tagToCommandTag 9 = Just Retr
tagToCommandTag 10 = Just Stor
tagToCommandTag 11 = Just Dele
tagToCommandTag 12 = Just Rmd
tagToCommandTag 13 = Just Mkd
tagToCommandTag 14 = Just Pwd
tagToCommandTag 15 = Just List
tagToCommandTag 16 = Just Nlst
tagToCommandTag 17 = Just Syst
tagToCommandTag 18 = Just Stat
tagToCommandTag 19 = Just Noop
tagToCommandTag 20 = Just Rnfr
tagToCommandTag 21 = Just Rnto
tagToCommandTag 22 = Just Size
tagToCommandTag _ = Nothing

||| Roundtrip proof: decoding an encoded CommandTag yields the original.
public export
command_tagRoundtrip : (x : CommandTag) -> tagToCommandTag (command_tagToTag x) = Just x
command_tagRoundtrip User = Refl
command_tagRoundtrip Pass = Refl
command_tagRoundtrip Acct = Refl
command_tagRoundtrip Cwd = Refl
command_tagRoundtrip Cdup = Refl
command_tagRoundtrip Quit = Refl
command_tagRoundtrip Pasv = Refl
command_tagRoundtrip Port = Refl
command_tagRoundtrip TypeCmd = Refl
command_tagRoundtrip Retr = Refl
command_tagRoundtrip Stor = Refl
command_tagRoundtrip Dele = Refl
command_tagRoundtrip Rmd = Refl
command_tagRoundtrip Mkd = Refl
command_tagRoundtrip Pwd = Refl
command_tagRoundtrip List = Refl
command_tagRoundtrip Nlst = Refl
command_tagRoundtrip Syst = Refl
command_tagRoundtrip Stat = Refl
command_tagRoundtrip Noop = Refl
command_tagRoundtrip Rnfr = Refl
command_tagRoundtrip Rnto = Refl
command_tagRoundtrip Size = Refl
