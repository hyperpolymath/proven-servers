-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-kerberos protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Kerberos is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Kerberos message types (tags 0-9).
   type Message_Type is
     (Msg_As_Req, Msg_As_Rep, Msg_Tgs_Req, Msg_Tgs_Rep,
      Msg_Ap_Req, Msg_Ap_Rep, Msg_Krb_Error, Msg_Krb_Safe,
      Msg_Krb_Priv, Msg_Krb_Cred);
   for Message_Type use
     (Msg_As_Req => 0, Msg_As_Rep => 1, Msg_Tgs_Req => 2,
      Msg_Tgs_Rep => 3, Msg_Ap_Req => 4, Msg_Ap_Rep => 5,
      Msg_Krb_Error => 6, Msg_Krb_Safe => 7, Msg_Krb_Priv => 8,
      Msg_Krb_Cred => 9);
   pragma Convention (C, Message_Type);

   -- Encryption types (tags 0-4).
   type Encryption_Type is
     (Enc_Aes256_Cts_Hmac_Sha1, Enc_Aes128_Cts_Hmac_Sha1,
      Enc_Aes256_Cts_Hmac_Sha384, Enc_Rc4_Hmac, Enc_Des3_Cbc_Sha1);
   for Encryption_Type use
     (Enc_Aes256_Cts_Hmac_Sha1 => 0, Enc_Aes128_Cts_Hmac_Sha1 => 1,
      Enc_Aes256_Cts_Hmac_Sha384 => 2, Enc_Rc4_Hmac => 3,
      Enc_Des3_Cbc_Sha1 => 4);
   pragma Convention (C, Encryption_Type);

   -- Principal name types (tags 0-6).
   type Principal_Type is
     (Nt_Unknown, Nt_Principal, Nt_Srv_Inst, Nt_Srv_Hst,
      Nt_Uid, Nt_X500, Nt_Enterprise);
   for Principal_Type use
     (Nt_Unknown => 0, Nt_Principal => 1, Nt_Srv_Inst => 2,
      Nt_Srv_Hst => 3, Nt_Uid => 4, Nt_X500 => 5, Nt_Enterprise => 6);
   pragma Convention (C, Principal_Type);

   -- Ticket flags (tags 0-6).
   type Ticket_Flag is
     (Flag_Forwardable, Flag_Forwarded, Flag_Proxiable, Flag_Proxy,
      Flag_Renewable, Flag_Pre_Authent, Flag_Hw_Authent);
   for Ticket_Flag use
     (Flag_Forwardable => 0, Flag_Forwarded => 1, Flag_Proxiable => 2,
      Flag_Proxy => 3, Flag_Renewable => 4, Flag_Pre_Authent => 5,
      Flag_Hw_Authent => 6);
   pragma Convention (C, Ticket_Flag);

   -- Authentication states (tags 0-4).
   type Auth_State is
     (Auth_Initial, Auth_Tgt_Obtained, Auth_Service_Ticket_Obtained,
      Auth_Authenticated, Auth_Failed);
   for Auth_State use
     (Auth_Initial => 0, Auth_Tgt_Obtained => 1,
      Auth_Service_Ticket_Obtained => 2, Auth_Authenticated => 3,
      Auth_Failed => 4);
   pragma Convention (C, Auth_State);

   -- Encryption strength levels (tags 0-2).
   type Enc_Strength is (Enc_Strong, Enc_Medium, Enc_Weak);
   for Enc_Strength use (Enc_Strong => 0, Enc_Medium => 1, Enc_Weak => 2);
   pragma Convention (C, Enc_Strength);

   -- Pre-authentication types (tags 0-3).
   type Pre_Auth_Type is
     (Pa_Enc_Timestamp, Pa_Etype_Info2, Pa_Fx_Fast, Pa_Fx_Cookie);
   for Pre_Auth_Type use
     (Pa_Enc_Timestamp => 0, Pa_Etype_Info2 => 1,
      Pa_Fx_Fast => 2, Pa_Fx_Cookie => 3);
   pragma Convention (C, Pre_Auth_Type);

   -- Negotiation states (tags 0-3).
   type Negotiation_State is
     (Neg_Idle, Neg_Proposed, Neg_Selected, Neg_Failed);
   for Negotiation_State use
     (Neg_Idle => 0, Neg_Proposed => 1, Neg_Selected => 2, Neg_Failed => 3);
   pragma Convention (C, Negotiation_State);

   -- Standard Kerberos KDC port.
   Kerberos_Port : constant := 88;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "kerberos_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "kerberos_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "kerberos_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "kerberos_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "kerberos_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Kerberos;
