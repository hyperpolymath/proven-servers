-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-backup protocol (Backup/restore server).
--
-- Wraps the C-ABI functions from protocols/proven-backup/ffi/zig/src/backup.zig:
--   backup_abi_version, backup_create_context, backup_destroy_context,
--   backup_state, backup_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Backup is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `BackupType` in `BackupABI.Types`.
   type Backup_Type is
     (Full,
      Incremental,
      Differential,
      Snapshot,
      Mirror);
   pragma Convention (C, Backup_Type);

   -- Matches `ScheduleFreq` in `BackupABI.Types`.
   type Schedule_Freq is
     (Hourly,
      Daily,
      Weekly,
      Monthly,
      On_Demand);
   pragma Convention (C, Schedule_Freq);

   -- Matches `CompressionAlg` in `BackupABI.Types`.
   type Compression_Alg is
     (None,
      Gzip,
      Zstd,
      Lz4,
      Xz);
   pragma Convention (C, Compression_Alg);

   -- Matches `EncryptionAlg` in `BackupABI.Types`.
   type Encryption_Alg is
     (No_Encryption,
      Aes256_Gcm,
      Cha_Cha20_Poly1305);
   pragma Convention (C, Encryption_Alg);

   -- Matches `BackupState` in `BackupABI.Types`.
   type Backup_State is
     (Idle,
      Running,
      Verifying,
      Complete,
      Failed,
      Cancelled);
   pragma Convention (C, Backup_State);

   -- Matches `RetentionPolicy` in `BackupABI.Types`.
   type Retention_Policy is
     (Keep_All,
      Keep_Last,
      Keep_Daily,
      Keep_Weekly,
      Keep_Monthly);
   pragma Convention (C, Retention_Policy);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "backup_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "backup_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "backup_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "backup_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "backup_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Backup;
