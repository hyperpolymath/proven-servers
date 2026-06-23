-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| HTTP/3 frame wire codes, stream-type codes, and the frame-vs-stream
||| rules (RFC 9114 Sections 6.2, 7.2, 11.2).
module Http3.Frames

import Http3.Types

%default total

---------------------------------------------------------------------------
-- Frame wire codes (RFC 9114 Section 7.2 / 11.2.1)
---------------------------------------------------------------------------

||| The on-the-wire varint type code for a frame.
public export
frameWireCode : H3Frame -> Bits64
frameWireCode Data        = 0x00
frameWireCode Headers     = 0x01
frameWireCode CancelPush  = 0x03
frameWireCode Settings    = 0x04
frameWireCode PushPromise = 0x05
frameWireCode GoAway      = 0x07
frameWireCode MaxPushId   = 0x0d

||| Decode a wire type code into a known frame, or Nothing for reserved /
||| unknown / grease types (which a receiver ignores).
public export
frameFromWire : Bits64 -> Maybe H3Frame
frameFromWire 0x00 = Just Data
frameFromWire 0x01 = Just Headers
frameFromWire 0x03 = Just CancelPush
frameFromWire 0x04 = Just Settings
frameFromWire 0x05 = Just PushPromise
frameFromWire 0x07 = Just GoAway
frameFromWire 0x0d = Just MaxPushId
frameFromWire _    = Nothing

||| Wire codes round-trip through the decoder.
public export
frameWireRoundtrip : (f : H3Frame) -> frameFromWire (frameWireCode f) = Just f
frameWireRoundtrip Data        = Refl
frameWireRoundtrip Headers     = Refl
frameWireRoundtrip CancelPush  = Refl
frameWireRoundtrip Settings    = Refl
frameWireRoundtrip PushPromise = Refl
frameWireRoundtrip GoAway      = Refl
frameWireRoundtrip MaxPushId   = Refl

---------------------------------------------------------------------------
-- Unidirectional stream type codes (RFC 9114 Section 6.2)
---------------------------------------------------------------------------

public export
streamTypeCode : H3StreamType -> Bits64
streamTypeCode ControlStream      = 0x00
streamTypeCode PushStream         = 0x01
streamTypeCode QpackEncoderStream = 0x02
streamTypeCode QpackDecoderStream = 0x03

public export
streamTypeFromCode : Bits64 -> Maybe H3StreamType
streamTypeFromCode 0x00 = Just ControlStream
streamTypeFromCode 0x01 = Just PushStream
streamTypeFromCode 0x02 = Just QpackEncoderStream
streamTypeFromCode 0x03 = Just QpackDecoderStream
streamTypeFromCode _    = Nothing

public export
streamTypeRoundtrip : (s : H3StreamType) -> streamTypeFromCode (streamTypeCode s) = Just s
streamTypeRoundtrip ControlStream      = Refl
streamTypeRoundtrip PushStream         = Refl
streamTypeRoundtrip QpackEncoderStream = Refl
streamTypeRoundtrip QpackDecoderStream = Refl

---------------------------------------------------------------------------
-- Frame-vs-stream rules (RFC 9114 Section 7.2)
---------------------------------------------------------------------------

||| Whether a frame may appear on the control stream.
||| SETTINGS, GOAWAY, CANCEL_PUSH, MAX_PUSH_ID are control-stream frames.
public export
allowedOnControl : H3Frame -> Bool
allowedOnControl Settings   = True
allowedOnControl GoAway     = True
allowedOnControl CancelPush = True
allowedOnControl MaxPushId  = True
allowedOnControl _          = False

||| Whether a frame may appear on a request (or push) stream.
||| DATA, HEADERS, and PUSH_PROMISE are request-stream frames.
public export
allowedOnRequest : H3Frame -> Bool
allowedOnRequest Data        = True
allowedOnRequest Headers     = True
allowedOnRequest PushPromise = True
allowedOnRequest _           = False

---------------------------------------------------------------------------
-- Pinned facts
---------------------------------------------------------------------------

||| DATA frames are never valid on the control stream.
public export
dataNotOnControl : allowedOnControl Data = False
dataNotOnControl = Refl

||| SETTINGS frames are never valid on a request stream.
public export
settingsNotOnRequest : allowedOnRequest Settings = False
settingsNotOnRequest = Refl

||| SETTINGS is a control-stream frame.
public export
settingsOnControl : allowedOnControl Settings = True
settingsOnControl = Refl

||| HEADERS is a request-stream frame.
public export
headersOnRequest : allowedOnRequest Headers = True
headersOnRequest = Refl

||| No frame is valid on both the control stream and a request stream.
public export
controlAndRequestDisjoint : (f : H3Frame)
                          -> allowedOnControl f = True
                          -> allowedOnRequest f = False
controlAndRequestDisjoint Settings   _ = Refl
controlAndRequestDisjoint GoAway     _ = Refl
controlAndRequestDisjoint CancelPush _ = Refl
controlAndRequestDisjoint MaxPushId  _ = Refl
controlAndRequestDisjoint Data        Refl impossible
controlAndRequestDisjoint Headers     Refl impossible
controlAndRequestDisjoint PushPromise Refl impossible
