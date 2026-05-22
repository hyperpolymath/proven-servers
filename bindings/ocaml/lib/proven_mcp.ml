(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Model Context Protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-mcp/ffi/zig/src/mcp.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for MCP message types, transports, content
    types, error codes, capabilities, and session states. *)

(** MCP message types matching [McpMessageType] in mcp.zig. *)
type mcp_message_type =
  | Initialize | Initialized | Ping | CallTool | ToolResult | ListTools
  | ListResources | ReadResource | ListPrompts | GetPrompt | Subscribe
  | Unsubscribe | Notification | Cancel

(** Transport types matching [Transport] in mcp.zig. *)
type transport =
  | Stdio | Sse | WebSocket | StreamableHttp

(** MCP content types matching [McpContentType] in mcp.zig. *)
type mcp_content_type =
  | Text | Image | Resource | Embedding

(** MCP error codes matching [McpErrorCode] in mcp.zig. *)
type mcp_error_code =
  | ParseError | InvalidRequest | MethodNotFound | InvalidParams
  | InternalError | Timeout

(** MCP capabilities matching [McpCapability] in mcp.zig. *)
type mcp_capability =
  | Tools | Resources | Prompts | Logging | Sampling

(** Session states matching [SessionState] in mcp.zig. *)
type session_state =
  | Idle | Connecting | Ready | Processing | Disconnecting

(** Convert a message type to its ABI tag value. *)
let mcp_message_type_to_tag = function
  | Initialize -> 0 | Initialized -> 1 | Ping -> 2 | CallTool -> 3
  | ToolResult -> 4 | ListTools -> 5 | ListResources -> 6
  | ReadResource -> 7 | ListPrompts -> 8 | GetPrompt -> 9
  | Subscribe -> 10 | Unsubscribe -> 11 | Notification -> 12 | Cancel -> 13

(** Decode a message type from its ABI tag value. *)
let mcp_message_type_of_tag = function
  | 0 -> Some Initialize | 1 -> Some Initialized | 2 -> Some Ping
  | 3 -> Some CallTool | 4 -> Some ToolResult | 5 -> Some ListTools
  | 6 -> Some ListResources | 7 -> Some ReadResource
  | 8 -> Some ListPrompts | 9 -> Some GetPrompt | 10 -> Some Subscribe
  | 11 -> Some Unsubscribe | 12 -> Some Notification | 13 -> Some Cancel
  | _ -> None

(** Convert a transport to its ABI tag value. *)
let transport_to_tag = function
  | Stdio -> 0 | Sse -> 1 | WebSocket -> 2 | StreamableHttp -> 3

(** Decode a transport from its ABI tag value. *)
let transport_of_tag = function
  | 0 -> Some Stdio | 1 -> Some Sse | 2 -> Some WebSocket
  | 3 -> Some StreamableHttp | _ -> None

(** Convert an MCP content type to its ABI tag value. *)
let mcp_content_type_to_tag = function
  | Text -> 0 | Image -> 1 | Resource -> 2 | Embedding -> 3

(** Decode an MCP content type from its ABI tag value. *)
let mcp_content_type_of_tag = function
  | 0 -> Some Text | 1 -> Some Image | 2 -> Some Resource
  | 3 -> Some Embedding | _ -> None

(** Convert an MCP error code to its ABI tag value. *)
let mcp_error_code_to_tag = function
  | ParseError -> 0 | InvalidRequest -> 1 | MethodNotFound -> 2
  | InvalidParams -> 3 | InternalError -> 4 | Timeout -> 5

(** Decode an MCP error code from its ABI tag value. *)
let mcp_error_code_of_tag = function
  | 0 -> Some ParseError | 1 -> Some InvalidRequest
  | 2 -> Some MethodNotFound | 3 -> Some InvalidParams
  | 4 -> Some InternalError | 5 -> Some Timeout | _ -> None

(** Convert an MCP capability to its ABI tag value. *)
let mcp_capability_to_tag = function
  | Tools -> 0 | Resources -> 1 | Prompts -> 2 | Logging -> 3 | Sampling -> 4

(** Decode an MCP capability from its ABI tag value. *)
let mcp_capability_of_tag = function
  | 0 -> Some Tools | 1 -> Some Resources | 2 -> Some Prompts
  | 3 -> Some Logging | 4 -> Some Sampling | _ -> None

(** Convert a session state to its ABI tag value. *)
let session_state_to_tag = function
  | Idle -> 0 | Connecting -> 1 | Ready -> 2 | Processing -> 3
  | Disconnecting -> 4

(** Decode a session state from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Connecting | 2 -> Some Ready
  | 3 -> Some Processing | 4 -> Some Disconnecting | _ -> None

(* --- C FFI declarations --- *)

external c_mcp_abi_version : unit -> int = "mcp_abi_version"
external c_mcp_create_context : unit -> int = "mcp_create_context"
external c_mcp_destroy_context : int -> unit = "mcp_destroy_context"
external c_mcp_can_transition : int -> int -> int = "mcp_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_mcp]. *)
let abi_version () = c_mcp_abi_version ()

(** Create a new MCP context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_mcp_create_context ())

(** Destroy an MCP context, releasing its slot. *)
let destroy_context slot = c_mcp_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_mcp_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
