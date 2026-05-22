// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Modbus protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// FunctionCode represents the FunctionCode type (Idris2 ABI tags).
type FunctionCode uint8

const (
	FunctionCodeReadCoils FunctionCode = iota
	FunctionCodeReadDiscreteInputs
	FunctionCodeReadHoldingRegisters
	FunctionCodeReadInputRegisters
	FunctionCodeWriteSingleCoil
	FunctionCodeWriteSingleRegister
	FunctionCodeWriteMultipleCoils
	FunctionCodeWriteMultipleRegisters
	FunctionCodeReadWriteMultipleRegisters
	FunctionCodeMaskWriteRegister
)

// ExceptionCode represents the ExceptionCode type (Idris2 ABI tags).
type ExceptionCode uint8

const (
	ExceptionCodeIllegalFunction ExceptionCode = iota
	ExceptionCodeIllegalDataAddress
	ExceptionCodeIllegalDataValue
	ExceptionCodeSlaveDeviceFailure
	ExceptionCodeAcknowledge
	ExceptionCodeSlaveDeviceBusy
	ExceptionCodeMemoryParityError
	ExceptionCodeGatewayPathUnavailable
	ExceptionCodeGatewayTargetDeviceFailed
)

// DeviceRole represents the DeviceRole type (Idris2 ABI tags).
type DeviceRole uint8

const (
	DeviceRoleMaster DeviceRole = iota
	DeviceRoleSlave
)

// GatewayState represents the GatewayState type (Idris2 ABI tags).
type GatewayState uint8

const (
	GatewayStateIdle GatewayState = iota
	GatewayStateListening
	GatewayStateProcessing
	GatewayStateError
	GatewayStateStopping
)
