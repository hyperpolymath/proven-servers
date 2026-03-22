(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Database server types for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-dbserver/ffi/zig/src/dbserver.zig]. *)

(** QueryType matching [QueryType] in dbserver.zig. *)
type query_type =
  | Select  (** SELECT query (tag 0). *)
  | Insert  (** INSERT query (tag 1). *)
  | Update  (** UPDATE query (tag 2). *)
  | Delete  (** DELETE query (tag 3). *)
  | CreateTable  (** CREATE TABLE DDL (tag 4). *)
  | DropTable  (** DROP TABLE DDL (tag 5). *)
  | AlterTable  (** ALTER TABLE DDL (tag 6). *)
  | CreateIndex  (** CREATE INDEX DDL (tag 7). *)
  | DropIndex  (** DROP INDEX DDL (tag 8). *)
  | Begin  (** BEGIN TRANSACTION (tag 9). *)
  | Commit  (** COMMIT TRANSACTION (tag 10). *)
  | Rollback  (** ROLLBACK TRANSACTION (tag 11). *)

let query_type_to_tag = function
  | Select -> 0
  | Insert -> 1
  | Update -> 2
  | Delete -> 3
  | CreateTable -> 4
  | DropTable -> 5
  | AlterTable -> 6
  | CreateIndex -> 7
  | DropIndex -> 8
  | Begin -> 9
  | Commit -> 10
  | Rollback -> 11

let query_type_of_tag = function
  | 0 -> Some Select
  | 1 -> Some Insert
  | 2 -> Some Update
  | 3 -> Some Delete
  | 4 -> Some CreateTable
  | 5 -> Some DropTable
  | 6 -> Some AlterTable
  | 7 -> Some CreateIndex
  | 8 -> Some DropIndex
  | 9 -> Some Begin
  | 10 -> Some Commit
  | 11 -> Some Rollback
  | _ -> None

(** DataType matching [DataType] in dbserver.zig. *)
type data_type =
  | Integer  (** Integer (tag 0). *)
  | Float  (** Float (tag 1). *)
  | Text  (** Text (tag 2). *)
  | Blob  (** Blob (tag 3). *)
  | Boolean  (** Boolean (tag 4). *)
  | Timestamp  (** Timestamp (tag 5). *)
  | Uuid  (** UUID type (tag 6). *)
  | Json  (** JSON type (tag 7). *)
  | Null  (** Null (tag 8). *)

let data_type_to_tag = function
  | Integer -> 0
  | Float -> 1
  | Text -> 2
  | Blob -> 3
  | Boolean -> 4
  | Timestamp -> 5
  | Uuid -> 6
  | Json -> 7
  | Null -> 8

let data_type_of_tag = function
  | 0 -> Some Integer
  | 1 -> Some Float
  | 2 -> Some Text
  | 3 -> Some Blob
  | 4 -> Some Boolean
  | 5 -> Some Timestamp
  | 6 -> Some Uuid
  | 7 -> Some Json
  | 8 -> Some Null
  | _ -> None

(** IsolationLevel matching [IsolationLevel] in dbserver.zig. *)
type isolation_level =
  | ReadUncommitted  (** ReadUncommitted (tag 0). *)
  | ReadCommitted  (** ReadCommitted (tag 1). *)
  | RepeatableRead  (** RepeatableRead (tag 2). *)
  | Serializable  (** Serializable (tag 3). *)

let isolation_level_to_tag = function
  | ReadUncommitted -> 0
  | ReadCommitted -> 1
  | RepeatableRead -> 2
  | Serializable -> 3

let isolation_level_of_tag = function
  | 0 -> Some ReadUncommitted
  | 1 -> Some ReadCommitted
  | 2 -> Some RepeatableRead
  | 3 -> Some Serializable
  | _ -> None

