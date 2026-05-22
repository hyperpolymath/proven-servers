//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// VoIP/SIP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `VoipABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// VoIP/SIP Constants
// ===========================================================================

/// Sip Port constant.
pub const sip_port = 5060

/// Sips Port constant.
pub const sips_port = 5061

// ===========================================================================
// Method
// ===========================================================================

/// SIP request methods (RFC 3261 and extensions).
/// 
/// Matches `Method` in `VoIPABI.Types`.
pub type Method {
  /// INVITE — initiate a session (tag 0).
  Invite
  /// ACK — confirm INVITE reception (tag 1).
  Ack
  /// BYE — terminate a session (tag 2).
  Bye
  /// CANCEL — cancel a pending request (tag 3).
  Cancel
  /// REGISTER — register contact URI (tag 4).
  Register
  /// OPTIONS — query capabilities (tag 5).
  Options
  /// INFO — send mid-session information (tag 6).
  Info
  /// UPDATE — modify session parameters (tag 7).
  Update
  /// SUBSCRIBE — request event notification (tag 8).
  Subscribe
  /// NOTIFY — deliver event notification (tag 9).
  Notify
  /// REFER — ask recipient to issue a request (tag 10).
  Refer
  /// MESSAGE — instant messaging (tag 11).
  Message
  /// PRACK — provisional response acknowledgement (tag 12).
  Prack
}

/// Convert a `Method` to its C-ABI tag value.
pub fn method_to_int(value: Method) -> Int {
  case value {
    Invite -> 0
    Ack -> 1
    Bye -> 2
    Cancel -> 3
    Register -> 4
    Options -> 5
    Info -> 6
    Update -> 7
    Subscribe -> 8
    Notify -> 9
    Refer -> 10
    Message -> 11
    Prack -> 12
  }
}

/// Decode from a C-ABI tag value.
pub fn method_from_int(tag: Int) -> Result(Method, Nil) {
  case tag {
    0 -> Ok(Invite)
    1 -> Ok(Ack)
    2 -> Ok(Bye)
    3 -> Ok(Cancel)
    4 -> Ok(Register)
    5 -> Ok(Options)
    6 -> Ok(Info)
    7 -> Ok(Update)
    8 -> Ok(Subscribe)
    9 -> Ok(Notify)
    10 -> Ok(Refer)
    11 -> Ok(Message)
    12 -> Ok(Prack)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ResponseCode
// ===========================================================================

/// SIP response codes (RFC 3261).
/// 
/// Matches `ResponseCode` in `VoIPABI.Types`.
pub type ResponseCode {
  /// 100 Trying (tag 0).
  Trying
  /// 180 Ringing (tag 1).
  Ringing
  /// 183 Session Progress (tag 2).
  SessionProgress
  /// 200 OK (tag 3).
  ResponseCodeOk
  /// 300 Multiple Choices (tag 4).
  MultipleChoices
  /// 301 Moved Permanently (tag 5).
  MovedPermanently
  /// 302 Moved Temporarily (tag 6).
  MovedTemporarily
  /// 400 Bad Request (tag 7).
  BadRequest
  /// 401 Unauthorized (tag 8).
  Unauthorized
  /// 403 Forbidden (tag 9).
  Forbidden
  /// 404 Not Found (tag 10).
  NotFound
  /// 405 Method Not Allowed (tag 11).
  MethodNotAllowed
  /// 408 Request Timeout (tag 12).
  RequestTimeout
  /// 486 Busy Here (tag 13).
  BusyHere
  /// 603 Decline (tag 14).
  Decline
  /// 500 Server Internal Error (tag 15).
  ServerInternalError
  /// 503 Service Unavailable (tag 16).
  ServiceUnavailable
}

/// Convert a `ResponseCode` to its C-ABI tag value.
pub fn response_code_to_int(value: ResponseCode) -> Int {
  case value {
    Trying -> 0
    Ringing -> 1
    SessionProgress -> 2
    ResponseCodeOk -> 3
    MultipleChoices -> 4
    MovedPermanently -> 5
    MovedTemporarily -> 6
    BadRequest -> 7
    Unauthorized -> 8
    Forbidden -> 9
    NotFound -> 10
    MethodNotAllowed -> 11
    RequestTimeout -> 12
    BusyHere -> 13
    Decline -> 14
    ServerInternalError -> 15
    ServiceUnavailable -> 16
  }
}

/// Decode from a C-ABI tag value.
pub fn response_code_from_int(tag: Int) -> Result(ResponseCode, Nil) {
  case tag {
    0 -> Ok(Trying)
    1 -> Ok(Ringing)
    2 -> Ok(SessionProgress)
    3 -> Ok(ResponseCodeOk)
    4 -> Ok(MultipleChoices)
    5 -> Ok(MovedPermanently)
    6 -> Ok(MovedTemporarily)
    7 -> Ok(BadRequest)
    8 -> Ok(Unauthorized)
    9 -> Ok(Forbidden)
    10 -> Ok(NotFound)
    11 -> Ok(MethodNotAllowed)
    12 -> Ok(RequestTimeout)
    13 -> Ok(BusyHere)
    14 -> Ok(Decline)
    15 -> Ok(ServerInternalError)
    16 -> Ok(ServiceUnavailable)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DialogState
// ===========================================================================

/// SIP dialog state machine (RFC 3261 Section 12).
/// 
/// Matches `DialogState` in `VoIPABI.Types`.
pub type DialogState {
  /// Early dialog — provisional response received (tag 0).
  Early
  /// Confirmed dialog — final 2xx response received (tag 1).
  Confirmed
  /// Terminated — BYE sent or received (tag 2).
  Terminated
}

/// Convert a `DialogState` to its C-ABI tag value.
pub fn dialog_state_to_int(value: DialogState) -> Int {
  case value {
    Early -> 0
    Confirmed -> 1
    Terminated -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn dialog_state_from_int(tag: Int) -> Result(DialogState, Nil) {
  case tag {
    0 -> Ok(Early)
    1 -> Ok(Confirmed)
    2 -> Ok(Terminated)
    _ -> Error(Nil)
  }
}

