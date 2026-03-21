-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-ssh-bastion protocol (SSH bastion host).
--
-- Wraps the C-ABI functions from protocols/proven-ssh-bastion/ffi/zig/src/ssh_bastion.zig.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Ssh is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- SSH bastion session states.
   type Bastion_State is
     (State_Init,
      State_Kex,
      State_Auth,
      State_Authenticated,
      State_Channel_Open,
      State_Rekey,
      State_Disconnected);
   for Bastion_State use
     (State_Init          => 0,
      State_Kex           => 1,
      State_Auth          => 2,
      State_Authenticated => 3,
      State_Channel_Open  => 4,
      State_Rekey         => 5,
      State_Disconnected  => 6);
   pragma Convention (C, Bastion_State);

   -- SSH key exchange methods.
   type Kex_Method is
     (Kex_Curve25519_SHA256,
      Kex_ECDH_SHA2_NISTP256,
      Kex_ECDH_SHA2_NISTP384,
      Kex_DH_Group14_SHA256,
      Kex_DH_Group16_SHA512);
   for Kex_Method use
     (Kex_Curve25519_SHA256   => 0,
      Kex_ECDH_SHA2_NISTP256  => 1,
      Kex_ECDH_SHA2_NISTP384  => 2,
      Kex_DH_Group14_SHA256   => 3,
      Kex_DH_Group16_SHA512   => 4);
   pragma Convention (C, Kex_Method);

   -- SSH authentication methods.
   type Auth_Method is
     (Auth_Public_Key,
      Auth_Password,
      Auth_Keyboard_Interactive,
      Auth_Certificate);
   for Auth_Method use
     (Auth_Public_Key            => 0,
      Auth_Password              => 1,
      Auth_Keyboard_Interactive  => 2,
      Auth_Certificate           => 3);
   pragma Convention (C, Auth_Method);

   -- SSH channel types.
   type Channel_Type is
     (Channel_Session,
      Channel_Direct_Tcpip,
      Channel_Forwarded_Tcpip,
      Channel_X11);
   for Channel_Type use
     (Channel_Session         => 0,
      Channel_Direct_Tcpip    => 1,
      Channel_Forwarded_Tcpip => 2,
      Channel_X11             => 3);
   pragma Convention (C, Channel_Type);

   -- SSH channel states.
   type Channel_State is
     (Ch_Opening,
      Ch_Open,
      Ch_Half_Closed_Local,
      Ch_Half_Closed_Remote,
      Ch_Closed);
   for Channel_State use
     (Ch_Opening             => 0,
      Ch_Open                => 1,
      Ch_Half_Closed_Local   => 2,
      Ch_Half_Closed_Remote  => 3,
      Ch_Closed              => 4);
   pragma Convention (C, Channel_State);

   -- SSH disconnect reasons.
   type Disconnect_Reason is
     (Reason_By_Application,
      Reason_Too_Many_Auth_Failures,
      Reason_Protocol_Error,
      Reason_Timeout);
   for Disconnect_Reason use
     (Reason_By_Application          => 0,
      Reason_Too_Many_Auth_Failures  => 1,
      Reason_Protocol_Error          => 2,
      Reason_Timeout                 => 3);
   pragma Convention (C, Disconnect_Reason);

   ---------------------------------------------------------------------------
   -- Raw FFI imports
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "ssh_bastion_abi_version");

   function Create
     (Kex_Method_Tag  : unsigned_char;
      Auth_Method_Tag : unsigned_char) return int;
   pragma Import (C, Create, "ssh_bastion_create");

   procedure Destroy (Slot : int);
   pragma Import (C, Destroy, "ssh_bastion_destroy");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "ssh_bastion_state");

   function Get_Kex_Method (Slot : int) return unsigned_char;
   pragma Import (C, Get_Kex_Method, "ssh_bastion_kex_method");

   function Get_Auth_Method (Slot : int) return unsigned_char;
   pragma Import (C, Get_Auth_Method, "ssh_bastion_auth_method");

   function Can_Transfer (Slot : int) return unsigned_char;
   pragma Import (C, Can_Transfer, "ssh_bastion_can_transfer");

   function Get_Disconnect_Reason (Slot : int) return unsigned_char;
   pragma Import (C, Get_Disconnect_Reason, "ssh_bastion_disconnect_reason");

   function Auth_Failures (Slot : int) return unsigned_char;
   pragma Import (C, Auth_Failures, "ssh_bastion_auth_failures");

   function Complete_Kex (Slot : int) return unsigned_char;
   pragma Import (C, Complete_Kex, "ssh_bastion_complete_kex");

   function Authenticate
     (Slot     : int;
      User_Len : unsigned_short) return unsigned_char;
   pragma Import (C, Authenticate, "ssh_bastion_authenticate");

   function Record_Auth_Failure (Slot : int) return unsigned_char;
   pragma Import (C, Record_Auth_Failure, "ssh_bastion_record_auth_failure");

   function Open_Channel
     (Slot    : int;
      Ch_Type : unsigned_char) return int;
   pragma Import (C, Open_Channel, "ssh_bastion_open_channel");

   function Confirm_Channel
     (Slot  : int;
      Ch_Id : unsigned_char) return unsigned_char;
   pragma Import (C, Confirm_Channel, "ssh_bastion_confirm_channel");

   function Close_Channel
     (Slot  : int;
      Ch_Id : unsigned_char) return unsigned_char;
   pragma Import (C, Close_Channel, "ssh_bastion_close_channel");

   function Get_Channel_State
     (Slot  : int;
      Ch_Id : unsigned_char) return unsigned_char;
   pragma Import (C, Get_Channel_State, "ssh_bastion_channel_state");

   function Get_Channel_Type
     (Slot  : int;
      Ch_Id : unsigned_char) return unsigned_char;
   pragma Import (C, Get_Channel_Type, "ssh_bastion_channel_type");

   function Channel_Count (Slot : int) return unsigned_char;
   pragma Import (C, Channel_Count, "ssh_bastion_channel_count");

   function Rekey (Slot : int) return unsigned_char;
   pragma Import (C, Rekey, "ssh_bastion_rekey");

   function Disconnect
     (Slot   : int;
      Reason : unsigned_char) return unsigned_char;
   pragma Import (C, Disconnect, "ssh_bastion_disconnect");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "ssh_bastion_can_transition");

   function Audit_Count (Slot : int) return unsigned;
   pragma Import (C, Audit_Count, "ssh_bastion_audit_count");

   function Audit_Entry
     (Slot      : int;
      Entry_Idx : unsigned) return unsigned_char;
   pragma Import (C, Audit_Entry, "ssh_bastion_audit_entry");

   function Audit_Entry_To
     (Slot      : int;
      Entry_Idx : unsigned) return unsigned_char;
   pragma Import (C, Audit_Entry_To, "ssh_bastion_audit_entry_to");

   function Set_Recording
     (Slot    : int;
      Enabled : unsigned_char) return unsigned_char;
   pragma Import (C, Set_Recording, "ssh_bastion_set_recording");

   function Is_Recording (Slot : int) return unsigned_char;
   pragma Import (C, Is_Recording, "ssh_bastion_is_recording");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create
     (Kex  : Kex_Method;
      Auth : Auth_Method) return Proven_Error.Slot_Id;

   procedure Safe_Destroy (Slot : Proven_Error.Slot_Id);
   procedure Safe_Complete_Kex (Slot : Proven_Error.Slot_Id);
   procedure Safe_Disconnect
     (Slot   : Proven_Error.Slot_Id;
      Reason : Disconnect_Reason);

end Proven_Ssh;
