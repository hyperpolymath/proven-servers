-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-httpd protocol (HTTP server).
--
-- Wraps the C-ABI functions from protocols/proven-httpd/ffi/zig/src/httpd.zig:
--   http_abi_version, http_create_context, http_destroy_context,
--   http_parse_request, http_get_method, http_get_path, http_get_header,
--   http_get_body, http_set_status, http_set_header, http_set_body,
--   http_send_response, http_keep_alive_check, http_get_phase,
--   http_get_version, http_reset_context, http_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Httpd is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- HTTP methods matching the Zig ABI tag values.
   type Http_Method is
     (Method_Get,
      Method_Head,
      Method_Post,
      Method_Put,
      Method_Delete,
      Method_Connect,
      Method_Options,
      Method_Trace,
      Method_Patch);
   for Http_Method use
     (Method_Get     => 0,
      Method_Head    => 1,
      Method_Post    => 2,
      Method_Put     => 3,
      Method_Delete  => 4,
      Method_Connect => 5,
      Method_Options => 6,
      Method_Trace   => 7,
      Method_Patch   => 8);
   pragma Convention (C, Http_Method);

   -- HTTP request lifecycle phases matching the Zig ABI.
   type Request_Phase is
     (Phase_Idle,
      Phase_Receiving,
      Phase_Headers_Parsed,
      Phase_Body_Receiving,
      Phase_Complete,
      Phase_Responding,
      Phase_Sent);
   for Request_Phase use
     (Phase_Idle           => 0,
      Phase_Receiving      => 1,
      Phase_Headers_Parsed => 2,
      Phase_Body_Receiving => 3,
      Phase_Complete       => 4,
      Phase_Responding     => 5,
      Phase_Sent           => 6);
   pragma Convention (C, Request_Phase);

   -- HTTP versions.
   type Http_Version is (Http_1_0, Http_1_1);
   for Http_Version use (Http_1_0 => 0, Http_1_1 => 1);
   pragma Convention (C, Http_Version);

   -- HTTP status code tags.
   type Status_Code is
     (Status_200_OK,
      Status_201_Created,
      Status_204_No_Content,
      Status_301_Moved,
      Status_302_Found,
      Status_304_Not_Modified,
      Status_400_Bad_Request,
      Status_401_Unauthorized,
      Status_403_Forbidden,
      Status_404_Not_Found,
      Status_405_Not_Allowed,
      Status_500_Internal,
      Status_502_Bad_Gateway,
      Status_503_Unavailable);
   pragma Convention (C, Status_Code);

   -- Parse result codes.
   type Parse_Result is (Parse_Complete, Parse_Rejected, Parse_Need_More);
   for Parse_Result use
     (Parse_Complete => 0, Parse_Rejected => 1, Parse_Need_More => 2);
   pragma Convention (C, Parse_Result);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "http_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "http_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "http_destroy_context");

   function Parse_Request
     (Slot : int;
      Data : access unsigned_char;
      Len  : unsigned) return unsigned_char;
   pragma Import (C, Parse_Request, "http_parse_request");

   function Get_Method (Slot : int) return unsigned_char;
   pragma Import (C, Get_Method, "http_get_method");

   function Get_Path
     (Slot : int;
      Buf  : access unsigned_char;
      Len  : unsigned) return unsigned;
   pragma Import (C, Get_Path, "http_get_path");

   function Get_Header
     (Slot : int;
      Key  : access unsigned_char;
      Klen : unsigned;
      Buf  : access unsigned_char;
      Blen : unsigned) return unsigned;
   pragma Import (C, Get_Header, "http_get_header");

   function Get_Body
     (Slot : int;
      Buf  : access unsigned_char;
      Len  : unsigned) return unsigned;
   pragma Import (C, Get_Body, "http_get_body");

   function Set_Status
     (Slot       : int;
      Status_Tag : unsigned_char) return unsigned_char;
   pragma Import (C, Set_Status, "http_set_status");

   function Set_Header
     (Slot : int;
      Key  : access unsigned_char;
      Klen : unsigned;
      Val  : access unsigned_char;
      Vlen : unsigned) return unsigned_char;
   pragma Import (C, Set_Header, "http_set_header");

   function Set_Body
     (Slot : int;
      Data : access unsigned_char;
      Len  : unsigned) return unsigned_char;
   pragma Import (C, Set_Body, "http_set_body");

   function Send_Response (Slot : int) return unsigned_char;
   pragma Import (C, Send_Response, "http_send_response");

   function Keep_Alive_Check (Slot : int) return unsigned_char;
   pragma Import (C, Keep_Alive_Check, "http_keep_alive_check");

   function Get_Phase (Slot : int) return unsigned_char;
   pragma Import (C, Get_Phase, "http_get_phase");

   function Get_Version (Slot : int) return unsigned_char;
   pragma Import (C, Get_Version, "http_get_version");

   function Reset_Context (Slot : int) return unsigned_char;
   pragma Import (C, Reset_Context, "http_reset_context");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "http_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers (raising on error)
   ---------------------------------------------------------------------------

   -- Create a new HTTP context. Raises on pool exhaustion.
   function Safe_Create_Context return Proven_Error.Slot_Id;

   -- Destroy a context, releasing its slot.
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

   -- Send the built response. Raises on invalid state.
   procedure Safe_Send_Response (Slot : Proven_Error.Slot_Id);

   -- Reset context for keep-alive reuse. Raises on invalid state.
   procedure Safe_Reset_Context (Slot : Proven_Error.Slot_Id);

   -- Check if keep-alive is active.
   function Is_Keep_Alive (Slot : Proven_Error.Slot_Id) return Boolean;

end Proven_Httpd;
