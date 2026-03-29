-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FTPABI.Layout: C-ABI-compatible numeric representations of FTP types.
--
-- Maps every constructor of the five core sum types (SessionState,
-- TransferType, DataModeTag, TransferStateTag, ReplyCategory) and
-- CommandTag to fixed Bits8 values for C interop.  Each type gets a
-- total encoder, partial decoder, and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/ftp.h) and the
-- Zig FFI enums (ffi/zig/src/ftp.zig) exactly.

module FTPABI.Layout

import FTP.Session
import FTP.Transfer
import FTP.Reply
import FTP.Command

%default total

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
sessionStateSize : Nat
sessionStateSize = 1

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag Connected     = 0
sessionStateToTag UserOk        = 1
sessionStateToTag Authenticated = 2
sessionStateToTag Renaming      = 3
sessionStateToTag Quit          = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Connected
tagToSessionState 1 = Just UserOk
tagToSessionState 2 = Just Authenticated
tagToSessionState 3 = Just Renaming
tagToSessionState 4 = Just Quit
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip Connected     = Refl
sessionStateRoundtrip UserOk        = Refl
sessionStateRoundtrip Authenticated = Refl
sessionStateRoundtrip Renaming      = Refl
sessionStateRoundtrip Quit          = Refl

---------------------------------------------------------------------------
-- TransferType (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
transferTypeSize : Nat
transferTypeSize = 1

public export
transferTypeToTag : TransferType -> Bits8
transferTypeToTag ASCII  = 0
transferTypeToTag Binary = 1

public export
tagToTransferType : Bits8 -> Maybe TransferType
tagToTransferType 0 = Just ASCII
tagToTransferType 1 = Just Binary
tagToTransferType _ = Nothing

public export
transferTypeRoundtrip : (t : TransferType) -> tagToTransferType (transferTypeToTag t) = Just t
transferTypeRoundtrip ASCII  = Refl
transferTypeRoundtrip Binary = Refl

---------------------------------------------------------------------------
-- DataModeTag (2 constructors, tags 0-1)
-- (stripped of host/port data for ABI tag purposes)
---------------------------------------------------------------------------

||| ABI-level data mode discriminator (Active vs Passive).
public export
data DataModeTag : Type where
  ActiveTag  : DataModeTag
  PassiveTag : DataModeTag

public export
dataModeTagSize : Nat
dataModeTagSize = 1

public export
dataModeTagToTag : DataModeTag -> Bits8
dataModeTagToTag ActiveTag  = 0
dataModeTagToTag PassiveTag = 1

public export
tagToDataModeTag : Bits8 -> Maybe DataModeTag
tagToDataModeTag 0 = Just ActiveTag
tagToDataModeTag 1 = Just PassiveTag
tagToDataModeTag _ = Nothing

public export
dataModeTagRoundtrip : (m : DataModeTag) -> tagToDataModeTag (dataModeTagToTag m) = Just m
dataModeTagRoundtrip ActiveTag  = Refl
dataModeTagRoundtrip PassiveTag = Refl

---------------------------------------------------------------------------
-- TransferStateTag (4 constructors, tags 0-3)
-- (stripped of Nat/String payloads for ABI tag purposes)
---------------------------------------------------------------------------

||| ABI-level transfer state discriminator.
public export
data TransferStateTag : Type where
  IdleTag       : TransferStateTag
  InProgressTag : TransferStateTag
  CompletedTag  : TransferStateTag
  AbortedTag    : TransferStateTag

public export
transferStateTagSize : Nat
transferStateTagSize = 1

public export
transferStateTagToTag : TransferStateTag -> Bits8
transferStateTagToTag IdleTag       = 0
transferStateTagToTag InProgressTag = 1
transferStateTagToTag CompletedTag  = 2
transferStateTagToTag AbortedTag    = 3

public export
tagToTransferStateTag : Bits8 -> Maybe TransferStateTag
tagToTransferStateTag 0 = Just IdleTag
tagToTransferStateTag 1 = Just InProgressTag
tagToTransferStateTag 2 = Just CompletedTag
tagToTransferStateTag 3 = Just AbortedTag
tagToTransferStateTag _ = Nothing

public export
transferStateTagRoundtrip : (t : TransferStateTag) -> tagToTransferStateTag (transferStateTagToTag t) = Just t
transferStateTagRoundtrip IdleTag       = Refl
transferStateTagRoundtrip InProgressTag = Refl
transferStateTagRoundtrip CompletedTag  = Refl
transferStateTagRoundtrip AbortedTag    = Refl

---------------------------------------------------------------------------
-- ReplyCategory (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
replyCategorySize : Nat
replyCategorySize = 1

public export
replyCategoryToTag : ReplyCategory -> Bits8
replyCategoryToTag Preliminary  = 0
replyCategoryToTag Completion   = 1
replyCategoryToTag Intermediate = 2
replyCategoryToTag TransientNeg = 3
replyCategoryToTag PermanentNeg = 4

public export
tagToReplyCategory : Bits8 -> Maybe ReplyCategory
tagToReplyCategory 0 = Just Preliminary
tagToReplyCategory 1 = Just Completion
tagToReplyCategory 2 = Just Intermediate
tagToReplyCategory 3 = Just TransientNeg
tagToReplyCategory 4 = Just PermanentNeg
tagToReplyCategory _ = Nothing

public export
replyCategoryRoundtrip : (c : ReplyCategory) -> tagToReplyCategory (replyCategoryToTag c) = Just c
replyCategoryRoundtrip Preliminary  = Refl
replyCategoryRoundtrip Completion   = Refl
replyCategoryRoundtrip Intermediate = Refl
replyCategoryRoundtrip TransientNeg = Refl
replyCategoryRoundtrip PermanentNeg = Refl

---------------------------------------------------------------------------
-- CommandTag (23 constructors, tags 0-22)
-- (stripped of String payloads for ABI tag purposes)
---------------------------------------------------------------------------

||| ABI-level command discriminator.
public export
data CommandTag : Type where
  UserTag : CommandTag
  PassTag : CommandTag
  AcctTag : CommandTag
  CwdTag  : CommandTag
  CdupTag : CommandTag
  QuitTag : CommandTag
  PasvTag : CommandTag
  PortTag : CommandTag
  TypeTag : CommandTag
  RetrTag : CommandTag
  StorTag : CommandTag
  DeleTag : CommandTag
  RmdTag  : CommandTag
  MkdTag  : CommandTag
  PwdTag  : CommandTag
  ListTag : CommandTag
  NlstTag : CommandTag
  SystTag : CommandTag
  StatTag : CommandTag
  NoopTag : CommandTag
  RnfrTag : CommandTag
  RntoTag : CommandTag
  SizeTag : CommandTag

public export
commandTagSize : Nat
commandTagSize = 1

public export
commandTagToTag : CommandTag -> Bits8
commandTagToTag UserTag = 0
commandTagToTag PassTag = 1
commandTagToTag AcctTag = 2
commandTagToTag CwdTag  = 3
commandTagToTag CdupTag = 4
commandTagToTag QuitTag = 5
commandTagToTag PasvTag = 6
commandTagToTag PortTag = 7
commandTagToTag TypeTag = 8
commandTagToTag RetrTag = 9
commandTagToTag StorTag = 10
commandTagToTag DeleTag = 11
commandTagToTag RmdTag  = 12
commandTagToTag MkdTag  = 13
commandTagToTag PwdTag  = 14
commandTagToTag ListTag = 15
commandTagToTag NlstTag = 16
commandTagToTag SystTag = 17
commandTagToTag StatTag = 18
commandTagToTag NoopTag = 19
commandTagToTag RnfrTag = 20
commandTagToTag RntoTag = 21
commandTagToTag SizeTag = 22

public export
tagToCommandTag : Bits8 -> Maybe CommandTag
tagToCommandTag 0  = Just UserTag
tagToCommandTag 1  = Just PassTag
tagToCommandTag 2  = Just AcctTag
tagToCommandTag 3  = Just CwdTag
tagToCommandTag 4  = Just CdupTag
tagToCommandTag 5  = Just QuitTag
tagToCommandTag 6  = Just PasvTag
tagToCommandTag 7  = Just PortTag
tagToCommandTag 8  = Just TypeTag
tagToCommandTag 9  = Just RetrTag
tagToCommandTag 10 = Just StorTag
tagToCommandTag 11 = Just DeleTag
tagToCommandTag 12 = Just RmdTag
tagToCommandTag 13 = Just MkdTag
tagToCommandTag 14 = Just PwdTag
tagToCommandTag 15 = Just ListTag
tagToCommandTag 16 = Just NlstTag
tagToCommandTag 17 = Just SystTag
tagToCommandTag 18 = Just StatTag
tagToCommandTag 19 = Just NoopTag
tagToCommandTag 20 = Just RnfrTag
tagToCommandTag 21 = Just RntoTag
tagToCommandTag 22 = Just SizeTag
tagToCommandTag _  = Nothing

public export
commandTagRoundtrip : (c : CommandTag) -> tagToCommandTag (commandTagToTag c) = Just c
commandTagRoundtrip UserTag = Refl
commandTagRoundtrip PassTag = Refl
commandTagRoundtrip AcctTag = Refl
commandTagRoundtrip CwdTag  = Refl
commandTagRoundtrip CdupTag = Refl
commandTagRoundtrip QuitTag = Refl
commandTagRoundtrip PasvTag = Refl
commandTagRoundtrip PortTag = Refl
commandTagRoundtrip TypeTag = Refl
commandTagRoundtrip RetrTag = Refl
commandTagRoundtrip StorTag = Refl
commandTagRoundtrip DeleTag = Refl
commandTagRoundtrip RmdTag  = Refl
commandTagRoundtrip MkdTag  = Refl
commandTagRoundtrip PwdTag  = Refl
commandTagRoundtrip ListTag = Refl
commandTagRoundtrip NlstTag = Refl
commandTagRoundtrip SystTag = Refl
commandTagRoundtrip StatTag = Refl
commandTagRoundtrip NoopTag = Refl
commandTagRoundtrip RnfrTag = Refl
commandTagRoundtrip RntoTag = Refl
commandTagRoundtrip SizeTag = Refl
