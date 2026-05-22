// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! Modbus protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `abi.Types` (Modbus) and its type definitions:
//! - `FunctionCode`  — Modbus function codes (10 constructors, tags 0-9)
//! - `ExceptionCode` — Modbus exception codes (9 constructors, tags 0-8)
//! - `DeviceRole`    — Master/Slave roles (2 constructors, tags 0-1)
//! - `GatewayState`  — Modbus TCP gateway lifecycle (5 constructors, tags 0-4)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Modbus Constants
// ===========================================================================

/// Standard Modbus TCP port (Modbus/TCP specification).
pub const MODBUS_TCP_PORT: u16 = 502;

/// Maximum number of coils in a single read request.
pub const MODBUS_MAX_COILS: u16 = 2000;

/// Maximum number of registers in a single read request.
pub const MODBUS_MAX_REGISTERS: u16 = 125;

// ===========================================================================
// FunctionCode (tags 0-9)
// ===========================================================================

/// Modbus function codes (Modbus Application Protocol Specification).
///
/// Matches `FunctionCode` in the Modbus `abi.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum FunctionCode {
    /// FC 01: Read coils (tag 0).
    ReadCoils = 0,
    /// FC 02: Read discrete inputs (tag 1).
    ReadDiscreteInputs = 1,
    /// FC 03: Read holding registers (tag 2).
    ReadHoldingRegisters = 2,
    /// FC 04: Read input registers (tag 3).
    ReadInputRegisters = 3,
    /// FC 05: Write single coil (tag 4).
    WriteSingleCoil = 4,
    /// FC 06: Write single register (tag 5).
    WriteSingleRegister = 5,
    /// FC 15: Write multiple coils (tag 6).
    WriteMultipleCoils = 6,
    /// FC 16: Write multiple registers (tag 7).
    WriteMultipleRegisters = 7,
    /// FC 23: Read/write multiple registers (tag 8).
    ReadWriteMultipleRegisters = 8,
    /// FC 22: Mask write register (tag 9).
    MaskWriteRegister = 9,
}

impl FunctionCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ReadCoils),
            1 => Some(Self::ReadDiscreteInputs),
            2 => Some(Self::ReadHoldingRegisters),
            3 => Some(Self::ReadInputRegisters),
            4 => Some(Self::WriteSingleCoil),
            5 => Some(Self::WriteSingleRegister),
            6 => Some(Self::WriteMultipleCoils),
            7 => Some(Self::WriteMultipleRegisters),
            8 => Some(Self::ReadWriteMultipleRegisters),
            9 => Some(Self::MaskWriteRegister),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this function code is a read operation.
    pub fn is_read(self) -> bool {
        matches!(
            self,
            Self::ReadCoils
                | Self::ReadDiscreteInputs
                | Self::ReadHoldingRegisters
                | Self::ReadInputRegisters
                | Self::ReadWriteMultipleRegisters
        )
    }

    /// Whether this function code is a write operation.
    pub fn is_write(self) -> bool {
        matches!(
            self,
            Self::WriteSingleCoil
                | Self::WriteSingleRegister
                | Self::WriteMultipleCoils
                | Self::WriteMultipleRegisters
                | Self::ReadWriteMultipleRegisters
                | Self::MaskWriteRegister
        )
    }

    /// Whether this function code operates on coils (bits).
    pub fn is_coil_operation(self) -> bool {
        matches!(
            self,
            Self::ReadCoils | Self::ReadDiscreteInputs
                | Self::WriteSingleCoil | Self::WriteMultipleCoils
        )
    }

    /// All supported function codes.
    pub const ALL: [FunctionCode; 10] = [
        Self::ReadCoils, Self::ReadDiscreteInputs, Self::ReadHoldingRegisters,
        Self::ReadInputRegisters, Self::WriteSingleCoil, Self::WriteSingleRegister,
        Self::WriteMultipleCoils, Self::WriteMultipleRegisters,
        Self::ReadWriteMultipleRegisters, Self::MaskWriteRegister,
    ];
}

impl fmt::Display for FunctionCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ExceptionCode (tags 0-8)
// ===========================================================================

/// Modbus exception codes (Modbus Application Protocol Specification).
///
/// Matches `ExceptionCode` in the Modbus `abi.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ExceptionCode {
    /// Illegal function code (tag 0).
    IllegalFunction = 0,
    /// Illegal data address (tag 1).
    IllegalDataAddress = 1,
    /// Illegal data value (tag 2).
    IllegalDataValue = 2,
    /// Slave device failure (tag 3).
    SlaveDeviceFailure = 3,
    /// Acknowledge — long-running operation in progress (tag 4).
    Acknowledge = 4,
    /// Slave device busy (tag 5).
    SlaveDeviceBusy = 5,
    /// Memory parity error (tag 6).
    MemoryParityError = 6,
    /// Gateway path unavailable (tag 7).
    GatewayPathUnavailable = 7,
    /// Gateway target device failed to respond (tag 8).
    GatewayTargetDeviceFailed = 8,
}

