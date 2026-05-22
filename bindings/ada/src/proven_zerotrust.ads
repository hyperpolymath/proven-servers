-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-zerotrust protocol (Zero Trust Architecture).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Zerotrust is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Policy types (tags 0-3).
   type Policy_Type is
     (Pol_Always_Verify, Pol_Never_Trust, Pol_Least_Privilege, Pol_Micro_Segmentation);
   for Policy_Type use
     (Pol_Always_Verify     => 0, Pol_Never_Trust       => 1,
      Pol_Least_Privilege   => 2, Pol_Micro_Segmentation => 3);
   pragma Convention (C, Policy_Type);

   -- Identity confidence (tags 0-4).
   type Identity_Confidence is
     (Id_Unverified, Id_Basic_Auth, Id_Mfa_Verified,
      Id_Strong_Auth, Id_Continuous_Auth);
   for Identity_Confidence use
     (Id_Unverified    => 0, Id_Basic_Auth    => 1,
      Id_Mfa_Verified  => 2, Id_Strong_Auth   => 3,
      Id_Continuous_Auth => 4);
   pragma Convention (C, Identity_Confidence);

   -- Device trust scores (tags 0-4).
   type Device_Trust_Score is
     (Dev_Unknown, Dev_Partial, Dev_Compliant, Dev_Managed, Dev_Hardened);
   for Device_Trust_Score use
     (Dev_Unknown => 0, Dev_Partial => 1, Dev_Compliant => 2,
      Dev_Managed => 3, Dev_Hardened => 4);
   pragma Convention (C, Device_Trust_Score);

   -- Access decisions (tags 0-3).
   type Access_Decision is (Dec_Allow, Dec_Deny, Dec_Challenge, Dec_Step_Up);
   for Access_Decision use
     (Dec_Allow => 0, Dec_Deny => 1, Dec_Challenge => 2, Dec_Step_Up => 3);
   pragma Convention (C, Access_Decision);

   -- Context signal kinds (tags 0-4).
   type Context_Signal_Kind is
     (Sig_Location, Sig_Time, Sig_Device, Sig_Behavior, Sig_Network);
   for Context_Signal_Kind use
     (Sig_Location => 0, Sig_Time => 1, Sig_Device => 2,
      Sig_Behavior => 3, Sig_Network => 4);
   pragma Convention (C, Context_Signal_Kind);

   -- Authentication factors (tags 0-5).
   type Auth_Factor is
     (Af_Certificate, Af_Token, Af_Biometric, Af_Fido2, Af_Totp, Af_Push);
   for Auth_Factor use
     (Af_Certificate => 0, Af_Token => 1, Af_Biometric => 2,
      Af_Fido2       => 3, Af_Totp  => 4, Af_Push      => 5);
   pragma Convention (C, Auth_Factor);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "zerotrust_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "zerotrust_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "zerotrust_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "zerotrust_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "zerotrust_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Zerotrust;
