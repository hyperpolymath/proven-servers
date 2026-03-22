-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-ca protocol (Certificate Authority / PKI).
--
-- Wraps the C-ABI functions from protocols/proven-ca/ffi/zig/src/ca.zig:
--   ca_abi_version, ca_create_context, ca_destroy_context,
--   ca_state, ca_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Ca is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `CertType` in `CaABI.Types`.
   type Cert_Type is
     (Root,
      Intermediate,
      End_Entity,
      Cross_Signed,
      Code_Signing,
      Email_Protection,
      Ocsp_Signing);
   pragma Convention (C, Cert_Type);

   -- Matches `KeyAlgorithm` in `CaABI.Types`.
   type Key_Algorithm is
     (Rsa2048,
      Rsa4096,
      Ecdsa_P256,
      Ecdsa_P384,
      Ed25519,
      Ed448);
   pragma Convention (C, Key_Algorithm);

   -- Matches `SignatureAlgorithm` in `CaABI.Types`.
   type Signature_Algorithm is
     (Sha256_With_Rsa,
      Sha384_With_Rsa,
      Sha512_With_Rsa,
      Sha256_With_Ecdsa,
      Sha384_With_Ecdsa,
      Pure_Ed25519,
      Pure_Ed448);
   pragma Convention (C, Signature_Algorithm);

   -- Matches `CertState` in `CaABI.Types`.
   type Cert_State is
     (Pending,
      Active,
      Revoked,
      Expired,
      Suspended);
   pragma Convention (C, Cert_State);

   -- Matches `RevocationReason` in `CaABI.Types`.
   type Revocation_Reason is
     (Unspecified,
      Key_Compromise,
      Ca_Compromise,
      Affiliation_Changed,
      Superseded,
      Cessation_Of_Operation,
      Certificate_Hold);
   pragma Convention (C, Revocation_Reason);

   -- Matches `CrlStatus` in `CaABI.Types`.
   type Crl_Status is
     (Current,
      Crl_Expired,
      Crl_Pending,
      Crl_Error);
   pragma Convention (C, Crl_Status);

   -- Matches `OcspStatus` in `CaABI.Types`.
   type Ocsp_Status is
     (Good,
      Ocsp_Revoked,
      Unknown,
      Unavailable);
   pragma Convention (C, Ocsp_Status);

   -- Matches `Extension` in `CaABI.Types`.
   type Extension is
     (Basic_Constraints,
      Key_Usage,
      Ext_Key_Usage,
      Subject_Alt_Name,
      Authority_Info_Access,
      Crl_Distribution_Points);
   pragma Convention (C, Extension);

   -- Matches `KeyUsageBit` in `CaABI.Types`.
   type Key_Usage_Bit is
     (Digital_Signature,
      Non_Repudiation,
      Key_Encipherment,
      Data_Encipherment,
      Key_Agreement,
      Key_Cert_Sign,
      Crl_Sign,
      Encipher_Only,
      Decipher_Only);
   pragma Convention (C, Key_Usage_Bit);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "ca_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "ca_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "ca_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "ca_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "ca_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Ca;
