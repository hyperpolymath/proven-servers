-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ChatABI.Types: C-ABI-compatible numeric representations of proven-chat types.
--
-- Maps every constructor of the core chat sum types to fixed Bits8 values
-- for C interop.  Each type gets a total encoder, partial decoder, and
-- roundtrip proof guaranteeing encoding/decoding never loses information.
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/chat.zig) exactly.
--
-- Types covered:
--   MessageType    (9 constructors, tags 0-8)
--   PresenceStatus (5 constructors, tags 0-4)
--   RoomType       (4 constructors, tags 0-3)
--   Permission     (8 constructors, tags 0-7)
--   Event          (7 constructors, tags 0-6)

module ChatABI.Types

import Chat.Types

%default total

---------------------------------------------------------------------------
-- MessageType (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
messageTypeSize : Nat
messageTypeSize = 1

||| Encode MessageType to its ABI tag value.
public export
messageTypeToTag : MessageType -> Bits8
messageTypeToTag Text     = 0
messageTypeToTag Image    = 1
messageTypeToTag File     = 2
messageTypeToTag System   = 3
messageTypeToTag Reaction = 4
messageTypeToTag Edit     = 5
messageTypeToTag Delete   = 6
messageTypeToTag Reply    = 7
messageTypeToTag Thread   = 8

public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0 = Just Text
tagToMessageType 1 = Just Image
tagToMessageType 2 = Just File
tagToMessageType 3 = Just System
tagToMessageType 4 = Just Reaction
tagToMessageType 5 = Just Edit
tagToMessageType 6 = Just Delete
tagToMessageType 7 = Just Reply
tagToMessageType 8 = Just Thread
tagToMessageType _ = Nothing

public export
messageTypeRoundtrip : (m : MessageType) -> tagToMessageType (messageTypeToTag m) = Just m
messageTypeRoundtrip Text     = Refl
messageTypeRoundtrip Image    = Refl
messageTypeRoundtrip File     = Refl
messageTypeRoundtrip System   = Refl
messageTypeRoundtrip Reaction = Refl
messageTypeRoundtrip Edit     = Refl
messageTypeRoundtrip Delete   = Refl
messageTypeRoundtrip Reply    = Refl
messageTypeRoundtrip Thread   = Refl

---------------------------------------------------------------------------
-- PresenceStatus (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
presenceStatusSize : Nat
presenceStatusSize = 1

||| Encode PresenceStatus to its ABI tag value.
public export
presenceStatusToTag : PresenceStatus -> Bits8
presenceStatusToTag Online    = 0
presenceStatusToTag Away      = 1
presenceStatusToTag DND       = 2
presenceStatusToTag Invisible = 3
presenceStatusToTag Offline   = 4

public export
tagToPresenceStatus : Bits8 -> Maybe PresenceStatus
tagToPresenceStatus 0 = Just Online
tagToPresenceStatus 1 = Just Away
tagToPresenceStatus 2 = Just DND
tagToPresenceStatus 3 = Just Invisible
tagToPresenceStatus 4 = Just Offline
tagToPresenceStatus _ = Nothing

public export
presenceStatusRoundtrip : (p : PresenceStatus) -> tagToPresenceStatus (presenceStatusToTag p) = Just p
presenceStatusRoundtrip Online    = Refl
presenceStatusRoundtrip Away      = Refl
presenceStatusRoundtrip DND       = Refl
presenceStatusRoundtrip Invisible = Refl
presenceStatusRoundtrip Offline   = Refl

---------------------------------------------------------------------------
-- RoomType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
roomTypeSize : Nat
roomTypeSize = 1

||| Encode RoomType to its ABI tag value.
public export
roomTypeToTag : RoomType -> Bits8
roomTypeToTag Direct    = 0
roomTypeToTag Group     = 1
roomTypeToTag Channel   = 2
roomTypeToTag Broadcast = 3

public export
tagToRoomType : Bits8 -> Maybe RoomType
tagToRoomType 0 = Just Direct
tagToRoomType 1 = Just Group
tagToRoomType 2 = Just Channel
tagToRoomType 3 = Just Broadcast
tagToRoomType _ = Nothing

public export
roomTypeRoundtrip : (r : RoomType) -> tagToRoomType (roomTypeToTag r) = Just r
roomTypeRoundtrip Direct    = Refl
roomTypeRoundtrip Group     = Refl
roomTypeRoundtrip Channel   = Refl
roomTypeRoundtrip Broadcast = Refl

---------------------------------------------------------------------------
-- Permission (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
permissionSize : Nat
permissionSize = 1

||| Encode Permission to its ABI tag value.
public export
permissionToTag : Permission -> Bits8
permissionToTag Read         = 0
permissionToTag Write        = 1
permissionToTag Admin        = 2
permissionToTag Invite       = 3
permissionToTag Kick         = 4
permissionToTag Ban          = 5
permissionToTag Pin          = 6
permissionToTag DeleteOthers = 7

public export
tagToPermission : Bits8 -> Maybe Permission
tagToPermission 0 = Just Read
tagToPermission 1 = Just Write
tagToPermission 2 = Just Admin
tagToPermission 3 = Just Invite
tagToPermission 4 = Just Kick
tagToPermission 5 = Just Ban
tagToPermission 6 = Just Pin
tagToPermission 7 = Just DeleteOthers
tagToPermission _ = Nothing

public export
permissionRoundtrip : (p : Permission) -> tagToPermission (permissionToTag p) = Just p
permissionRoundtrip Read         = Refl
permissionRoundtrip Write        = Refl
permissionRoundtrip Admin        = Refl
permissionRoundtrip Invite       = Refl
permissionRoundtrip Kick         = Refl
permissionRoundtrip Ban          = Refl
permissionRoundtrip Pin          = Refl
permissionRoundtrip DeleteOthers = Refl

---------------------------------------------------------------------------
-- Event (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
eventSize : Nat
eventSize = 1

||| Encode Event to its ABI tag value.
public export
eventToTag : Event -> Bits8
eventToTag MessageSent      = 0
eventToTag MessageDelivered = 1
eventToTag MessageRead      = 2
eventToTag UserJoined       = 3
eventToTag UserLeft         = 4
eventToTag Typing           = 5
eventToTag RoomCreated      = 6

public export
tagToEvent : Bits8 -> Maybe Event
tagToEvent 0 = Just MessageSent
tagToEvent 1 = Just MessageDelivered
tagToEvent 2 = Just MessageRead
tagToEvent 3 = Just UserJoined
tagToEvent 4 = Just UserLeft
tagToEvent 5 = Just Typing
tagToEvent 6 = Just RoomCreated
tagToEvent _ = Nothing

public export
eventRoundtrip : (e : Event) -> tagToEvent (eventToTag e) = Just e
eventRoundtrip MessageSent      = Refl
eventRoundtrip MessageDelivered = Refl
eventRoundtrip MessageRead      = Refl
eventRoundtrip UserJoined       = Refl
eventRoundtrip UserLeft         = Refl
eventRoundtrip Typing           = Refl
eventRoundtrip RoomCreated      = Refl
