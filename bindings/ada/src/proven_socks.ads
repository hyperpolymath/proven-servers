-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-socks protocol (SOCKS5 proxy).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Socks is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Authentication methods (tags 0-3).
   type Auth_Method is (Auth_No_Auth, Auth_Gssapi, Auth_Username_Password, Auth_No_Acceptable);
   for Auth_Method use
     (Auth_No_Auth => 0, Auth_Gssapi => 1,
      Auth_Username_Password => 2, Auth_No_Acceptable => 3);
   pragma Convention (C, Auth_Method);

   -- SOCKS commands (tags 0-2).
   type Socks_Command is (Cmd_Connect, Cmd_Bind, Cmd_Udp_Associate);
   for Socks_Command use (Cmd_Connect => 0, Cmd_Bind => 1, Cmd_Udp_Associate => 2);
   pragma Convention (C, Socks_Command);

   -- Address types (tags 0-2).
   type Address_Type is (Addr_IPv4, Addr_Domain_Name, Addr_IPv6);
   for Address_Type use (Addr_IPv4 => 0, Addr_Domain_Name => 1, Addr_IPv6 => 2);
   pragma Convention (C, Address_Type);

   -- Reply codes (tags 0-8).
   type Reply is
     (Reply_Succeeded, Reply_General_Failure, Reply_Not_Allowed,
      Reply_Network_Unreachable, Reply_Host_Unreachable,
      Reply_Connection_Refused, Reply_Ttl_Expired,
      Reply_Command_Not_Supported, Reply_Address_Type_Not_Supported);
   for Reply use
     (Reply_Succeeded              => 0, Reply_General_Failure          => 1,
      Reply_Not_Allowed            => 2, Reply_Network_Unreachable      => 3,
      Reply_Host_Unreachable       => 4, Reply_Connection_Refused       => 5,
      Reply_Ttl_Expired            => 6, Reply_Command_Not_Supported    => 7,
      Reply_Address_Type_Not_Supported => 8);
   pragma Convention (C, Reply);

   -- Connection states (tags 0-5).
   type Connection_State is
     (State_Initial, State_Authenticating, State_Authenticated,
      State_Connecting, State_Established, State_Closed);
   for Connection_State use
     (State_Initial        => 0, State_Authenticating => 1,
      State_Authenticated  => 2, State_Connecting     => 3,
      State_Established    => 4, State_Closed         => 5);
   pragma Convention (C, Connection_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "socks_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "socks_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "socks_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "socks_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "socks_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Socks;
