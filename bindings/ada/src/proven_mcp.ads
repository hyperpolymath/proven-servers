-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-model context protocol protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Mcp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- MCP message types (tags 0-13).
   type Mcp_Message_Type is
     (Msg_Initialize, Msg_Initialized, Msg_Ping, Msg_Call_Tool,
      Msg_Tool_Result, Msg_List_Tools, Msg_List_Resources,
      Msg_Read_Resource, Msg_List_Prompts, Msg_Get_Prompt,
      Msg_Subscribe, Msg_Unsubscribe, Msg_Notification, Msg_Cancel);
   for Mcp_Message_Type use
     (Msg_Initialize => 0, Msg_Initialized => 1, Msg_Ping => 2,
      Msg_Call_Tool => 3, Msg_Tool_Result => 4, Msg_List_Tools => 5,
      Msg_List_Resources => 6, Msg_Read_Resource => 7,
      Msg_List_Prompts => 8, Msg_Get_Prompt => 9, Msg_Subscribe => 10,
      Msg_Unsubscribe => 11, Msg_Notification => 12, Msg_Cancel => 13);
   pragma Convention (C, Mcp_Message_Type);

   -- MCP transport types (tags 0-3).
   type Mcp_Transport is
     (Trans_Stdio, Trans_Sse, Trans_Web_Socket, Trans_Streamable_Http);
   for Mcp_Transport use
     (Trans_Stdio => 0, Trans_Sse => 1, Trans_Web_Socket => 2,
      Trans_Streamable_Http => 3);
   pragma Convention (C, Mcp_Transport);

   -- MCP content types (tags 0-3).
   type Mcp_Content_Type is
     (Ct_Text, Ct_Image, Ct_Resource, Ct_Embedding);
   for Mcp_Content_Type use
     (Ct_Text => 0, Ct_Image => 1, Ct_Resource => 2, Ct_Embedding => 3);
   pragma Convention (C, Mcp_Content_Type);

   -- MCP error codes (tags 0-5).
   type Mcp_Error_Code is
     (Ec_Parse_Error, Ec_Invalid_Request, Ec_Method_Not_Found,
      Ec_Invalid_Params, Ec_Internal_Error, Ec_Timeout);
   for Mcp_Error_Code use
     (Ec_Parse_Error => 0, Ec_Invalid_Request => 1,
      Ec_Method_Not_Found => 2, Ec_Invalid_Params => 3,
      Ec_Internal_Error => 4, Ec_Timeout => 5);
   pragma Convention (C, Mcp_Error_Code);

   -- MCP server capabilities (tags 0-4).
   type Mcp_Capability is
     (Cap_Tools, Cap_Resources, Cap_Prompts, Cap_Logging, Cap_Sampling);
   for Mcp_Capability use
     (Cap_Tools => 0, Cap_Resources => 1, Cap_Prompts => 2,
      Cap_Logging => 3, Cap_Sampling => 4);
   pragma Convention (C, Mcp_Capability);

   -- MCP session states (tags 0-4).
   type Session_State is
     (State_Idle, State_Connecting, State_Ready,
      State_Processing, State_Disconnecting);
   for Session_State use
     (State_Idle => 0, State_Connecting => 1, State_Ready => 2,
      State_Processing => 3, State_Disconnecting => 4);
   pragma Convention (C, Session_State);


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "mcp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "mcp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "mcp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "mcp_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "mcp_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Mcp;
