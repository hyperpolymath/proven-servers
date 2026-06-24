-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ChatABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into chat_abi_gen.zig for the comptime guard.

module ChatABI.Emit

import Chat.Types
import ChatABI.Types
import ChatABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "MSG" "TEXT"     (messageTypeToTag Text)
  , line "MSG" "IMAGE"    (messageTypeToTag Image)
  , line "MSG" "FILE"     (messageTypeToTag File)
  , line "MSG" "SYSTEM"   (messageTypeToTag System)
  , line "MSG" "REACTION" (messageTypeToTag Reaction)
  , line "MSG" "EDIT"     (messageTypeToTag Edit)
  , line "MSG" "DELETE"   (messageTypeToTag Delete)
  , line "MSG" "REPLY"    (messageTypeToTag Reply)
  , line "MSG" "THREAD"   (messageTypeToTag Thread)
  , line "PRESENCE" "ONLINE"    (presenceStatusToTag Online)
  , line "PRESENCE" "AWAY"      (presenceStatusToTag Away)
  , line "PRESENCE" "DND"       (presenceStatusToTag DND)
  , line "PRESENCE" "INVISIBLE" (presenceStatusToTag Invisible)
  , line "PRESENCE" "OFFLINE"   (presenceStatusToTag Offline)
  , line "ROOM" "DIRECT"    (roomTypeToTag Direct)
  , line "ROOM" "GROUP"     (roomTypeToTag Group)
  , line "ROOM" "CHANNEL"   (roomTypeToTag Channel)
  , line "ROOM" "BROADCAST" (roomTypeToTag Broadcast)
  , line "PERM" "READ"          (permissionToTag Read)
  , line "PERM" "WRITE"         (permissionToTag Write)
  , line "PERM" "ADMIN"         (permissionToTag Admin)
  , line "PERM" "INVITE"        (permissionToTag Invite)
  , line "PERM" "KICK"          (permissionToTag Kick)
  , line "PERM" "BAN"           (permissionToTag Ban)
  , line "PERM" "PIN"           (permissionToTag Pin)
  , line "PERM" "DELETE_OTHERS" (permissionToTag DeleteOthers)
  , line "EVENT" "MESSAGE_SENT"      (eventToTag MessageSent)
  , line "EVENT" "MESSAGE_DELIVERED" (eventToTag MessageDelivered)
  , line "EVENT" "MESSAGE_READ"      (eventToTag MessageRead)
  , line "EVENT" "USER_JOINED"       (eventToTag UserJoined)
  , line "EVENT" "USER_LEFT"         (eventToTag UserLeft)
  , line "EVENT" "TYPING"            (eventToTag Typing)
  , line "EVENT" "ROOM_CREATED"      (eventToTag RoomCreated)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
