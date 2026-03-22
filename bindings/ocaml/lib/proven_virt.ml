(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Virtualization/hypervisor bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-virt/ffi/zig/src/virt.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for VM states, operations,
    disk formats, network types, and boot devices. *)

(** VM lifecycle states matching [VmState] in virt.zig. *)
type vm_state =
  | Creating | Running | Paused | Suspended | Shutting_down
  | Stopped | Crashed | Migrating

(** Virtualization operations matching [VirtOperation] in virt.zig. *)
type virt_operation =
  | Create | Start | Stop | Restart | Pause | Resume
  | Suspend | Migrate | Snapshot | Clone | Delete

(** Disk image formats matching [DiskFormat] in virt.zig. *)
type disk_format = Raw | Qcow2 | Vdi | Vmdk | Vhd

(** Virtual network types matching [NetworkType] in virt.zig. *)
type network_type = Nat | Bridged | Internal | Host_only

(** Boot device types matching [BootDevice] in virt.zig. *)
type boot_device = Hard_disk | Cdrom | Network | Usb

(** Convert a VM state to its ABI tag value. *)
let vm_state_to_tag = function
  | Creating -> 0 | Running -> 1 | Paused -> 2 | Suspended -> 3
  | Shutting_down -> 4 | Stopped -> 5 | Crashed -> 6 | Migrating -> 7

(** Decode a VM state from its ABI tag value. *)
let vm_state_of_tag = function
  | 0 -> Some Creating | 1 -> Some Running | 2 -> Some Paused
  | 3 -> Some Suspended | 4 -> Some Shutting_down | 5 -> Some Stopped
  | 6 -> Some Crashed | 7 -> Some Migrating | _ -> None

(** Convert a virt operation to its ABI tag value. *)
let virt_operation_to_tag = function
  | Create -> 0 | Start -> 1 | Stop -> 2 | Restart -> 3 | Pause -> 4
  | Resume -> 5 | Suspend -> 6 | Migrate -> 7 | Snapshot -> 8
  | Clone -> 9 | Delete -> 10

(** Decode a virt operation from its ABI tag value. *)
let virt_operation_of_tag = function
  | 0 -> Some Create | 1 -> Some Start | 2 -> Some Stop | 3 -> Some Restart
  | 4 -> Some Pause | 5 -> Some Resume | 6 -> Some Suspend
  | 7 -> Some Migrate | 8 -> Some Snapshot | 9 -> Some Clone
  | 10 -> Some Delete | _ -> None

(** Convert a disk format to its ABI tag value. *)
let disk_format_to_tag = function
  | Raw -> 0 | Qcow2 -> 1 | Vdi -> 2 | Vmdk -> 3 | Vhd -> 4

(** Decode a disk format from its ABI tag value. *)
let disk_format_of_tag = function
  | 0 -> Some Raw | 1 -> Some Qcow2 | 2 -> Some Vdi
  | 3 -> Some Vmdk | 4 -> Some Vhd | _ -> None

(** Convert a network type to its ABI tag value. *)
let network_type_to_tag = function
  | Nat -> 0 | Bridged -> 1 | Internal -> 2 | Host_only -> 3

(** Decode a network type from its ABI tag value. *)
let network_type_of_tag = function
  | 0 -> Some Nat | 1 -> Some Bridged | 2 -> Some Internal
  | 3 -> Some Host_only | _ -> None

(** Convert a boot device to its ABI tag value. *)
let boot_device_to_tag = function
  | Hard_disk -> 0 | Cdrom -> 1 | Network -> 2 | Usb -> 3

(** Decode a boot device from its ABI tag value. *)
let boot_device_of_tag = function
  | 0 -> Some Hard_disk | 1 -> Some Cdrom | 2 -> Some Network
  | 3 -> Some Usb | _ -> None

(* --- C FFI declarations --- *)

external c_virt_abi_version : unit -> int = "virt_abi_version"
external c_virt_create_context : unit -> int = "virt_create_context"
external c_virt_destroy_context : int -> unit = "virt_destroy_context"
external c_virt_can_transition : int -> int -> int = "virt_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_virt]. *)
let abi_version () = c_virt_abi_version ()

(** Create a new virtualization context. *)
let create_context () =
  Proven_error.from_slot (c_virt_create_context ())

(** Destroy a virtualization context, releasing its slot. *)
let destroy_context slot = c_virt_destroy_context slot

(** Stateless query: check whether a VM state transition is valid. *)
let can_transition ~from ~to_ =
  c_virt_can_transition (vm_state_to_tag from) (vm_state_to_tag to_) = 1
