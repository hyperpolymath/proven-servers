<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Modbus protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** FunctionCode matching the Idris2 ABI tags. */
enum FunctionCode: int
{
    case ReadCoils = 0;
    case ReadDiscreteInputs = 1;
    case ReadHoldingRegisters = 2;
    case ReadInputRegisters = 3;
    case WriteSingleCoil = 4;
    case WriteSingleRegister = 5;
    case WriteMultipleCoils = 6;
    case WriteMultipleRegisters = 7;
    case ReadWriteMultipleRegisters = 8;
    case MaskWriteRegister = 9;
}

/** ExceptionCode matching the Idris2 ABI tags. */
enum ExceptionCode: int
{
    case IllegalFunction = 0;
    case IllegalDataAddress = 1;
    case IllegalDataValue = 2;
    case SlaveDeviceFailure = 3;
    case Acknowledge = 4;
    case SlaveDeviceBusy = 5;
    case MemoryParityError = 6;
    case GatewayPathUnavailable = 7;
    case GatewayTargetDeviceFailed = 8;
}

/** DeviceRole matching the Idris2 ABI tags. */
enum DeviceRole: int
{
    case Master = 0;
    case Slave = 1;
}

/** GatewayState matching the Idris2 ABI tags. */
enum GatewayState: int
{
    case Idle = 0;
    case Listening = 1;
    case Processing = 2;
    case Error = 3;
    case Stopping = 4;
}
