-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-proxy protocol (Reverse Proxy).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Proxy is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Proxy operating modes (tags 0-1).
   type Proxy_Mode is (Mode_Forward, Mode_Reverse);
   for Proxy_Mode use (Mode_Forward => 0, Mode_Reverse => 1);
   pragma Convention (C, Proxy_Mode);

   -- HTTP hop-by-hop headers (tags 0-7).
   type Hop_By_Hop_Header is
     (Hdr_Connection, Hdr_Keep_Alive, Hdr_Proxy_Auth, Hdr_Proxy_Authz,
      Hdr_Te, Hdr_Trailers, Hdr_Transfer_Encoding, Hdr_Upgrade);
   for Hop_By_Hop_Header use
     (Hdr_Connection        => 0, Hdr_Keep_Alive         => 1,
      Hdr_Proxy_Auth        => 2, Hdr_Proxy_Authz        => 3,
      Hdr_Te                => 4, Hdr_Trailers           => 5,
      Hdr_Transfer_Encoding => 6, Hdr_Upgrade            => 7);
   pragma Convention (C, Hop_By_Hop_Header);

   -- Cache directives (tags 0-5).
   type Cache_Directive is
     (Cache_No_Cache, Cache_No_Store, Cache_Max_Age,
      Cache_Public, Cache_Private, Cache_Must_Revalidate);
   for Cache_Directive use
     (Cache_No_Cache        => 0, Cache_No_Store   => 1,
      Cache_Max_Age         => 2, Cache_Public     => 3,
      Cache_Private         => 4, Cache_Must_Revalidate => 5);
   pragma Convention (C, Cache_Directive);

   -- Proxy error codes (tags 0-3).
   type Proxy_Error is
     (Err_Bad_Gateway, Err_Gateway_Timeout,
      Err_Upstream_Refused, Err_Upstream_Tls);
   for Proxy_Error use
     (Err_Bad_Gateway      => 0, Err_Gateway_Timeout  => 1,
      Err_Upstream_Refused => 2, Err_Upstream_Tls     => 3);
   pragma Convention (C, Proxy_Error);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "proxy_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "proxy_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "proxy_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "proxy_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "proxy_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Proxy;