impl ExceptionCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::IllegalFunction),
            1 => Some(Self::IllegalDataAddress),
            2 => Some(Self::IllegalDataValue),
            3 => Some(Self::SlaveDeviceFailure),
            4 => Some(Self::Acknowledge),
            5 => Some(Self::SlaveDeviceBusy),
            6 => Some(Self::MemoryParityError),
            7 => Some(Self::GatewayPathUnavailable),
            8 => Some(Self::GatewayTargetDeviceFailed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this exception indicates the request can be retried.
    pub fn is_retryable(self) -> bool {
        matches!(self, Self::Acknowledge | Self::SlaveDeviceBusy)
    }

    /// Whether this exception relates to gateway operation.
    pub fn is_gateway_error(self) -> bool {
        matches!(self, Self::GatewayPathUnavailable | Self::GatewayTargetDeviceFailed)
    }

    /// All supported exception codes.
    pub const ALL: [ExceptionCode; 9] = [
        Self::IllegalFunction, Self::IllegalDataAddress, Self::IllegalDataValue,
        Self::SlaveDeviceFailure, Self::Acknowledge, Self::SlaveDeviceBusy,
        Self::MemoryParityError, Self::GatewayPathUnavailable,
        Self::GatewayTargetDeviceFailed,
    ];
}

impl fmt::Display for ExceptionCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for ExceptionCode {}

// ===========================================================================
// DeviceRole (tags 0-1)
// ===========================================================================

/// Modbus device role.
///
/// Matches `DeviceRole` in the Modbus `abi.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DeviceRole {
    /// Master — initiates requests (tag 0).
    Master = 0,
    /// Slave — responds to requests (tag 1).
    Slave = 1,
}

impl DeviceRole {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Master),
            1 => Some(Self::Slave),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

impl fmt::Display for DeviceRole {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// GatewayState (tags 0-4)
// ===========================================================================

/// Modbus TCP gateway lifecycle states.
///
/// Matches `GatewayState` in the Modbus `abi.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum GatewayState {
    /// No gateway active (tag 0).
    Idle = 0,
    /// Gateway listening for connections (tag 1).
    Listening = 1,
    /// Actively processing Modbus transactions (tag 2).
    Processing = 2,
    /// Error recovery state (tag 3).
    Error = 3,
    /// Gateway shutting down (tag 4).
    Stopping = 4,
}

impl GatewayState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Listening),
            2 => Some(Self::Processing),
            3 => Some(Self::Error),
            4 => Some(Self::Stopping),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the gateway is in a healthy operational state.
    pub fn is_healthy(self) -> bool {
        matches!(self, Self::Listening | Self::Processing)
    }

    /// Whether the gateway needs operator attention.
    pub fn needs_intervention(self) -> bool {
        matches!(self, Self::Error)
    }
}

impl fmt::Display for GatewayState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn function_code_roundtrip() {
        for fc in FunctionCode::ALL {
            let tag = fc.to_tag();
            let decoded = FunctionCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, fc);
        }
        assert!(FunctionCode::from_tag(10).is_none());
    }

    #[test]
    fn function_code_classification() {
        assert!(FunctionCode::ReadCoils.is_read());
        assert!(!FunctionCode::ReadCoils.is_write());
        assert!(FunctionCode::WriteSingleCoil.is_write());
        assert!(!FunctionCode::WriteSingleCoil.is_read());
        // ReadWriteMultipleRegisters is both read and write
        assert!(FunctionCode::ReadWriteMultipleRegisters.is_read());
        assert!(FunctionCode::ReadWriteMultipleRegisters.is_write());
        assert!(FunctionCode::ReadCoils.is_coil_operation());
        assert!(!FunctionCode::ReadHoldingRegisters.is_coil_operation());
    }

    #[test]
    fn exception_code_roundtrip() {
        for ec in ExceptionCode::ALL {
            let tag = ec.to_tag();
            let decoded = ExceptionCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ec);
        }
        assert!(ExceptionCode::from_tag(9).is_none());
    }

    #[test]
    fn exception_code_retryable() {
        assert!(ExceptionCode::Acknowledge.is_retryable());
        assert!(ExceptionCode::SlaveDeviceBusy.is_retryable());
        assert!(!ExceptionCode::IllegalFunction.is_retryable());
    }

    #[test]
    fn exception_code_gateway() {
        assert!(ExceptionCode::GatewayPathUnavailable.is_gateway_error());
        assert!(ExceptionCode::GatewayTargetDeviceFailed.is_gateway_error());
        assert!(!ExceptionCode::SlaveDeviceFailure.is_gateway_error());
    }

    #[test]
    fn device_role_roundtrip() {
        for tag in 0u8..=1 {
            let dr = DeviceRole::from_tag(tag).expect("valid tag");
            assert_eq!(dr.to_tag(), tag);
        }
        assert!(DeviceRole::from_tag(2).is_none());
    }

    #[test]
    fn gateway_state_roundtrip() {
        for tag in 0u8..=4 {
            let gs = GatewayState::from_tag(tag).expect("valid tag");
            assert_eq!(gs.to_tag(), tag);
        }
        assert!(GatewayState::from_tag(5).is_none());
    }

    #[test]
    fn gateway_state_health() {
        assert!(!GatewayState::Idle.is_healthy());
        assert!(GatewayState::Listening.is_healthy());
        assert!(GatewayState::Processing.is_healthy());
        assert!(!GatewayState::Error.is_healthy());
        assert!(GatewayState::Error.needs_intervention());
        assert!(!GatewayState::Listening.needs_intervention());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(MODBUS_TCP_PORT, 502);
    }
}
