// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VoIP (Voice over IP / SIP) types for the proven-servers ABI.
//
// Mirrors the Idris2 module VoIPABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard SIP port (RFC 3261).
let sipPort = 5060

/// Standard SIP over TLS (SIPS) port (RFC 3261).
let sipsPort = 5061

// ===========================================================================
// Method (tags 0-12)
// ===========================================================================

/// Standard SIP port (RFC 3261).
type method =
  | @as(0) Invite
  | @as(1) Ack
  | @as(2) Bye
  | @as(3) Cancel
  | @as(4) Register
  | @as(5) Options
  | @as(6) Info
  | @as(7) Update
  | @as(8) Subscribe
  | @as(9) Notify
  | @as(10) Refer
  | @as(11) Message
  | @as(12) Prack

/// Decode from the C-ABI tag value.
let methodFromTag = (tag: int): option<method> =>
  switch tag {
  | 0 => Some(Invite)
  | 1 => Some(Ack)
  | 2 => Some(Bye)
  | 3 => Some(Cancel)
  | 4 => Some(Register)
  | 5 => Some(Options)
  | 6 => Some(Info)
  | 7 => Some(Update)
  | 8 => Some(Subscribe)
  | 9 => Some(Notify)
  | 10 => Some(Refer)
  | 11 => Some(Message)
  | 12 => Some(Prack)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let methodToTag = (v: method): int =>
  switch v {
  | Invite => 0
  | Ack => 1
  | Bye => 2
  | Cancel => 3
  | Register => 4
  | Options => 5
  | Info => 6
  | Update => 7
  | Subscribe => 8
  | Notify => 9
  | Refer => 10
  | Message => 11
  | Prack => 12
  }

/// Whether this method creates or modifies a dialog.
let methodIsDialogCreating = (v: method): bool =>
  switch v {
  | Invite | Subscribe => true
  | _ => false
  }

/// Whether this method is related to session management.
let methodIsSessionRelated = (v: method): bool =>
  switch v {
  | Invite | Ack | Bye | Cancel | Update | Prack => true
  | _ => false
  }

/// Whether this method is related to event notification.
let methodIsEventRelated = (v: method): bool =>
  switch v {
  | Subscribe | Notify => true
  | _ => false
  }

// ===========================================================================
// ResponseCode (tags 0-16)
// ===========================================================================

/// Decode from an ABI tag value.
type responseCode =
  | @as(0) Trying
  | @as(1) Ringing
  | @as(2) SessionProgress
  | @as(3) Ok
  | @as(4) MultipleChoices
  | @as(5) MovedPermanently
  | @as(6) MovedTemporarily
  | @as(7) BadRequest
  | @as(8) Unauthorized
  | @as(9) Forbidden
  | @as(10) NotFound
  | @as(11) MethodNotAllowed
  | @as(12) RequestTimeout
  | @as(13) BusyHere
  | @as(14) Decline
  | @as(15) ServerInternalError
  | @as(16) ServiceUnavailable

/// Decode from the C-ABI tag value.
let responseCodeFromTag = (tag: int): option<responseCode> =>
  switch tag {
  | 0 => Some(Trying)
  | 1 => Some(Ringing)
  | 2 => Some(SessionProgress)
  | 3 => Some(Ok)
  | 4 => Some(MultipleChoices)
  | 5 => Some(MovedPermanently)
  | 6 => Some(MovedTemporarily)
  | 7 => Some(BadRequest)
  | 8 => Some(Unauthorized)
  | 9 => Some(Forbidden)
  | 10 => Some(NotFound)
  | 11 => Some(MethodNotAllowed)
  | 12 => Some(RequestTimeout)
  | 13 => Some(BusyHere)
  | 14 => Some(Decline)
  | 15 => Some(ServerInternalError)
  | 16 => Some(ServiceUnavailable)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let responseCodeToTag = (v: responseCode): int =>
  switch v {
  | Trying => 0
  | Ringing => 1
  | SessionProgress => 2
  | Ok => 3
  | MultipleChoices => 4
  | MovedPermanently => 5
  | MovedTemporarily => 6
  | BadRequest => 7
  | Unauthorized => 8
  | Forbidden => 9
  | NotFound => 10
  | MethodNotAllowed => 11
  | RequestTimeout => 12
  | BusyHere => 13
  | Decline => 14
  | ServerInternalError => 15
  | ServiceUnavailable => 16
  }

/// Whether this is a provisional (1xx) response.
let responseCodeIsProvisional = (v: responseCode): bool =>
  switch v {
  | Trying | Ringing | SessionProgress => true
  | _ => false
  }

/// Whether this is a success (2xx) response.
let responseCodeIsSuccess = (v: responseCode): bool =>
  switch v {
  | Ok => true
  | _ => false
  }

/// Whether this is a redirection (3xx) response.
let responseCodeIsRedirect = (v: responseCode): bool =>
  switch v {
  | MultipleChoices | MovedPermanently | MovedTemporarily => true
  | _ => false
  }

/// Whether this is a client error (4xx) response.
let responseCodeIsClientError = (v: responseCode): bool =>
  switch v {
  | BadRequest | Unauthorized | Forbidden | NotFound | MethodNotAllowed | RequestTimeout | BusyHere => true
  | _ => false
  }

/// Whether this is a server error (5xx) response.
let responseCodeIsServerError = (v: responseCode): bool =>
  switch v {
  | ServerInternalError | ServiceUnavailable => true
  | _ => false
  }

/// Whether this is a global failure (6xx) response.
let responseCodeIsGlobalFailure = (v: responseCode): bool =>
  switch v {
  | Decline => true
  | _ => false
  }

// ===========================================================================
// DialogState (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type dialogState =
  | @as(0) Early
  | @as(1) Confirmed
  | @as(2) Terminated

/// Decode from the C-ABI tag value.
let dialogStateFromTag = (tag: int): option<dialogState> =>
  switch tag {
  | 0 => Some(Early)
  | 1 => Some(Confirmed)
  | 2 => Some(Terminated)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let dialogStateToTag = (v: dialogState): int =>
  switch v {
  | Early => 0
  | Confirmed => 1
  | Terminated => 2
  }

/// Whether media can flow in this state.
let dialogStateCanCarryMedia = (v: dialogState): bool =>
  switch v {
  | Early | Confirmed => true
  | _ => false
  }

/// Whether the dialog is active (not terminated).
let dialogStateIsActive = (v: dialogState): bool =>
  switch v {
  | Terminated => false
  | _ => true
  }

