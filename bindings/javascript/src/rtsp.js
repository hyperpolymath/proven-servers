// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RTSP protocol types for proven-servers.

/** Method matching the Idris2 ABI tags. */
export const Method = Object.freeze({
  DESCRIBE: 0,
  SETUP: 1,
  PLAY: 2,
  PAUSE: 3,
  TEARDOWN: 4,
  GET_PARAMETER: 5,
  SET_PARAMETER: 6,
  OPTIONS: 7,
  ANNOUNCE: 8,
  RECORD: 9,
  REDIRECT: 10,
});

/** TransportProtocol matching the Idris2 ABI tags. */
export const TransportProtocol = Object.freeze({
  RTP_AVP_UDP: 0,
  RTP_AVP_TCP: 1,
  RTP_AVP_UDP_MULTICAST: 2,
});

/** SessionState matching the Idris2 ABI tags. */
export const SessionState = Object.freeze({
  INIT: 0,
  READY: 1,
  PLAYING: 2,
  RECORDING: 3,
});

/** StatusCode matching the Idris2 ABI tags. */
export const StatusCode = Object.freeze({
  STATUS_CODE_OK: 0,
  MOVED_PERMANENTLY: 1,
  MOVED_TEMPORARILY: 2,
  BAD_REQUEST: 3,
  UNAUTHORIZED: 4,
  NOT_FOUND: 5,
  STATUS_CODE_METHOD_NOT_ALLOWED: 6,
  NOT_ACCEPTABLE: 7,
  SESSION_NOT_FOUND: 8,
  INTERNAL_SERVER_ERROR: 9,
  NOT_IMPLEMENTED: 10,
  SERVICE_UNAVAILABLE: 11,
});

/** RtspError matching the Idris2 ABI tags. */
export const RtspError = Object.freeze({
  RTSP_ERROR_OK: 0,
  INVALID_SLOT: 1,
  NOT_ACTIVE: 2,
  INVALID_TRANSITION: 3,
  RTSP_ERROR_METHOD_NOT_ALLOWED: 4,
  TRANSPORT_ERROR: 5,
  SESSION_EXPIRED: 6,
});
