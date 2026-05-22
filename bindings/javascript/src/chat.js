// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Chat protocol types for proven-servers.

/** MessageType matching the Idris2 ABI tags. */
export const MessageType = Object.freeze({
  TEXT: 0,
  IMAGE: 1,
  FILE: 2,
  SYSTEM: 3,
  REACTION: 4,
  EDIT: 5,
  DELETE: 6,
  REPLY: 7,
  THREAD: 8,
});

/** PresenceStatus matching the Idris2 ABI tags. */
export const PresenceStatus = Object.freeze({
  ONLINE: 0,
  AWAY: 1,
  DND: 2,
  INVISIBLE: 3,
  OFFLINE: 4,
});

/** RoomType matching the Idris2 ABI tags. */
export const RoomType = Object.freeze({
  DIRECT: 0,
  GROUP: 1,
  CHANNEL: 2,
  BROADCAST: 3,
});

/** Permission matching the Idris2 ABI tags. */
export const Permission = Object.freeze({
  READ: 0,
  WRITE: 1,
  ADMIN: 2,
  INVITE: 3,
  KICK: 4,
  BAN: 5,
  PIN: 6,
  DELETE_OTHERS: 7,
});

/** Event matching the Idris2 ABI tags. */
export const Event = Object.freeze({
  MESSAGE_SENT: 0,
  MESSAGE_DELIVERED: 1,
  MESSAGE_READ: 2,
  USER_JOINED: 3,
  USER_LEFT: 4,
  TYPING: 5,
  ROOM_CREATED: 6,
});
