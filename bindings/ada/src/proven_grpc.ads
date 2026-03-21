-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-grpc protocol (gRPC server).
--
-- Wraps the C-ABI functions from protocols/proven-grpc/ffi/zig/src/grpc.zig.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Grpc is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- gRPC stream states (HTTP/2 stream lifecycle).
   type Stream_State is
     (Stream_Idle,
      Stream_Reserved_Local,
      Stream_Reserved_Remote,
      Stream_Open,
      Stream_Half_Closed_Local,
      Stream_Half_Closed_Remote,
      Stream_Closed);
   for Stream_State use
     (Stream_Idle                => 0,
      Stream_Reserved_Local      => 1,
      Stream_Reserved_Remote     => 2,
      Stream_Open                => 3,
      Stream_Half_Closed_Local   => 4,
      Stream_Half_Closed_Remote  => 5,
      Stream_Closed              => 6);
   pragma Convention (C, Stream_State);

   -- gRPC compression modes.
   type Compression is (Compress_None, Compress_Gzip, Compress_Deflate);
   for Compression use
     (Compress_None    => 0,
      Compress_Gzip    => 1,
      Compress_Deflate => 2);
   pragma Convention (C, Compression);

   -- gRPC status codes.
   type Status_Code is
     (Status_Ok,
      Status_Cancelled,
      Status_Unknown,
      Status_Invalid_Argument,
      Status_Deadline_Exceeded,
      Status_Not_Found,
      Status_Already_Exists,
      Status_Permission_Denied,
      Status_Resource_Exhausted,
      Status_Failed_Precondition,
      Status_Aborted,
      Status_Out_Of_Range,
      Status_Unimplemented,
      Status_Internal,
      Status_Unavailable,
      Status_Data_Loss,
      Status_Unauthenticated);
   for Status_Code use
     (Status_Ok                  => 0,
      Status_Cancelled           => 1,
      Status_Unknown             => 2,
      Status_Invalid_Argument    => 3,
      Status_Deadline_Exceeded   => 4,
      Status_Not_Found           => 5,
      Status_Already_Exists      => 6,
      Status_Permission_Denied   => 7,
      Status_Resource_Exhausted  => 8,
      Status_Failed_Precondition => 9,
      Status_Aborted             => 10,
      Status_Out_Of_Range        => 11,
      Status_Unimplemented       => 12,
      Status_Internal            => 13,
      Status_Unavailable         => 14,
      Status_Data_Loss           => 15,
      Status_Unauthenticated     => 16);
   pragma Convention (C, Status_Code);

   ---------------------------------------------------------------------------
   -- Raw FFI imports
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "grpc_abi_version");

   function Create (Compress : unsigned_char) return int;
   pragma Import (C, Create, "grpc_create");

   procedure Destroy (Slot : int);
   pragma Import (C, Destroy, "grpc_destroy");

   function Get_Stream_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_Stream_State, "grpc_stream_state");

   function Get_Compression (Slot : int) return unsigned_char;
   pragma Import (C, Get_Compression, "grpc_compression");

   function Get_Status_Code (Slot : int) return unsigned_char;
   pragma Import (C, Get_Status_Code, "grpc_status_code");

   function Set_Status
     (Slot   : int;
      Status : unsigned_char) return unsigned_char;
   pragma Import (C, Set_Status, "grpc_set_status");

   function Get_Stream_Id (Slot : int) return unsigned;
   pragma Import (C, Get_Stream_Id, "grpc_stream_id");

   function Send_Headers (Slot : int) return unsigned_char;
   pragma Import (C, Send_Headers, "grpc_send_headers");

   function Local_End_Stream (Slot : int) return unsigned_char;
   pragma Import (C, Local_End_Stream, "grpc_local_end_stream");

   function Remote_End_Stream (Slot : int) return unsigned_char;
   pragma Import (C, Remote_End_Stream, "grpc_remote_end_stream");

   function Reset_Stream
     (Slot   : int;
      Status : unsigned_char) return unsigned_char;
   pragma Import (C, Reset_Stream, "grpc_reset_stream");

   function Close_Half_Local (Slot : int) return unsigned_char;
   pragma Import (C, Close_Half_Local, "grpc_close_half_local");

   function Close_Half_Remote (Slot : int) return unsigned_char;
   pragma Import (C, Close_Half_Remote, "grpc_close_half_remote");

   function Push_Promise (Slot : int) return unsigned_char;
   pragma Import (C, Push_Promise, "grpc_push_promise");

   function Reserved_To_Half (Slot : int) return unsigned_char;
   pragma Import (C, Reserved_To_Half, "grpc_reserved_to_half");

   function Can_Send (Slot : int) return unsigned_char;
   pragma Import (C, Can_Send, "grpc_can_send");

   function Can_Receive (Slot : int) return unsigned_char;
   pragma Import (C, Can_Receive, "grpc_can_receive");

   function Send_Window (Slot : int) return int;
   pragma Import (C, Send_Window, "grpc_send_window");

   function Recv_Window (Slot : int) return int;
   pragma Import (C, Recv_Window, "grpc_recv_window");

   function Update_Send_Window
     (Slot  : int;
      Delta : int) return unsigned_char;
   pragma Import (C, Update_Send_Window, "grpc_update_send_window");

   function Update_Recv_Window
     (Slot  : int;
      Delta : int) return unsigned_char;
   pragma Import (C, Update_Recv_Window, "grpc_update_recv_window");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "grpc_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create
     (Compress : Compression) return Proven_Error.Slot_Id;
   procedure Safe_Destroy (Slot : Proven_Error.Slot_Id);
   procedure Safe_Send_Headers (Slot : Proven_Error.Slot_Id);

end Proven_Grpc;
