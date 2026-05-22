(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Backup/restore protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-backup/ffi/zig/src/backup.zig]. *)

(** BackupType matching [BackupType] in backup.zig. *)
type backup_type =
  | Full  (** Full (tag 0). *)
  | Incremental  (** Incremental (tag 1). *)
  | Differential  (** Differential (tag 2). *)
  | Snapshot  (** Snapshot (tag 3). *)
  | Mirror  (** Mirror (tag 4). *)

let backup_type_to_tag = function
  | Full -> 0 | Incremental -> 1 | Differential -> 2 | Snapshot -> 3
  | Mirror -> 4

let backup_type_of_tag = function
  | 0 -> Some Full | 1 -> Some Incremental | 2 -> Some Differential
  | 3 -> Some Snapshot | 4 -> Some Mirror | _ -> None

(** ScheduleFreq matching [ScheduleFreq] in backup.zig. *)
type schedule_freq =
  | Hourly  (** Hourly (tag 0). *)
  | Daily  (** Daily (tag 1). *)
  | Weekly  (** Weekly (tag 2). *)
  | Monthly  (** Monthly (tag 3). *)
  | OnDemand  (** OnDemand (tag 4). *)

let schedule_freq_to_tag = function
  | Hourly -> 0 | Daily -> 1 | Weekly -> 2 | Monthly -> 3 | OnDemand -> 4

let schedule_freq_of_tag = function
  | 0 -> Some Hourly | 1 -> Some Daily | 2 -> Some Weekly
  | 3 -> Some Monthly | 4 -> Some OnDemand | _ -> None

(** CompressionAlg matching [CompressionAlg] in backup.zig. *)
type compression_alg =
  | CompNone  (** None (tag 0). *)
  | Gzip  (** Gzip (tag 1). *)
  | Zstd  (** Zstd (tag 2). *)
  | Lz4  (** LZ4 (tag 3). *)
  | Xz  (** XZ (tag 4). *)

let compression_alg_to_tag = function
  | CompNone -> 0 | Gzip -> 1 | Zstd -> 2 | Lz4 -> 3 | Xz -> 4

let compression_alg_of_tag = function
  | 0 -> Some CompNone | 1 -> Some Gzip | 2 -> Some Zstd | 3 -> Some Lz4
  | 4 -> Some Xz | _ -> None

(** EncryptionAlg matching [EncryptionAlg] in backup.zig. *)
type encryption_alg =
  | NoEncryption  (** NoEncryption (tag 0). *)
  | Aes256Gcm  (** AES-256-GCM (tag 1). *)
  | ChaCha20Poly1305  (** ChaCha20-Poly1305 (tag 2). *)

let encryption_alg_to_tag = function
  | NoEncryption -> 0 | Aes256Gcm -> 1 | ChaCha20Poly1305 -> 2

let encryption_alg_of_tag = function
  | 0 -> Some NoEncryption | 1 -> Some Aes256Gcm
  | 2 -> Some ChaCha20Poly1305 | _ -> None

(** BackupState matching [BackupState] in backup.zig. *)
type backup_state =
  | Idle  (** Idle (tag 0). *)
  | Running  (** Running (tag 1). *)
  | Verifying  (** Verifying (tag 2). *)
  | Complete  (** Complete (tag 3). *)
  | Failed  (** Failed (tag 4). *)
  | Cancelled  (** Cancelled (tag 5). *)

let backup_state_to_tag = function
  | Idle -> 0 | Running -> 1 | Verifying -> 2 | Complete -> 3
  | Failed -> 4 | Cancelled -> 5

let backup_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Running | 2 -> Some Verifying
  | 3 -> Some Complete | 4 -> Some Failed | 5 -> Some Cancelled
  | _ -> None

(** RetentionPolicy matching [RetentionPolicy] in backup.zig. *)
type retention_policy =
  | KeepAll  (** KeepAll (tag 0). *)
  | KeepLast  (** KeepLast (tag 1). *)
  | KeepDaily  (** KeepDaily (tag 2). *)
  | KeepWeekly  (** KeepWeekly (tag 3). *)
  | KeepMonthly  (** KeepMonthly (tag 4). *)

let retention_policy_to_tag = function
  | KeepAll -> 0 | KeepLast -> 1 | KeepDaily -> 2 | KeepWeekly -> 3
  | KeepMonthly -> 4

let retention_policy_of_tag = function
  | 0 -> Some KeepAll | 1 -> Some KeepLast | 2 -> Some KeepDaily
  | 3 -> Some KeepWeekly | 4 -> Some KeepMonthly | _ -> None

(* --- C FFI declarations --- *)

external c_backup_abi_version : unit -> int = "backup_abi_version"
external c_backup_create_context : unit -> int = "backup_create_context"
external c_backup_destroy_context : int -> unit = "backup_destroy_context"
external c_backup_state : int -> int = "backup_state"
external c_backup_can_transition : int -> int -> int = "backup_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_backup_abi_version ()

let create_context () = Proven_error.from_slot (c_backup_create_context ())

let destroy_context slot = c_backup_destroy_context slot

let get_state slot = backup_state_of_tag (c_backup_state slot)

let can_transition ~from ~to_ =
  c_backup_can_transition (backup_state_to_tag from) (backup_state_to_tag to_) = 1
