(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Modbus industrial protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-modbus/ffi/zig/src/modbus.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for function codes, exception codes,
    device roles, and gateway states. *)

(** Function codes matching [FunctionCode] in modbus.zig. *)
type function_code =
  | ReadCoils | ReadDiscreteInputs | ReadHoldingRegisters
  | ReadInputRegisters | WriteSingleCoil | WriteSingleRegister
  | WriteMultipleCoils | WriteMultipleRegisters
  | ReadWriteMultipleRegisters | MaskWriteRegister

(** Exception codes matching [ExceptionCode] in modbus.zig. *)
type exception_code =
  | IllegalFunction | IllegalDataAddress | IllegalDataValue
  | SlaveDeviceFailure | Acknowledge | SlaveDeviceBusy
  | MemoryParityError | GatewayPathUnavailable | GatewayTargetDeviceFailed

(** Device roles matching [DeviceRole] in modbus.zig. *)
type device_role =
  | Master | Slave

(** Gateway states matching [GatewayState] in modbus.zig. *)
type gateway_state =
  | Idle | Listening | Processing | Error | Stopping

(** Convert a function code to its ABI tag value. *)
let function_code_to_tag = function
  | ReadCoils -> 0 | ReadDiscreteInputs -> 1 | ReadHoldingRegisters -> 2
  | ReadInputRegisters -> 3 | WriteSingleCoil -> 4
  | WriteSingleRegister -> 5 | WriteMultipleCoils -> 6
  | WriteMultipleRegisters -> 7 | ReadWriteMultipleRegisters -> 8
  | MaskWriteRegister -> 9

(** Decode a function code from its ABI tag value. *)
let function_code_of_tag = function
  | 0 -> Some ReadCoils | 1 -> Some ReadDiscreteInputs
  | 2 -> Some ReadHoldingRegisters | 3 -> Some ReadInputRegisters
  | 4 -> Some WriteSingleCoil | 5 -> Some WriteSingleRegister
  | 6 -> Some WriteMultipleCoils | 7 -> Some WriteMultipleRegisters
  | 8 -> Some ReadWriteMultipleRegisters | 9 -> Some MaskWriteRegister
  | _ -> None

(** Convert an exception code to its ABI tag value. *)
let exception_code_to_tag = function
  | IllegalFunction -> 0 | IllegalDataAddress -> 1 | IllegalDataValue -> 2
  | SlaveDeviceFailure -> 3 | Acknowledge -> 4 | SlaveDeviceBusy -> 5
  | MemoryParityError -> 6 | GatewayPathUnavailable -> 7
  | GatewayTargetDeviceFailed -> 8

(** Decode an exception code from its ABI tag value. *)
let exception_code_of_tag = function
  | 0 -> Some IllegalFunction | 1 -> Some IllegalDataAddress
  | 2 -> Some IllegalDataValue | 3 -> Some SlaveDeviceFailure
  | 4 -> Some Acknowledge | 5 -> Some SlaveDeviceBusy
  | 6 -> Some MemoryParityError | 7 -> Some GatewayPathUnavailable
  | 8 -> Some GatewayTargetDeviceFailed | _ -> None

(** Convert a device role to its ABI tag value. *)
let device_role_to_tag = function
  | Master -> 0 | Slave -> 1

(** Decode a device role from its ABI tag value. *)
let device_role_of_tag = function
  | 0 -> Some Master | 1 -> Some Slave | _ -> None

(** Convert a gateway state to its ABI tag value. *)
let gateway_state_to_tag = function
  | Idle -> 0 | Listening -> 1 | Processing -> 2 | Error -> 3 | Stopping -> 4

(** Decode a gateway state from its ABI tag value. *)
let gateway_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Listening | 2 -> Some Processing
  | 3 -> Some Error | 4 -> Some Stopping | _ -> None

(* --- C FFI declarations --- *)

external c_modbus_abi_version : unit -> int = "modbus_abi_version"
external c_modbus_create_context : unit -> int = "modbus_create_context"
external c_modbus_destroy_context : int -> unit = "modbus_destroy_context"
external c_modbus_can_transition : int -> int -> int = "modbus_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_modbus]. *)
let abi_version () = c_modbus_abi_version ()

(** Create a new Modbus context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_modbus_create_context ())

(** Destroy a Modbus context, releasing its slot. *)
let destroy_context slot = c_modbus_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_modbus_can_transition (gateway_state_to_tag from) (gateway_state_to_tag to_) = 1
