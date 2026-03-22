// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Modbus protocol types for proven-servers.

/** FunctionCode matching the Idris2 ABI tags. */
export const FunctionCode = Object.freeze({
  READ_COILS: 0,
  READ_DISCRETE_INPUTS: 1,
  READ_HOLDING_REGISTERS: 2,
  READ_INPUT_REGISTERS: 3,
  WRITE_SINGLE_COIL: 4,
  WRITE_SINGLE_REGISTER: 5,
  WRITE_MULTIPLE_COILS: 6,
  WRITE_MULTIPLE_REGISTERS: 7,
  READ_WRITE_MULTIPLE_REGISTERS: 8,
  MASK_WRITE_REGISTER: 9,
});

/** ExceptionCode matching the Idris2 ABI tags. */
export const ExceptionCode = Object.freeze({
  ILLEGAL_FUNCTION: 0,
  ILLEGAL_DATA_ADDRESS: 1,
  ILLEGAL_DATA_VALUE: 2,
  SLAVE_DEVICE_FAILURE: 3,
  ACKNOWLEDGE: 4,
  SLAVE_DEVICE_BUSY: 5,
  MEMORY_PARITY_ERROR: 6,
  GATEWAY_PATH_UNAVAILABLE: 7,
  GATEWAY_TARGET_DEVICE_FAILED: 8,
});

/** DeviceRole matching the Idris2 ABI tags. */
export const DeviceRole = Object.freeze({
  MASTER: 0,
  SLAVE: 1,
});

/** GatewayState matching the Idris2 ABI tags. */
export const GatewayState = Object.freeze({
  IDLE: 0,
  LISTENING: 1,
  PROCESSING: 2,
  ERROR: 3,
  STOPPING: 4,
});
