-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LPDABI.Layout: C-ABI-compatible numeric representations of LPD types.
--
-- Maps the LPD domain types (CommandCode, SubCommandCode, JobStatus
-- simplified to a closed enum, QueueState) to fixed Bits8 values for
-- C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- Note: LPD Commands carry parameters (queue name, job list, etc.) that
-- cannot be represented as a single byte. The FFI layer represents only
-- the command code (0x01-0x05) and sub-command code (0x01-0x03).
-- String data is passed separately through the FFI API.
--
-- Tag values here MUST match the C header (generated/abi/lpd.h) and the
-- Zig FFI enums (ffi/zig/src/lpd.zig) exactly.

module LPDABI.Layout

%default total

---------------------------------------------------------------------------
-- CommandCode (5 constructors, tags 1-5 per RFC 1179)
---------------------------------------------------------------------------

||| LPD command codes as byte values (RFC 1179 Section 5).
public export
data CommandCode : Type where
  ||| 0x01: Print any waiting jobs.
  CmdPrintJob       : CommandCode
  ||| 0x02: Receive a print job.
  CmdReceiveJob     : CommandCode
  ||| 0x03: Send short queue state.
  CmdShortQueue     : CommandCode
  ||| 0x04: Send long queue state.
  CmdLongQueue      : CommandCode
  ||| 0x05: Remove jobs.
  CmdRemoveJobs     : CommandCode

public export
Eq CommandCode where
  CmdPrintJob   == CmdPrintJob   = True
  CmdReceiveJob == CmdReceiveJob = True
  CmdShortQueue == CmdShortQueue = True
  CmdLongQueue  == CmdLongQueue  = True
  CmdRemoveJobs == CmdRemoveJobs = True
  _             == _             = False

public export
Show CommandCode where
  show CmdPrintJob   = "PrintJob"
  show CmdReceiveJob = "ReceiveJob"
  show CmdShortQueue = "ShortQueueState"
  show CmdLongQueue  = "LongQueueState"
  show CmdRemoveJobs = "RemoveJobs"

||| C-ABI representation size for CommandCode (1 byte).
public export
commandCodeSize : Nat
commandCodeSize = 1

||| Map CommandCode to its C-ABI byte value (RFC 1179 codes).
public export
commandCodeToTag : CommandCode -> Bits8
commandCodeToTag CmdPrintJob   = 1
commandCodeToTag CmdReceiveJob = 2
commandCodeToTag CmdShortQueue = 3
commandCodeToTag CmdLongQueue  = 4
commandCodeToTag CmdRemoveJobs = 5

||| Recover CommandCode from its C-ABI byte value.
public export
tagToCommandCode : Bits8 -> Maybe CommandCode
tagToCommandCode 1 = Just CmdPrintJob
tagToCommandCode 2 = Just CmdReceiveJob
tagToCommandCode 3 = Just CmdShortQueue
tagToCommandCode 4 = Just CmdLongQueue
tagToCommandCode 5 = Just CmdRemoveJobs
tagToCommandCode _ = Nothing

||| Proof: encoding then decoding CommandCode is the identity.
public export
commandCodeRoundtrip : (c : CommandCode) -> tagToCommandCode (commandCodeToTag c) = Just c
commandCodeRoundtrip CmdPrintJob   = Refl
commandCodeRoundtrip CmdReceiveJob = Refl
commandCodeRoundtrip CmdShortQueue = Refl
commandCodeRoundtrip CmdLongQueue  = Refl
commandCodeRoundtrip CmdRemoveJobs = Refl

---------------------------------------------------------------------------
-- SubCommandCode (3 constructors, tags 1-3 per RFC 1179)
---------------------------------------------------------------------------

||| LPD sub-command codes for the ReceiveJob phase (RFC 1179 Section 6).
public export
data SubCommandCode : Type where
  ||| 0x01: Abort the current job receive.
  SubAbortJob     : SubCommandCode
  ||| 0x02: Receive a control file.
  SubControlFile  : SubCommandCode
  ||| 0x03: Receive a data file.
  SubDataFile     : SubCommandCode

public export
Eq SubCommandCode where
  SubAbortJob    == SubAbortJob    = True
  SubControlFile == SubControlFile = True
  SubDataFile    == SubDataFile    = True
  _              == _              = False

public export
Show SubCommandCode where
  show SubAbortJob    = "AbortJob"
  show SubControlFile = "ReceiveControlFile"
  show SubDataFile    = "ReceiveDataFile"

||| C-ABI representation size for SubCommandCode (1 byte).
public export
subCommandCodeSize : Nat
subCommandCodeSize = 1

||| Map SubCommandCode to its C-ABI byte value (RFC 1179 codes).
public export
subCommandCodeToTag : SubCommandCode -> Bits8
subCommandCodeToTag SubAbortJob    = 1
subCommandCodeToTag SubControlFile = 2
subCommandCodeToTag SubDataFile    = 3

||| Recover SubCommandCode from its C-ABI byte value.
public export
tagToSubCommandCode : Bits8 -> Maybe SubCommandCode
tagToSubCommandCode 1 = Just SubAbortJob
tagToSubCommandCode 2 = Just SubControlFile
tagToSubCommandCode 3 = Just SubDataFile
tagToSubCommandCode _ = Nothing

||| Proof: encoding then decoding SubCommandCode is the identity.
public export
subCommandCodeRoundtrip : (s : SubCommandCode) -> tagToSubCommandCode (subCommandCodeToTag s) = Just s
subCommandCodeRoundtrip SubAbortJob    = Refl
subCommandCodeRoundtrip SubControlFile = Refl
subCommandCodeRoundtrip SubDataFile    = Refl

