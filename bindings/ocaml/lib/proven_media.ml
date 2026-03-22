(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Media streaming server protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-media/ffi/zig/src/media.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for content types, codecs, stream
    protocols, transcode profiles, player events, and player states. *)

(** Media content types matching [MediaContentType] in media.zig. *)
type media_content_type =
  | Audio | Video | LiveStream | Playlist | Subtitle

(** Codecs matching [Codec] in media.zig. *)
type codec =
  | H264 | H265 | Av1 | Vp9 | Aac | Opus | Flac | Mp3

(** Stream protocols matching [StreamProtocol] in media.zig. *)
type stream_protocol =
  | Hls | Dash | Rtmp | Rtsp | WebRtc | Srt

(** Transcode profiles matching [TranscodeProfile] in media.zig. *)
type transcode_profile =
  | Passthrough | Low | Medium | High | Ultra

(** Player events matching [PlayerEvent] in media.zig. *)
type player_event =
  | Play | Pause | Seek | Stop | BufferStart | BufferEnd
  | Error | QualityChange

(** Player states matching [PlayerState] in media.zig. *)
type player_state =
  | Idle | Ready | Playing | Paused | Stopping

(** Convert a content type to its ABI tag value. *)
let media_content_type_to_tag = function
  | Audio -> 0 | Video -> 1 | LiveStream -> 2 | Playlist -> 3 | Subtitle -> 4

(** Decode a content type from its ABI tag value. *)
let media_content_type_of_tag = function
  | 0 -> Some Audio | 1 -> Some Video | 2 -> Some LiveStream
  | 3 -> Some Playlist | 4 -> Some Subtitle | _ -> None

(** Convert a codec to its ABI tag value. *)
let codec_to_tag = function
  | H264 -> 0 | H265 -> 1 | Av1 -> 2 | Vp9 -> 3 | Aac -> 4
  | Opus -> 5 | Flac -> 6 | Mp3 -> 7

(** Decode a codec from its ABI tag value. *)
let codec_of_tag = function
  | 0 -> Some H264 | 1 -> Some H265 | 2 -> Some Av1 | 3 -> Some Vp9
  | 4 -> Some Aac | 5 -> Some Opus | 6 -> Some Flac | 7 -> Some Mp3
  | _ -> None

(** Convert a stream protocol to its ABI tag value. *)
let stream_protocol_to_tag = function
  | Hls -> 0 | Dash -> 1 | Rtmp -> 2 | Rtsp -> 3 | WebRtc -> 4 | Srt -> 5

(** Decode a stream protocol from its ABI tag value. *)
let stream_protocol_of_tag = function
  | 0 -> Some Hls | 1 -> Some Dash | 2 -> Some Rtmp | 3 -> Some Rtsp
  | 4 -> Some WebRtc | 5 -> Some Srt | _ -> None

(** Convert a transcode profile to its ABI tag value. *)
let transcode_profile_to_tag = function
  | Passthrough -> 0 | Low -> 1 | Medium -> 2 | High -> 3 | Ultra -> 4

(** Decode a transcode profile from its ABI tag value. *)
let transcode_profile_of_tag = function
  | 0 -> Some Passthrough | 1 -> Some Low | 2 -> Some Medium
  | 3 -> Some High | 4 -> Some Ultra | _ -> None

(** Convert a player event to its ABI tag value. *)
let player_event_to_tag = function
  | Play -> 0 | Pause -> 1 | Seek -> 2 | Stop -> 3 | BufferStart -> 4
  | BufferEnd -> 5 | Error -> 6 | QualityChange -> 7

(** Decode a player event from its ABI tag value. *)
let player_event_of_tag = function
  | 0 -> Some Play | 1 -> Some Pause | 2 -> Some Seek | 3 -> Some Stop
  | 4 -> Some BufferStart | 5 -> Some BufferEnd | 6 -> Some Error
  | 7 -> Some QualityChange | _ -> None

(** Convert a player state to its ABI tag value. *)
let player_state_to_tag = function
  | Idle -> 0 | Ready -> 1 | Playing -> 2 | Paused -> 3 | Stopping -> 4

(** Decode a player state from its ABI tag value. *)
let player_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Ready | 2 -> Some Playing
  | 3 -> Some Paused | 4 -> Some Stopping | _ -> None

(* --- C FFI declarations --- *)

external c_media_abi_version : unit -> int = "media_abi_version"
external c_media_create_context : unit -> int = "media_create_context"
external c_media_destroy_context : int -> unit = "media_destroy_context"
external c_media_can_transition : int -> int -> int = "media_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_media]. *)
let abi_version () = c_media_abi_version ()

(** Create a new media context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_media_create_context ())

(** Destroy a media context, releasing its slot. *)
let destroy_context slot = c_media_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_media_can_transition (player_state_to_tag from) (player_state_to_tag to_) = 1
