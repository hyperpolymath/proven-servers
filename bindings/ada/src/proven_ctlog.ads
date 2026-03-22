-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-ctlog protocol (Certificate Transparency log (RFC 6962)).
--
-- Wraps the C-ABI functions from protocols/proven-ctlog/ffi/zig/src/ctlog.zig:
--   ctlog_abi_version, ctlog_create_context, ctlog_destroy_context,
--   ctlog_state, ctlog_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Ctlog is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `LogEntryType` in `CtlogABI.Types`.
   type Log_Entry_Type is
     (X509_Entry,
      Precert_Entry);
   pragma Convention (C, Log_Entry_Type);

   -- Matches `SignatureType` in `CtlogABI.Types`.
   type Signature_Type is
     (Certificate_Timestamp,
      Tree_Hash);
   pragma Convention (C, Signature_Type);

   -- Matches `MerkleLeafType` in `CtlogABI.Types`.
   type Merkle_Leaf_Type is
     (Timestamped_Entry,
      Timestamped_Entry);
   pragma Convention (C, Merkle_Leaf_Type);

   -- Matches `SubmissionStatus` in `CtlogABI.Types`.
   type Submission_Status is
     (Accepted,
      Duplicate,
      Rate_Limited,
      Rejected,
      Invalid_Chain,
      Unknown_Anchor);
   pragma Convention (C, Submission_Status);

   -- Matches `VerificationResult` in `CtlogABI.Types`.
   type Verification_Result is
     (Valid_Proof,
      Invalid_Proof,
      Inconsistent_Tree,
      Stale_Sth);
   pragma Convention (C, Verification_Result);

   -- Matches `ServerState` in `CtlogABI.Types`.
   type Server_State is
     (Idle,
      Active,
      Merging,
      Signing,
      Shutdown);
   pragma Convention (C, Server_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "ctlog_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "ctlog_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "ctlog_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "ctlog_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "ctlog_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Ctlog;
