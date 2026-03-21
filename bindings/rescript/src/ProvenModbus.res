// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Modbus protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module abi.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard Modbus TCP port (Modbus/TCP specification).
let modbusTcpPort = 502

/// Maximum number of coils in a single read request.
let modbusMaxCoils = 2000

/// Maximum number of registers in a single read request.
let modbusMaxRegisters = 125

// ===========================================================================
// FunctionCode (tags 0-9)
// ===========================================================================

/// Standard Modbus TCP port (Modbus/TCP specification).
type functionCode =
  | @as(0) ReadCoils
  | @as(1) ReadDiscreteInputs
  | @as(2) ReadHoldingRegisters
  | @as(3) ReadInputRegisters
  | @as(4) WriteSingleCoil
  | @as(5) WriteSingleRegister
  | @as(6) WriteMultipleCoils
  | @as(7) WriteMultipleRegisters
  | @as(8) ReadWriteMultipleRegisters
  | @as(9) MaskWriteRegister

/// Decode from the C-ABI tag value.
let functionCodeFromTag = (tag: int): option<functionCode> =>
  switch tag {
  | 0 => Some(ReadCoils)
  | 1 => Some(ReadDiscreteInputs)
  | 2 => Some(ReadHoldingRegisters)
  | 3 => Some(ReadInputRegisters)
  | 4 => Some(WriteSingleCoil)
  | 5 => Some(WriteSingleRegister)
  | 6 => Some(WriteMultipleCoils)
  | 7 => Some(WriteMultipleRegisters)
  | 8 => Some(ReadWriteMultipleRegisters)
  | 9 => Some(MaskWriteRegister)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let functionCodeToTag = (v: functionCode): int =>
  switch v {
  | ReadCoils => 0
  | ReadDiscreteInputs => 1
  | ReadHoldingRegisters => 2
  | ReadInputRegisters => 3
  | WriteSingleCoil => 4
  | WriteSingleRegister => 5
  | WriteMultipleCoils => 6
  | WriteMultipleRegisters => 7
  | ReadWriteMultipleRegisters => 8
  | MaskWriteRegister => 9
  }

/// Whether this function code is a read operation.
let functionCodeIsRead = (v: functionCode): bool =>
  switch v {
  | ReadCoils | ReadDiscreteInputs | ReadHoldingRegisters | ReadInputRegisters | ReadWriteMultipleRegisters => true
  | _ => false
  }

/// Whether this function code is a write operation.
let functionCodeIsWrite = (v: functionCode): bool =>
  switch v {
  | WriteSingleCoil | WriteSingleRegister | WriteMultipleCoils | WriteMultipleRegisters | ReadWriteMultipleRegisters | MaskWriteRegister => true
  | _ => false
  }

/// Whether this function code operates on coils (bits).
let functionCodeIsCoilOperation = (v: functionCode): bool =>
  switch v {
  | ReadCoils | ReadDiscreteInputs | WriteSingleCoil | WriteMultipleCoils => true
  | _ => false
  }

// ===========================================================================
// ExceptionCode (tags 0-8)
// ===========================================================================

/// Decode from an ABI tag value.
type exceptionCode =
  | @as(0) IllegalFunction
  | @as(1) IllegalDataAddress
  | @as(2) IllegalDataValue
  | @as(3) SlaveDeviceFailure
  | @as(4) Acknowledge
  | @as(5) SlaveDeviceBusy
  | @as(6) MemoryParityError
  | @as(7) GatewayPathUnavailable
  | @as(8) GatewayTargetDeviceFailed

/// Decode from the C-ABI tag value.
let exceptionCodeFromTag = (tag: int): option<exceptionCode> =>
  switch tag {
  | 0 => Some(IllegalFunction)
  | 1 => Some(IllegalDataAddress)
  | 2 => Some(IllegalDataValue)
  | 3 => Some(SlaveDeviceFailure)
  | 4 => Some(Acknowledge)
  | 5 => Some(SlaveDeviceBusy)
  | 6 => Some(MemoryParityError)
  | 7 => Some(GatewayPathUnavailable)
  | 8 => Some(GatewayTargetDeviceFailed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let exceptionCodeToTag = (v: exceptionCode): int =>
  switch v {
  | IllegalFunction => 0
  | IllegalDataAddress => 1
  | IllegalDataValue => 2
  | SlaveDeviceFailure => 3
  | Acknowledge => 4
  | SlaveDeviceBusy => 5
  | MemoryParityError => 6
  | GatewayPathUnavailable => 7
  | GatewayTargetDeviceFailed => 8
  }

/// Whether this exception indicates the request can be retried.
let exceptionCodeIsRetryable = (v: exceptionCode): bool =>
  switch v {
  | Acknowledge | SlaveDeviceBusy => true
  | _ => false
  }

/// Whether this exception relates to gateway operation.
let exceptionCodeIsGatewayError = (v: exceptionCode): bool =>
  switch v {
  | GatewayPathUnavailable | GatewayTargetDeviceFailed => true
  | _ => false
  }

// ===========================================================================
// DeviceRole (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type deviceRole =
  | @as(0) Master
  | @as(1) Slave

/// Decode from the C-ABI tag value.
let deviceRoleFromTag = (tag: int): option<deviceRole> =>
  switch tag {
  | 0 => Some(Master)
  | 1 => Some(Slave)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let deviceRoleToTag = (v: deviceRole): int =>
  switch v {
  | Master => 0
  | Slave => 1
  }

// ===========================================================================
// GatewayState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type gatewayState =
  | @as(0) Idle
  | @as(1) Listening
  | @as(2) Processing
  | @as(3) Error
  | @as(4) Stopping

/// Decode from the C-ABI tag value.
let gatewayStateFromTag = (tag: int): option<gatewayState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Listening)
  | 2 => Some(Processing)
  | 3 => Some(Error)
  | 4 => Some(Stopping)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let gatewayStateToTag = (v: gatewayState): int =>
  switch v {
  | Idle => 0
  | Listening => 1
  | Processing => 2
  | Error => 3
  | Stopping => 4
  }

/// Whether the gateway is in a healthy operational state.
let gatewayStateIsHealthy = (v: gatewayState): bool =>
  switch v {
  | Listening | Processing => true
  | _ => false
  }

/// Whether the gateway needs operator attention.
let gatewayStateNeedsIntervention = (v: gatewayState): bool =>
  switch v {
  | Error => true
  | _ => false
  }

