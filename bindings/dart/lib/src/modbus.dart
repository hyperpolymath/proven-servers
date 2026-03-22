// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Modbus protocol types for proven-servers.

/// FunctionCode matching the Idris2 ABI tags.
enum FunctionCode {
  readCoils(0),
  readDiscreteInputs(1),
  readHoldingRegisters(2),
  readInputRegisters(3),
  writeSingleCoil(4),
  writeSingleRegister(5),
  writeMultipleCoils(6),
  writeMultipleRegisters(7),
  readWriteMultipleRegisters(8),
  maskWriteRegister(9);

  const FunctionCode(this.tag);
  final int tag;

  static FunctionCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ExceptionCode matching the Idris2 ABI tags.
enum ExceptionCode {
  illegalFunction(0),
  illegalDataAddress(1),
  illegalDataValue(2),
  slaveDeviceFailure(3),
  acknowledge(4),
  slaveDeviceBusy(5),
  memoryParityError(6),
  gatewayPathUnavailable(7),
  gatewayTargetDeviceFailed(8);

  const ExceptionCode(this.tag);
  final int tag;

  static ExceptionCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DeviceRole matching the Idris2 ABI tags.
enum DeviceRole {
  master(0),
  slave(1);

  const DeviceRole(this.tag);
  final int tag;

  static DeviceRole? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// GatewayState matching the Idris2 ABI tags.
enum GatewayState {
  idle(0),
  listening(1),
  processing(2),
  error(3),
  stopping(4);

  const GatewayState(this.tag);
  final int tag;

  static GatewayState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