---------------------------------------------------------------------------
-- JobStatusTag (4 constructors, tags 0-3)
-- Simplified version of LPD.Job.JobStatus for FFI (no String payload).
---------------------------------------------------------------------------

||| Simplified job status for FFI representation.
||| The full JobStatus type carries a reason String for Failed, which
||| cannot be represented as a single byte tag.  The FFI layer uses
||| this simplified version and passes the reason separately.
public export
data JobStatusTag : Type where
  ||| Job is waiting in the queue.
  JsPending  : JobStatusTag
  ||| Job is currently being printed.
  JsPrinting : JobStatusTag
  ||| Job completed successfully.
  JsComplete : JobStatusTag
  ||| Job failed (reason passed separately).
  JsFailed   : JobStatusTag

public export
Eq JobStatusTag where
  JsPending  == JsPending  = True
  JsPrinting == JsPrinting = True
  JsComplete == JsComplete = True
  JsFailed   == JsFailed   = True
  _          == _          = False

public export
Show JobStatusTag where
  show JsPending  = "Pending"
  show JsPrinting = "Printing"
  show JsComplete = "Complete"
  show JsFailed   = "Failed"

||| C-ABI representation size for JobStatusTag (1 byte).
public export
jobStatusTagSize : Nat
jobStatusTagSize = 1

||| Map JobStatusTag to its C-ABI byte value.
public export
jobStatusTagToTag : JobStatusTag -> Bits8
jobStatusTagToTag JsPending  = 0
jobStatusTagToTag JsPrinting = 1
jobStatusTagToTag JsComplete = 2
jobStatusTagToTag JsFailed   = 3

||| Recover JobStatusTag from its C-ABI byte value.
public export
tagToJobStatusTag : Bits8 -> Maybe JobStatusTag
tagToJobStatusTag 0 = Just JsPending
tagToJobStatusTag 1 = Just JsPrinting
tagToJobStatusTag 2 = Just JsComplete
tagToJobStatusTag 3 = Just JsFailed
tagToJobStatusTag _ = Nothing

||| Proof: encoding then decoding JobStatusTag is the identity.
public export
jobStatusTagRoundtrip : (j : JobStatusTag) -> tagToJobStatusTag (jobStatusTagToTag j) = Just j
jobStatusTagRoundtrip JsPending  = Refl
jobStatusTagRoundtrip JsPrinting = Refl
jobStatusTagRoundtrip JsComplete = Refl
jobStatusTagRoundtrip JsFailed   = Refl

---------------------------------------------------------------------------
-- LPDError (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| Error codes for LPD FFI operations.
public export
data LPDError : Type where
  ||| No error.
  LpdOk               : LPDError
  ||| Invalid slot index.
  LpdInvalidSlot       : LPDError
  ||| Queue not active.
  LpdNotActive         : LPDError
  ||| Queue is full.
  LpdQueueFull         : LPDError
  ||| Queue is not accepting jobs.
  LpdNotAccepting      : LPDError
  ||| Job not found.
  LpdJobNotFound       : LPDError
  ||| Invalid parameter value.
  LpdInvalidParam      : LPDError

public export
Eq LPDError where
  LpdOk           == LpdOk           = True
  LpdInvalidSlot  == LpdInvalidSlot  = True
  LpdNotActive    == LpdNotActive    = True
  LpdQueueFull    == LpdQueueFull    = True
  LpdNotAccepting == LpdNotAccepting = True
  LpdJobNotFound  == LpdJobNotFound  = True
  LpdInvalidParam == LpdInvalidParam = True
  _               == _               = False

public export
Show LPDError where
  show LpdOk           = "Ok"
  show LpdInvalidSlot  = "InvalidSlot"
  show LpdNotActive    = "NotActive"
  show LpdQueueFull    = "QueueFull"
  show LpdNotAccepting = "NotAccepting"
  show LpdJobNotFound  = "JobNotFound"
  show LpdInvalidParam = "InvalidParam"

||| C-ABI representation size for LPDError (1 byte).
public export
lpdErrorSize : Nat
lpdErrorSize = 1

||| Map LPDError to its C-ABI byte value.
public export
lpdErrorToTag : LPDError -> Bits8
lpdErrorToTag LpdOk           = 0
lpdErrorToTag LpdInvalidSlot  = 1
lpdErrorToTag LpdNotActive    = 2
lpdErrorToTag LpdQueueFull    = 3
lpdErrorToTag LpdNotAccepting = 4
lpdErrorToTag LpdJobNotFound  = 5
lpdErrorToTag LpdInvalidParam = 6

||| Recover LPDError from its C-ABI byte value.
public export
tagToLPDError : Bits8 -> Maybe LPDError
tagToLPDError 0 = Just LpdOk
tagToLPDError 1 = Just LpdInvalidSlot
tagToLPDError 2 = Just LpdNotActive
tagToLPDError 3 = Just LpdQueueFull
tagToLPDError 4 = Just LpdNotAccepting
tagToLPDError 5 = Just LpdJobNotFound
tagToLPDError 6 = Just LpdInvalidParam
tagToLPDError _ = Nothing

||| Proof: encoding then decoding LPDError is the identity.
public export
lpdErrorRoundtrip : (e : LPDError) -> tagToLPDError (lpdErrorToTag e) = Just e
lpdErrorRoundtrip LpdOk           = Refl
lpdErrorRoundtrip LpdInvalidSlot  = Refl
lpdErrorRoundtrip LpdNotActive    = Refl
lpdErrorRoundtrip LpdQueueFull    = Refl
lpdErrorRoundtrip LpdNotAccepting = Refl
lpdErrorRoundtrip LpdJobNotFound  = Refl
lpdErrorRoundtrip LpdInvalidParam = Refl