(** ErrorCode matching [ErrorCode] in dbserver.zig. *)
type error_code =
  | SyntaxError  (** SyntaxError (tag 0). *)
  | TableNotFound  (** TableNotFound (tag 1). *)
  | ColumnNotFound  (** ColumnNotFound (tag 2). *)
  | DuplicateKey  (** DuplicateKey (tag 3). *)
  | ConstraintViolation  (** ConstraintViolation (tag 4). *)
  | TypeMismatch  (** TypeMismatch (tag 5). *)
  | DeadlockDetected  (** DeadlockDetected (tag 6). *)
  | TransactionAborted  (** TransactionAborted (tag 7). *)
  | DiskFull  (** DiskFull (tag 8). *)
  | ConnectionLost  (** ConnectionLost (tag 9). *)

let error_code_to_tag = function
  | SyntaxError -> 0
  | TableNotFound -> 1
  | ColumnNotFound -> 2
  | DuplicateKey -> 3
  | ConstraintViolation -> 4
  | TypeMismatch -> 5
  | DeadlockDetected -> 6
  | TransactionAborted -> 7
  | DiskFull -> 8
  | ConnectionLost -> 9

let error_code_of_tag = function
  | 0 -> Some SyntaxError
  | 1 -> Some TableNotFound
  | 2 -> Some ColumnNotFound
  | 3 -> Some DuplicateKey
  | 4 -> Some ConstraintViolation
  | 5 -> Some TypeMismatch
  | 6 -> Some DeadlockDetected
  | 7 -> Some TransactionAborted
  | 8 -> Some DiskFull
  | 9 -> Some ConnectionLost
  | _ -> None

(** JoinType matching [JoinType] in dbserver.zig. *)
type join_type =
  | Inner  (** Inner (tag 0). *)
  | LeftOuter  (** LeftOuter (tag 1). *)
  | RightOuter  (** RightOuter (tag 2). *)
  | FullOuter  (** FullOuter (tag 3). *)
  | Cross  (** Cross (tag 4). *)

let join_type_to_tag = function
  | Inner -> 0
  | LeftOuter -> 1
  | RightOuter -> 2
  | FullOuter -> 3
  | Cross -> 4

let join_type_of_tag = function
  | 0 -> Some Inner
  | 1 -> Some LeftOuter
  | 2 -> Some RightOuter
  | 3 -> Some FullOuter
  | 4 -> Some Cross
  | _ -> None

(** SessionState matching [SessionState] in dbserver.zig. *)
type session_state =
  | Idle  (** Idle (tag 0). *)
  | Connected  (** Connected (tag 1). *)
  | Transaction  (** Transaction (tag 2). *)
  | Executing  (** Executing (tag 3). *)
  | Finalising  (** Finalising (tag 4). *)
  | Disconnecting  (** Disconnecting (tag 5). *)

let session_state_to_tag = function
  | Idle -> 0
  | Connected -> 1
  | Transaction -> 2
  | Executing -> 3
  | Finalising -> 4
  | Disconnecting -> 5

let session_state_of_tag = function
  | 0 -> Some Idle
  | 1 -> Some Connected
  | 2 -> Some Transaction
  | 3 -> Some Executing
  | 4 -> Some Finalising
  | 5 -> Some Disconnecting
  | _ -> None

(* --- C FFI declarations --- *)

external c_dbserver_abi_version : unit -> int = "dbserver_abi_version"
external c_dbserver_create_context : unit -> int = "dbserver_create_context"
external c_dbserver_destroy_context : int -> unit = "dbserver_destroy_context"
external c_dbserver_state : int -> int = "dbserver_state"
external c_dbserver_can_transition : int -> int -> int = "dbserver_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_dbserver_abi_version ()

let create_context () = Proven_error.from_slot (c_dbserver_create_context ())

let destroy_context slot = c_dbserver_destroy_context slot

let get_state slot = session_state_of_tag (c_dbserver_state slot)

let can_transition ~from ~to_ =
  c_dbserver_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
