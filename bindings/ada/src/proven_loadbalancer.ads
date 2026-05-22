-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-load balancer protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Loadbalancer is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Load balancing algorithms (tags 0-5).
   type Lb_Algorithm is
     (Algo_Round_Robin, Algo_Least_Connections, Algo_Ip_Hash,
      Algo_Random, Algo_Weighted_Round_Robin, Algo_Least_Response_Time);
   for Lb_Algorithm use
     (Algo_Round_Robin => 0, Algo_Least_Connections => 1,
      Algo_Ip_Hash => 2, Algo_Random => 3,
      Algo_Weighted_Round_Robin => 4, Algo_Least_Response_Time => 5);
   pragma Convention (C, Lb_Algorithm);

   -- Health check types (tags 0-3).
   type Health_Check_Type is (Hc_Http, Hc_Tcp, Hc_Grpc, Hc_Script);
   for Health_Check_Type use
     (Hc_Http => 0, Hc_Tcp => 1, Hc_Grpc => 2, Hc_Script => 3);
   pragma Convention (C, Health_Check_Type);

   -- Backend server states (tags 0-3).
   type Backend_State is
     (Bs_Healthy, Bs_Unhealthy, Bs_Draining, Bs_Disabled);
   for Backend_State use
     (Bs_Healthy => 0, Bs_Unhealthy => 1, Bs_Draining => 2, Bs_Disabled => 3);
   pragma Convention (C, Backend_State);

   -- Session persistence strategies (tags 0-3).
   type Session_Persistence is
     (Sp_None, Sp_Cookie, Sp_Source_Ip, Sp_Header);
   for Session_Persistence use
     (Sp_None => 0, Sp_Cookie => 1, Sp_Source_Ip => 2, Sp_Header => 3);
   pragma Convention (C, Session_Persistence);

   -- Load balancer protocols (tags 0-4).
   type Lb_Protocol is
     (Lbp_Http, Lbp_Https, Lbp_Tcp, Lbp_Udp, Lbp_Grpc);
   for Lb_Protocol use
     (Lbp_Http => 0, Lbp_Https => 1, Lbp_Tcp => 2,
      Lbp_Udp => 3, Lbp_Grpc => 4);
   pragma Convention (C, Lb_Protocol);


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "loadbalancer_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "loadbalancer_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "loadbalancer_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "loadbalancer_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "loadbalancer_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Loadbalancer;
