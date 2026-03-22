// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Modbus protocol types for proven-servers.

/// FunctionCode matching the Idris2 ABI tags.
public enum FunctionCode: UInt8, CaseIterable, Sendable {
    case readCoils = 0
    case readDiscreteInputs = 1
    case readHoldingRegisters = 2
    case readInputRegisters = 3
    case writeSingleCoil = 4
    case writeSingleRegister = 5
    case writeMultipleCoils = 6
    case writeMultipleRegisters = 7
    case readWriteMultipleRegisters = 8
    case maskWriteRegister = 9
}

/// ExceptionCode matching the Idris2 ABI tags.
public enum ExceptionCode: UInt8, CaseIterable, Sendable {
    case illegalFunction = 0
    case illegalDataAddress = 1
    case illegalDataValue = 2
    case slaveDeviceFailure = 3
    case acknowledge = 4
    case slaveDeviceBusy = 5
    case memoryParityError = 6
    case gatewayPathUnavailable = 7
    case gatewayTargetDeviceFailed = 8
}

/// DeviceRole matching the Idris2 ABI tags.
public enum DeviceRole: UInt8, CaseIterable, Sendable {
    case master = 0
    case slave = 1
}

/// GatewayState matching the Idris2 ABI tags.
public enum GatewayState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case listening = 1
    case processing = 2
    case error = 3
    case stopping = 4
}
