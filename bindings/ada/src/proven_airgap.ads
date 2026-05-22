-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-airgap protocol (Air-gapped transfer).
--
-- Wraps the C-ABI functions from protocols/proven-airgap/ffi/zig/src/airgap.zig:
--   airgap_abi_version, airgap_create_context, airgap_destroy_context,
--   airgap_state, airgap_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Airgap is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `TransferDirection` in `AirgapABI.Types`.
   type Transfer_Direction is
     (Import,
      Export);
   pragma Convention (C, Transfer_Direction);

   -- Matches `MediaType` in `AirgapABI.Types`.
   type Media_Type is
     (Usb,
      Optical_Disc,
      Tape_Cartridge,
      Diode_Link);
   pragma Convention (C, Media_Type);

   -- Matches `ScanResult` in `AirgapABI.Types`.
   type Scan_Result is
     (Clean,
      Suspicious,
      Malicious,
      Unscannable);
   pragma Convention (C, Scan_Result);

   -- Matches `TransferState` in `AirgapABI.Types`.
   type Transfer_State is
     (Pending,
      Scanning,
      Approved,
      Rejected,
      In_Progress,
      Complete,
      Failed);
   pragma Convention (C, Transfer_State);

   -- Matches `ValidationCheck` in `AirgapABI.Types`.
   type Validation_Check is
     (Hash_Verify,
      Signature_Verify,
      Format_Check,
      Content_Inspection,
      Malware_Scan);
   pragma Convention (C, Validation_Check);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "airgap_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "airgap_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "airgap_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "airgap_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "airgap_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Airgap;
