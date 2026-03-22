// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file modbus.hpp
/// @brief Modbus protocol types for proven-servers.

#ifndef PROVEN_MODBUS_HPP
#define PROVEN_MODBUS_HPP

#include <cstdint>

namespace proven {

/// @brief FunctionCode matching the Idris2 ABI tags.
enum class FunctionCode : uint8_t {
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
};

/// @brief ExceptionCode matching the Idris2 ABI tags.
enum class ExceptionCode : uint8_t {
    IllegalFunction = 0,
    IllegalDataAddress = 1,
    IllegalDataValue = 2,
    SlaveDeviceFailure = 3,
    Acknowledge = 4,
    SlaveDeviceBusy = 5,
    MemoryParityError = 6,
    GatewayPathUnavailable = 7,
    GatewayTargetDeviceFailed = 8
};

/// @brief DeviceRole matching the Idris2 ABI tags.
enum class DeviceRole : uint8_t {
    Master = 0,
    Slave = 1
};

/// @brief GatewayState matching the Idris2 ABI tags.
enum class GatewayState : uint8_t {
    Idle = 0,
    Listening = 1,
    Processing = 2,
    Error = 3,
    Stopping = 4
};

} // namespace proven

#endif // PROVEN_MODBUS_HPP
