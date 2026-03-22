-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-authserver protocol (Authentication server).
--
-- Wraps the C-ABI functions from protocols/proven-authserver/ffi/zig/src/authserver.zig:
--   authserver_abi_version, authserver_create_context, authserver_destroy_context,
--   authserver_state, authserver_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Authserver is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `AuthMethod` in `AuthserverABI.Types`.
   type Auth_Method is
     (Password,
      Certificate,
      O_Auth2,
      Saml,
      Fido2,
      Kerberos,
      Ldap,
      Radius);
   pragma Convention (C, Auth_Method);

   -- Matches `TokenType` in `AuthserverABI.Types`.
   type Token_Type is
     (Access,
      Refresh,
      Id,
      Api);
   pragma Convention (C, Token_Type);

   -- Matches `AuthResult` in `AuthserverABI.Types`.
   type Auth_Result is
     (Success,
      Invalid_Credentials,
      Account_Locked,
      Account_Expired,
      Mfa_Required,
      Ip_Blocked);
   pragma Convention (C, Auth_Result);

   -- Matches `MfaMethod` in `AuthserverABI.Types`.
   type Mfa_Method is
     (Totp,
      Sms,
      Push,
      Fido2_Mfa,
      Email);
   pragma Convention (C, Mfa_Method);

   -- Matches `SessionState` in `AuthserverABI.Types`.
   type Session_State is
     (Active,
      Expired,
      Revoked,
      Locked);
   pragma Convention (C, Session_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "authserver_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "authserver_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "authserver_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "authserver_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "authserver_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Authserver;
