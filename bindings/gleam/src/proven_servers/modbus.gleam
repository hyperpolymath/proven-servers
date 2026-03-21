//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Modbus protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `ModbusABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Modbus Constants
// ===========================================================================

/// Modbus Tcp Port constant.
pub const modbus_tcp_port = 502

/// Modbus Max Coils constant.
pub const modbus_max_coils = 2000

/// Modbus Max Registers constant.
pub const modbus_max_registers = 125

// ===========================================================================
// FunctionCode
// ===========================================================================

/// Modbus function codes (Modbus Application Protocol Specification).
/// 
/// Matches `FunctionCode` in the Modbus `abi.Types`.
pub type FunctionCode {
  /// FC 01: Read coils (tag 0).
  ReadCoils
  /// FC 02: Read discrete inputs (tag 1).
  ReadDiscreteInputs
  /// FC 03: Read holding registers (tag 2).
  ReadHoldingRegisters
  /// FC 04: Read input registers (tag 3).
  ReadInputRegisters
  /// FC 05: Write single coil (tag 4).
  WriteSingleCoil
  /// FC 06: Write single register (tag 5).
  WriteSingleRegister
  /// FC 15: Write multiple coils (tag 6).
  WriteMultipleCoils
  /// FC 16: Write multiple registers (tag 7).
  WriteMultipleRegisters
  /// FC 23: Read/write multiple registers (tag 8).
  ReadWriteMultipleRegisters
  /// FC 22: Mask write register (tag 9).
  MaskWriteRegister
}

/// Convert a `FunctionCode` to its C-ABI tag value.
pub fn function_code_to_int(value: FunctionCode) -> Int {
  case value {
    ReadCoils -> 0
    ReadDiscreteInputs -> 1
    ReadHoldingRegisters -> 2
    ReadInputRegisters -> 3
    WriteSingleCoil -> 4
    WriteSingleRegister -> 5
    WriteMultipleCoils -> 6
    WriteMultipleRegisters -> 7
    ReadWriteMultipleRegisters -> 8
    MaskWriteRegister -> 9
  }
}

/// Decode from a C-ABI tag value.
pub fn function_code_from_int(tag: Int) -> Result(FunctionCode, Nil) {
  case tag {
    0 -> Ok(ReadCoils)
    1 -> Ok(ReadDiscreteInputs)
    2 -> Ok(ReadHoldingRegisters)
    3 -> Ok(ReadInputRegisters)
    4 -> Ok(WriteSingleCoil)
    5 -> Ok(WriteSingleRegister)
    6 -> Ok(WriteMultipleCoils)
    7 -> Ok(WriteMultipleRegisters)
    8 -> Ok(ReadWriteMultipleRegisters)
    9 -> Ok(MaskWriteRegister)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ExceptionCode
// ===========================================================================

/// Modbus exception codes (Modbus Application Protocol Specification).
/// 
/// Matches `ExceptionCode` in the Modbus `abi.Types`.
pub type ExceptionCode {
  /// Illegal function code (tag 0).
  IllegalFunction
  /// Illegal data address (tag 1).
  IllegalDataAddress
  /// Illegal data value (tag 2).
  IllegalDataValue
  /// Slave device failure (tag 3).
  SlaveDeviceFailure
  /// Acknowledge — long-running operation in progress (tag 4).
  Acknowledge
  /// Slave device busy (tag 5).
  SlaveDeviceBusy
  /// Memory parity error (tag 6).
  MemoryParityError
  /// Gateway path unavailable (tag 7).
  GatewayPathUnavailable
  /// Gateway target device failed to respond (tag 8).
  GatewayTargetDeviceFailed
}

/// Convert a `ExceptionCode` to its C-ABI tag value.
pub fn exception_code_to_int(value: ExceptionCode) -> Int {
  case value {
    IllegalFunction -> 0
    IllegalDataAddress -> 1
    IllegalDataValue -> 2
    SlaveDeviceFailure -> 3
    Acknowledge -> 4
    SlaveDeviceBusy -> 5
    MemoryParityError -> 6
    GatewayPathUnavailable -> 7
    GatewayTargetDeviceFailed -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn exception_code_from_int(tag: Int) -> Result(ExceptionCode, Nil) {
  case tag {
    0 -> Ok(IllegalFunction)
    1 -> Ok(IllegalDataAddress)
    2 -> Ok(IllegalDataValue)
    3 -> Ok(SlaveDeviceFailure)
    4 -> Ok(Acknowledge)
    5 -> Ok(SlaveDeviceBusy)
    6 -> Ok(MemoryParityError)
    7 -> Ok(GatewayPathUnavailable)
    8 -> Ok(GatewayTargetDeviceFailed)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DeviceRole
// ===========================================================================

/// Modbus device role.
/// 
/// Matches `DeviceRole` in the Modbus `abi.Types`.
pub type DeviceRole {
  /// Master — initiates requests (tag 0).
  Master
  /// Slave — responds to requests (tag 1).
  Slave
}

/// Convert a `DeviceRole` to its C-ABI tag value.
pub fn device_role_to_int(value: DeviceRole) -> Int {
  case value {
    Master -> 0
    Slave -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn device_role_from_int(tag: Int) -> Result(DeviceRole, Nil) {
  case tag {
    0 -> Ok(Master)
    1 -> Ok(Slave)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// GatewayState
// ===========================================================================

/// Modbus TCP gateway lifecycle states.
/// 
/// Matches `GatewayState` in the Modbus `abi.Types`.
pub type GatewayState {
  /// No gateway active (tag 0).
  Idle
  /// Gateway listening for connections (tag 1).
  Listening
  /// Actively processing Modbus transactions (tag 2).
  Processing
  /// Error recovery state (tag 3).
  GatewayStateError
  /// Gateway shutting down (tag 4).
  Stopping
}

/// Convert a `GatewayState` to its C-ABI tag value.
pub fn gateway_state_to_int(value: GatewayState) -> Int {
  case value {
    Idle -> 0
    Listening -> 1
    Processing -> 2
    GatewayStateError -> 3
    Stopping -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn gateway_state_from_int(tag: Int) -> Result(GatewayState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Listening)
    2 -> Ok(Processing)
    3 -> Ok(GatewayStateError)
    4 -> Ok(Stopping)
    _ -> Error(Nil)
  }
}

