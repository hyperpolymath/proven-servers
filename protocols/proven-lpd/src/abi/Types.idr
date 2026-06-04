-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- LpdABI.Types: C-ABI-compatible numeric representations of Lpd types.
--
-- Maps every constructor of the core Lpd sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/lpd.zig) exactly.
--
-- Types covered:
--   CommandCode               (5 constructors, tags 0-5)
--   SubCommandCode            (3 constructors, tags 0-3)
--   JobStatusTag              (4 constructors, tags 0-3)
--   LPDError                  (7 constructors, tags 0-6)

module LpdABI.Types

%default total

---------------------------------------------------------------------------
-- CommandCode (5 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
command_codeSize : Nat
command_codeSize = 1

||| CommandCode sum type for ABI encoding.
public export
data CommandCode : Type where
  PrintJob : CommandCode
  ReceiveJob : CommandCode
  ShortQueue : CommandCode
  LongQueue : CommandCode
  RemoveJobs : CommandCode

||| Encode a CommandCode to its ABI tag value.
public export
command_codeToTag : CommandCode -> Bits8
command_codeToTag PrintJob = 1
command_codeToTag ReceiveJob = 2
command_codeToTag ShortQueue = 3
command_codeToTag LongQueue = 4
command_codeToTag RemoveJobs = 5

||| Decode an ABI tag to a CommandCode.
public export
tagToCommandCode : Bits8 -> Maybe CommandCode
tagToCommandCode 1 = Just PrintJob
tagToCommandCode 2 = Just ReceiveJob
tagToCommandCode 3 = Just ShortQueue
tagToCommandCode 4 = Just LongQueue
tagToCommandCode 5 = Just RemoveJobs
tagToCommandCode _ = Nothing

||| Roundtrip proof: decoding an encoded CommandCode yields the original.
public export
command_codeRoundtrip : (x : CommandCode) -> tagToCommandCode (command_codeToTag x) = Just x
command_codeRoundtrip PrintJob = Refl
command_codeRoundtrip ReceiveJob = Refl
command_codeRoundtrip ShortQueue = Refl
command_codeRoundtrip LongQueue = Refl
command_codeRoundtrip RemoveJobs = Refl

---------------------------------------------------------------------------
-- SubCommandCode (3 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
sub_command_codeSize : Nat
sub_command_codeSize = 1

||| SubCommandCode sum type for ABI encoding.
public export
data SubCommandCode : Type where
  AbortJob : SubCommandCode
  ControlFile : SubCommandCode
  DataFile : SubCommandCode

||| Encode a SubCommandCode to its ABI tag value.
public export
sub_command_codeToTag : SubCommandCode -> Bits8
sub_command_codeToTag AbortJob = 1
sub_command_codeToTag ControlFile = 2
sub_command_codeToTag DataFile = 3

||| Decode an ABI tag to a SubCommandCode.
public export
tagToSubCommandCode : Bits8 -> Maybe SubCommandCode
tagToSubCommandCode 1 = Just AbortJob
tagToSubCommandCode 2 = Just ControlFile
tagToSubCommandCode 3 = Just DataFile
tagToSubCommandCode _ = Nothing

||| Roundtrip proof: decoding an encoded SubCommandCode yields the original.
public export
sub_command_codeRoundtrip : (x : SubCommandCode) -> tagToSubCommandCode (sub_command_codeToTag x) = Just x
sub_command_codeRoundtrip AbortJob = Refl
sub_command_codeRoundtrip ControlFile = Refl
sub_command_codeRoundtrip DataFile = Refl

---------------------------------------------------------------------------
-- JobStatusTag (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
job_status_tagSize : Nat
job_status_tagSize = 1

||| JobStatusTag sum type for ABI encoding.
public export
data JobStatusTag : Type where
  Pending : JobStatusTag
  Printing : JobStatusTag
  Complete : JobStatusTag
  Failed : JobStatusTag

||| Encode a JobStatusTag to its ABI tag value.
public export
job_status_tagToTag : JobStatusTag -> Bits8
job_status_tagToTag Pending = 0
job_status_tagToTag Printing = 1
job_status_tagToTag Complete = 2
job_status_tagToTag Failed = 3

||| Decode an ABI tag to a JobStatusTag.
public export
tagToJobStatusTag : Bits8 -> Maybe JobStatusTag
tagToJobStatusTag 0 = Just Pending
tagToJobStatusTag 1 = Just Printing
tagToJobStatusTag 2 = Just Complete
tagToJobStatusTag 3 = Just Failed
tagToJobStatusTag _ = Nothing

||| Roundtrip proof: decoding an encoded JobStatusTag yields the original.
public export
job_status_tagRoundtrip : (x : JobStatusTag) -> tagToJobStatusTag (job_status_tagToTag x) = Just x
job_status_tagRoundtrip Pending = Refl
job_status_tagRoundtrip Printing = Refl
job_status_tagRoundtrip Complete = Refl
job_status_tagRoundtrip Failed = Refl

---------------------------------------------------------------------------
-- LPDError (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
l_p_d_errorSize : Nat
l_p_d_errorSize = 1

||| LPDError sum type for ABI encoding.
public export
data LPDError : Type where
  Ok : LPDError
  InvalidSlot : LPDError
  NotActive : LPDError
  QueueFull : LPDError
  NotAccepting : LPDError
  JobNotFound : LPDError
  InvalidParam : LPDError

||| Encode a LPDError to its ABI tag value.
public export
l_p_d_errorToTag : LPDError -> Bits8
l_p_d_errorToTag Ok = 0
l_p_d_errorToTag InvalidSlot = 1
l_p_d_errorToTag NotActive = 2
l_p_d_errorToTag QueueFull = 3
l_p_d_errorToTag NotAccepting = 4
l_p_d_errorToTag JobNotFound = 5
l_p_d_errorToTag InvalidParam = 6

||| Decode an ABI tag to a LPDError.
public export
tagToLPDError : Bits8 -> Maybe LPDError
tagToLPDError 0 = Just Ok
tagToLPDError 1 = Just InvalidSlot
tagToLPDError 2 = Just NotActive
tagToLPDError 3 = Just QueueFull
tagToLPDError 4 = Just NotAccepting
tagToLPDError 5 = Just JobNotFound
tagToLPDError 6 = Just InvalidParam
tagToLPDError _ = Nothing

||| Roundtrip proof: decoding an encoded LPDError yields the original.
public export
l_p_d_errorRoundtrip : (x : LPDError) -> tagToLPDError (l_p_d_errorToTag x) = Just x
l_p_d_errorRoundtrip Ok = Refl
l_p_d_errorRoundtrip InvalidSlot = Refl
l_p_d_errorRoundtrip NotActive = Refl
l_p_d_errorRoundtrip QueueFull = Refl
l_p_d_errorRoundtrip NotAccepting = Refl
l_p_d_errorRoundtrip JobNotFound = Refl
l_p_d_errorRoundtrip InvalidParam = Refl
