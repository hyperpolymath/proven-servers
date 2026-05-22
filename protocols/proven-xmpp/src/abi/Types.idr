-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- XMPPABI.Types: C-ABI-compatible numeric representations of XMPP types.
--
-- Maps every constructor of the core XMPP sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/xmpp.h) and the
-- Zig FFI enums (ffi/zig/src/xmpp.zig) exactly.
--
-- Types covered:
--   StanzaType   (3 constructors, tags 0-2)
--   MessageType  (5 constructors, tags 0-4)
--   PresenceType (5 constructors, tags 0-4)
--   IQType       (4 constructors, tags 0-3)
--   StreamError  (9 constructors, tags 0-8)

module XMPPABI.Types

import XMPP.Types

%default total

---------------------------------------------------------------------------
-- StanzaType (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
stanzaTypeSize : Nat
stanzaTypeSize = 1

||| Encode a StanzaType to its ABI tag value.
public export
stanzaTypeToTag : StanzaType -> Bits8
stanzaTypeToTag Message  = 0
stanzaTypeToTag Presence = 1
stanzaTypeToTag IQ       = 2

||| Decode an ABI tag to a StanzaType.
public export
tagToStanzaType : Bits8 -> Maybe StanzaType
tagToStanzaType 0 = Just Message
tagToStanzaType 1 = Just Presence
tagToStanzaType 2 = Just IQ
tagToStanzaType _ = Nothing

||| Roundtrip proof: decoding an encoded StanzaType yields the original.
public export
stanzaTypeRoundtrip : (s : StanzaType) -> tagToStanzaType (stanzaTypeToTag s) = Just s
stanzaTypeRoundtrip Message  = Refl
stanzaTypeRoundtrip Presence = Refl
stanzaTypeRoundtrip IQ       = Refl

---------------------------------------------------------------------------
-- MessageType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
messageTypeSize : Nat
messageTypeSize = 1

||| Encode a MessageType to its ABI tag value.
public export
messageTypeToTag : MessageType -> Bits8
messageTypeToTag Chat      = 0
messageTypeToTag Error     = 1
messageTypeToTag Groupchat = 2
messageTypeToTag Headline  = 3
messageTypeToTag Normal    = 4

||| Decode an ABI tag to a MessageType.
public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0 = Just Chat
tagToMessageType 1 = Just Error
tagToMessageType 2 = Just Groupchat
tagToMessageType 3 = Just Headline
tagToMessageType 4 = Just Normal
tagToMessageType _ = Nothing

||| Roundtrip proof: decoding an encoded MessageType yields the original.
public export
messageTypeRoundtrip : (m : MessageType) -> tagToMessageType (messageTypeToTag m) = Just m
messageTypeRoundtrip Chat      = Refl
messageTypeRoundtrip Error     = Refl
messageTypeRoundtrip Groupchat = Refl
messageTypeRoundtrip Headline  = Refl
messageTypeRoundtrip Normal    = Refl

---------------------------------------------------------------------------
-- PresenceType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
presenceTypeSize : Nat
presenceTypeSize = 1

||| Encode a PresenceType to its ABI tag value.
public export
presenceTypeToTag : PresenceType -> Bits8
presenceTypeToTag Available   = 0
presenceTypeToTag Away        = 1
presenceTypeToTag DND         = 2
presenceTypeToTag XA          = 3
presenceTypeToTag Unavailable = 4

||| Decode an ABI tag to a PresenceType.
public export
tagToPresenceType : Bits8 -> Maybe PresenceType
tagToPresenceType 0 = Just Available
tagToPresenceType 1 = Just Away
tagToPresenceType 2 = Just DND
tagToPresenceType 3 = Just XA
tagToPresenceType 4 = Just Unavailable
tagToPresenceType _ = Nothing

||| Roundtrip proof: decoding an encoded PresenceType yields the original.
public export
presenceTypeRoundtrip : (p : PresenceType) -> tagToPresenceType (presenceTypeToTag p) = Just p
presenceTypeRoundtrip Available   = Refl
presenceTypeRoundtrip Away        = Refl
presenceTypeRoundtrip DND         = Refl
presenceTypeRoundtrip XA          = Refl
presenceTypeRoundtrip Unavailable = Refl

---------------------------------------------------------------------------
-- IQType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
iqTypeSize : Nat
iqTypeSize = 1

||| Encode an IQType to its ABI tag value.
public export
iqTypeToTag : IQType -> Bits8
iqTypeToTag Get     = 0
iqTypeToTag Set     = 1
iqTypeToTag Result  = 2
iqTypeToTag IQError = 3

||| Decode an ABI tag to an IQType.
public export
tagToIQType : Bits8 -> Maybe IQType
tagToIQType 0 = Just Get
tagToIQType 1 = Just Set
tagToIQType 2 = Just Result
tagToIQType 3 = Just IQError
tagToIQType _ = Nothing

||| Roundtrip proof: decoding an encoded IQType yields the original.
public export
iqTypeRoundtrip : (i : IQType) -> tagToIQType (iqTypeToTag i) = Just i
iqTypeRoundtrip Get     = Refl
iqTypeRoundtrip Set     = Refl
iqTypeRoundtrip Result  = Refl
iqTypeRoundtrip IQError = Refl

---------------------------------------------------------------------------
-- StreamError (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
streamErrorSize : Nat
streamErrorSize = 1

||| Encode a StreamError to its ABI tag value.
public export
streamErrorToTag : StreamError -> Bits8
streamErrorToTag BadFormat          = 0
streamErrorToTag Conflict           = 1
streamErrorToTag ConnectionTimeout  = 2
streamErrorToTag HostGone           = 3
streamErrorToTag HostUnknown        = 4
streamErrorToTag NotAuthorized      = 5
streamErrorToTag PolicyViolation    = 6
streamErrorToTag ResourceConstraint = 7
streamErrorToTag SystemShutdown     = 8

||| Decode an ABI tag to a StreamError.
public export
tagToStreamError : Bits8 -> Maybe StreamError
tagToStreamError 0 = Just BadFormat
tagToStreamError 1 = Just Conflict
tagToStreamError 2 = Just ConnectionTimeout
tagToStreamError 3 = Just HostGone
tagToStreamError 4 = Just HostUnknown
tagToStreamError 5 = Just NotAuthorized
tagToStreamError 6 = Just PolicyViolation
tagToStreamError 7 = Just ResourceConstraint
tagToStreamError 8 = Just SystemShutdown
tagToStreamError _ = Nothing

||| Roundtrip proof: decoding an encoded StreamError yields the original.
public export
streamErrorRoundtrip : (e : StreamError) -> tagToStreamError (streamErrorToTag e) = Just e
streamErrorRoundtrip BadFormat          = Refl
streamErrorRoundtrip Conflict           = Refl
streamErrorRoundtrip ConnectionTimeout  = Refl
streamErrorRoundtrip HostGone           = Refl
streamErrorRoundtrip HostUnknown        = Refl
streamErrorRoundtrip NotAuthorized      = Refl
streamErrorRoundtrip PolicyViolation    = Refl
streamErrorRoundtrip ResourceConstraint = Refl
streamErrorRoundtrip SystemShutdown     = Refl
