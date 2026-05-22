// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Modbus protocol types for proven-servers.

namespace Proven;

/// <summary>FunctionCode matching the Idris2 ABI tags (0-9).</summary>
public enum FunctionCode : byte
{
    ReadCoils = 0,
    ReadDiscreteInputs = 1,
    ReadHoldingRegisters = 2,
    ReadInputRegisters = 3,
    WriteSingleCoil = 4,
    WriteSingleRegister = 5,
    WriteMultipleCoils = 6,
    WriteMultipleRegisters = 7,
    ReadWriteMultipleRegisters = 8,
    MaskWriteRegister = 9
}

/// <summary>ExceptionCode matching the Idris2 ABI tags (0-8).</summary>
public enum ExceptionCode : byte
{
    IllegalFunction = 0,
    IllegalDataAddress = 1,
    IllegalDataValue = 2,
    SlaveDeviceFailure = 3,
    Acknowledge = 4,
    SlaveDeviceBusy = 5,
    MemoryParityError = 6,
    GatewayPathUnavailable = 7,
    GatewayTargetDeviceFailed = 8
}

/// <summary>DeviceRole matching the Idris2 ABI tags (0-1).</summary>
public enum DeviceRole : byte
{
    Master = 0,
    Slave = 1
}

/// <summary>GatewayState matching the Idris2 ABI tags (0-4).</summary>
public enum GatewayState : byte
{
    Idle = 0,
    Listening = 1,
    Processing = 2,
    Error = 3,
    Stopping = 4
}
