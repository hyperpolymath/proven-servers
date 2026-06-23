-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| Core HTTP/3 types (RFC 9114) as closed sum types with Show/Eq.
|||
||| proven-http3 models the structural layer of HTTP/3 over QUIC: frame and
||| unidirectional-stream identity, the request-stream frame sequence, and
||| the frame-vs-stream rules.  QPACK field compression, the full settings
||| exchange, server push delivery, and the HTTP semantics layer are out of
||| scope (see README).  HTTP/3 frames are length-delimited and carried on
||| QUIC streams; the byte-level varint codec lives in proven-quic.
module Http3.Types

%default total

---------------------------------------------------------------------------
-- Frame types (RFC 9114 Section 7.2)
---------------------------------------------------------------------------

||| The defined HTTP/3 frame types.  (Reserved/grease types are not modelled
||| as constructors; the engine treats unknown types as ignorable.)
public export
data H3Frame : Type where
  Data        : H3Frame
  Headers     : H3Frame
  CancelPush  : H3Frame
  Settings    : H3Frame
  PushPromise : H3Frame
  GoAway      : H3Frame
  MaxPushId   : H3Frame

public export
Eq H3Frame where
  Data        == Data        = True
  Headers     == Headers     = True
  CancelPush  == CancelPush  = True
  Settings    == Settings    = True
  PushPromise == PushPromise = True
  GoAway      == GoAway      = True
  MaxPushId   == MaxPushId   = True
  _           == _           = False

public export
Show H3Frame where
  show Data        = "DATA"
  show Headers     = "HEADERS"
  show CancelPush  = "CANCEL_PUSH"
  show Settings    = "SETTINGS"
  show PushPromise = "PUSH_PROMISE"
  show GoAway      = "GOAWAY"
  show MaxPushId   = "MAX_PUSH_ID"

---------------------------------------------------------------------------
-- Unidirectional stream types (RFC 9114 Sections 6.2, 11.2.4)
---------------------------------------------------------------------------

public export
data H3StreamType : Type where
  ControlStream      : H3StreamType
  PushStream         : H3StreamType
  QpackEncoderStream : H3StreamType
  QpackDecoderStream : H3StreamType

public export
Eq H3StreamType where
  ControlStream      == ControlStream      = True
  PushStream         == PushStream         = True
  QpackEncoderStream == QpackEncoderStream = True
  QpackDecoderStream == QpackDecoderStream = True
  _                  == _                  = False

public export
Show H3StreamType where
  show ControlStream      = "control"
  show PushStream         = "push"
  show QpackEncoderStream = "qpack-encoder"
  show QpackDecoderStream = "qpack-decoder"

---------------------------------------------------------------------------
-- Settings identifiers (RFC 9114 Section 7.2.4.1, RFC 9204 Section 5)
---------------------------------------------------------------------------

public export
data H3Setting : Type where
  QpackMaxTableCapacity : H3Setting
  MaxFieldSectionSize   : H3Setting
  QpackBlockedStreams   : H3Setting

public export
Eq H3Setting where
  QpackMaxTableCapacity == QpackMaxTableCapacity = True
  MaxFieldSectionSize   == MaxFieldSectionSize   = True
  QpackBlockedStreams   == QpackBlockedStreams   = True
  _                     == _                     = False

public export
Show H3Setting where
  show QpackMaxTableCapacity = "QPACK_MAX_TABLE_CAPACITY"
  show MaxFieldSectionSize   = "MAX_FIELD_SECTION_SIZE"
  show QpackBlockedStreams   = "QPACK_BLOCKED_STREAMS"

---------------------------------------------------------------------------
-- Error codes (RFC 9114 Section 8.1), contiguous subset 0x100-0x10b
---------------------------------------------------------------------------

public export
data H3Error : Type where
  H3NoError              : H3Error
  H3GeneralProtocolError : H3Error
  H3InternalError        : H3Error
  H3StreamCreationError  : H3Error
  H3ClosedCriticalStream : H3Error
  H3FrameUnexpected      : H3Error
  H3FrameError           : H3Error
  H3ExcessiveLoad        : H3Error
  H3IdError              : H3Error
  H3SettingsError        : H3Error
  H3MissingSettings      : H3Error
  H3RequestRejected      : H3Error

public export
Eq H3Error where
  H3NoError              == H3NoError              = True
  H3GeneralProtocolError == H3GeneralProtocolError = True
  H3InternalError        == H3InternalError        = True
  H3StreamCreationError  == H3StreamCreationError  = True
  H3ClosedCriticalStream == H3ClosedCriticalStream = True
  H3FrameUnexpected      == H3FrameUnexpected      = True
  H3FrameError           == H3FrameError           = True
  H3ExcessiveLoad        == H3ExcessiveLoad        = True
  H3IdError              == H3IdError              = True
  H3SettingsError        == H3SettingsError        = True
  H3MissingSettings      == H3MissingSettings      = True
  H3RequestRejected      == H3RequestRejected      = True
  _                      == _                      = False

public export
Show H3Error where
  show H3NoError              = "0x100 H3_NO_ERROR"
  show H3GeneralProtocolError = "0x101 H3_GENERAL_PROTOCOL_ERROR"
  show H3InternalError        = "0x102 H3_INTERNAL_ERROR"
  show H3StreamCreationError  = "0x103 H3_STREAM_CREATION_ERROR"
  show H3ClosedCriticalStream = "0x104 H3_CLOSED_CRITICAL_STREAM"
  show H3FrameUnexpected      = "0x105 H3_FRAME_UNEXPECTED"
  show H3FrameError           = "0x106 H3_FRAME_ERROR"
  show H3ExcessiveLoad        = "0x107 H3_EXCESSIVE_LOAD"
  show H3IdError              = "0x108 H3_ID_ERROR"
  show H3SettingsError        = "0x109 H3_SETTINGS_ERROR"
  show H3MissingSettings      = "0x10a H3_MISSING_SETTINGS"
  show H3RequestRejected      = "0x10b H3_REQUEST_REJECTED"

---------------------------------------------------------------------------
-- Request-stream frame-sequence states (RFC 9114 Section 4.1)
---------------------------------------------------------------------------

||| The state of a request/response exchange on a request stream, tracked by
||| the sequence of frames seen: HEADERS, then optional DATA, then optional
||| trailing HEADERS.
public export
data ReqState : Type where
  RInit        : ReqState
  RReqHeaders  : ReqState
  RData        : ReqState
  RTrailers    : ReqState
  RDone        : ReqState

public export
Eq ReqState where
  RInit       == RInit       = True
  RReqHeaders == RReqHeaders = True
  RData       == RData       = True
  RTrailers   == RTrailers   = True
  RDone       == RDone       = True
  _           == _           = False

public export
Show ReqState where
  show RInit       = "Init"
  show RReqHeaders = "HeadersReceived"
  show RData       = "DataFlowing"
  show RTrailers   = "Trailers"
  show RDone       = "Done"
