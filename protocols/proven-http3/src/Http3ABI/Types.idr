-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| C-ABI numeric encodings for the proven-http3 enums, each with encoder,
||| decoder, and round-trip proof.  These are dense ABI tags; the sparse
||| on-the-wire codes live in Http3.Frames.  Tags MUST match the Zig engine.
module Http3ABI.Types

import Http3.Types

%default total

---------------------------------------------------------------------------
-- H3Frame (tags 0-6)
---------------------------------------------------------------------------

public export
frameToTag : H3Frame -> Bits8
frameToTag Data        = 0
frameToTag Headers     = 1
frameToTag CancelPush  = 2
frameToTag Settings    = 3
frameToTag PushPromise = 4
frameToTag GoAway      = 5
frameToTag MaxPushId   = 6

public export
tagToFrame : Bits8 -> Maybe H3Frame
tagToFrame 0 = Just Data
tagToFrame 1 = Just Headers
tagToFrame 2 = Just CancelPush
tagToFrame 3 = Just Settings
tagToFrame 4 = Just PushPromise
tagToFrame 5 = Just GoAway
tagToFrame 6 = Just MaxPushId
tagToFrame _ = Nothing

public export
frameRoundtrip : (f : H3Frame) -> tagToFrame (frameToTag f) = Just f
frameRoundtrip Data        = Refl
frameRoundtrip Headers     = Refl
frameRoundtrip CancelPush  = Refl
frameRoundtrip Settings    = Refl
frameRoundtrip PushPromise = Refl
frameRoundtrip GoAway      = Refl
frameRoundtrip MaxPushId   = Refl

---------------------------------------------------------------------------
-- H3StreamType (tags 0-3, matching the wire codes)
---------------------------------------------------------------------------

public export
streamTypeToTag : H3StreamType -> Bits8
streamTypeToTag ControlStream      = 0
streamTypeToTag PushStream         = 1
streamTypeToTag QpackEncoderStream = 2
streamTypeToTag QpackDecoderStream = 3

public export
tagToStreamType : Bits8 -> Maybe H3StreamType
tagToStreamType 0 = Just ControlStream
tagToStreamType 1 = Just PushStream
tagToStreamType 2 = Just QpackEncoderStream
tagToStreamType 3 = Just QpackDecoderStream
tagToStreamType _ = Nothing

public export
streamTypeTagRoundtrip : (s : H3StreamType) -> tagToStreamType (streamTypeToTag s) = Just s
streamTypeTagRoundtrip ControlStream      = Refl
streamTypeTagRoundtrip PushStream         = Refl
streamTypeTagRoundtrip QpackEncoderStream = Refl
streamTypeTagRoundtrip QpackDecoderStream = Refl

---------------------------------------------------------------------------
-- H3Setting (tags 0-2)
---------------------------------------------------------------------------

public export
settingToTag : H3Setting -> Bits8
settingToTag QpackMaxTableCapacity = 0
settingToTag MaxFieldSectionSize   = 1
settingToTag QpackBlockedStreams   = 2

public export
tagToSetting : Bits8 -> Maybe H3Setting
tagToSetting 0 = Just QpackMaxTableCapacity
tagToSetting 1 = Just MaxFieldSectionSize
tagToSetting 2 = Just QpackBlockedStreams
tagToSetting _ = Nothing

public export
settingRoundtrip : (s : H3Setting) -> tagToSetting (settingToTag s) = Just s
settingRoundtrip QpackMaxTableCapacity = Refl
settingRoundtrip MaxFieldSectionSize   = Refl
settingRoundtrip QpackBlockedStreams   = Refl

---------------------------------------------------------------------------
-- ReqState (tags 0-4)
---------------------------------------------------------------------------

public export
reqStateToTag : ReqState -> Bits8
reqStateToTag RInit       = 0
reqStateToTag RReqHeaders = 1
reqStateToTag RData       = 2
reqStateToTag RTrailers   = 3
reqStateToTag RDone       = 4

public export
tagToReqState : Bits8 -> Maybe ReqState
tagToReqState 0 = Just RInit
tagToReqState 1 = Just RReqHeaders
tagToReqState 2 = Just RData
tagToReqState 3 = Just RTrailers
tagToReqState 4 = Just RDone
tagToReqState _ = Nothing

public export
reqStateRoundtrip : (s : ReqState) -> tagToReqState (reqStateToTag s) = Just s
reqStateRoundtrip RInit       = Refl
reqStateRoundtrip RReqHeaders = Refl
reqStateRoundtrip RData       = Refl
reqStateRoundtrip RTrailers   = Refl
reqStateRoundtrip RDone       = Refl

---------------------------------------------------------------------------
-- H3Error (tags 0-11, matching the contiguous 0x100-0x10b wire range)
---------------------------------------------------------------------------

public export
errorToTag : H3Error -> Bits8
errorToTag H3NoError              = 0
errorToTag H3GeneralProtocolError = 1
errorToTag H3InternalError        = 2
errorToTag H3StreamCreationError  = 3
errorToTag H3ClosedCriticalStream = 4
errorToTag H3FrameUnexpected      = 5
errorToTag H3FrameError           = 6
errorToTag H3ExcessiveLoad        = 7
errorToTag H3IdError              = 8
errorToTag H3SettingsError        = 9
errorToTag H3MissingSettings      = 10
errorToTag H3RequestRejected      = 11

public export
tagToError : Bits8 -> Maybe H3Error
tagToError 0  = Just H3NoError
tagToError 1  = Just H3GeneralProtocolError
tagToError 2  = Just H3InternalError
tagToError 3  = Just H3StreamCreationError
tagToError 4  = Just H3ClosedCriticalStream
tagToError 5  = Just H3FrameUnexpected
tagToError 6  = Just H3FrameError
tagToError 7  = Just H3ExcessiveLoad
tagToError 8  = Just H3IdError
tagToError 9  = Just H3SettingsError
tagToError 10 = Just H3MissingSettings
tagToError 11 = Just H3RequestRejected
tagToError _  = Nothing

public export
errorRoundtrip : (e : H3Error) -> tagToError (errorToTag e) = Just e
errorRoundtrip H3NoError              = Refl
errorRoundtrip H3GeneralProtocolError = Refl
errorRoundtrip H3InternalError        = Refl
errorRoundtrip H3StreamCreationError  = Refl
errorRoundtrip H3ClosedCriticalStream = Refl
errorRoundtrip H3FrameUnexpected      = Refl
errorRoundtrip H3FrameError           = Refl
errorRoundtrip H3ExcessiveLoad        = Refl
errorRoundtrip H3IdError              = Refl
errorRoundtrip H3SettingsError        = Refl
errorRoundtrip H3MissingSettings      = Refl
errorRoundtrip H3RequestRejected      = Refl
