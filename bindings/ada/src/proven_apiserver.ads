-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-apiserver protocol (API gateway/server).
--
-- Wraps the C-ABI functions from protocols/proven-apiserver/ffi/zig/src/apiserver.zig:
--   apiserver_abi_version, apiserver_create_context, apiserver_destroy_context,
--   apiserver_state, apiserver_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Apiserver is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `AuthScheme` in `ApiserverABI.Types`.
   type Auth_Scheme is
     (Api_Key,
      Bearer,
      Basic,
      O_Auth2,
      Hmac,
      Mtls);
   pragma Convention (C, Auth_Scheme);

   -- Matches `RateLimitStrategy` in `ApiserverABI.Types`.
   type Rate_Limit_Strategy is
     (Fixed_Window,
      Sliding_Window,
      Token_Bucket,
      Leaky_Bucket);
   pragma Convention (C, Rate_Limit_Strategy);

   -- Matches `ApiVersion` in `ApiserverABI.Types`.
   type Api_Version is
     (V1,
      V2,
      V3,
      Latest,
      Deprecated);
   pragma Convention (C, Api_Version);

   -- Matches `ResponseFormat` in `ApiserverABI.Types`.
   type Response_Format is
     (Json,
      Xml,
      Protobuf,
      Message_Pack);
   pragma Convention (C, Response_Format);

   -- Matches `GatewayError` in `ApiserverABI.Types`.
   type Gateway_Error is
     (Unauthorized,
      Rate_Limited,
      Not_Found,
      Bad_Request,
      Service_Unavailable,
      Circuit_Open);
   pragma Convention (C, Gateway_Error);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "apiserver_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "apiserver_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "apiserver_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "apiserver_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "apiserver_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Apiserver;
