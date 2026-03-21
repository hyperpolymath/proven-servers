// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenModbus protocol bindings.

open ProvenModbus

let test_functionCode_roundtrip = () => {
  assert(functionCodeFromTag(0) == Some(ReadCoils))
  assert(functionCodeFromTag(1) == Some(ReadDiscreteInputs))
  assert(functionCodeFromTag(2) == Some(ReadHoldingRegisters))
  assert(functionCodeFromTag(3) == Some(ReadInputRegisters))
  assert(functionCodeFromTag(4) == Some(WriteSingleCoil))
  assert(functionCodeFromTag(5) == Some(WriteSingleRegister))
  assert(functionCodeFromTag(6) == Some(WriteMultipleCoils))
  assert(functionCodeFromTag(7) == Some(WriteMultipleRegisters))
  assert(functionCodeFromTag(8) == Some(ReadWriteMultipleRegisters))
  assert(functionCodeFromTag(9) == Some(MaskWriteRegister))
  assert(functionCodeFromTag(10) == None)
}

let test_functionCode_toTag = () => {
  assert(functionCodeToTag(ReadCoils) == 0)
  assert(functionCodeToTag(ReadDiscreteInputs) == 1)
  assert(functionCodeToTag(ReadHoldingRegisters) == 2)
  assert(functionCodeToTag(ReadInputRegisters) == 3)
  assert(functionCodeToTag(WriteSingleCoil) == 4)
  assert(functionCodeToTag(WriteSingleRegister) == 5)
  assert(functionCodeToTag(WriteMultipleCoils) == 6)
  assert(functionCodeToTag(WriteMultipleRegisters) == 7)
  assert(functionCodeToTag(ReadWriteMultipleRegisters) == 8)
  assert(functionCodeToTag(MaskWriteRegister) == 9)
}

let test_exceptionCode_roundtrip = () => {
  assert(exceptionCodeFromTag(0) == Some(IllegalFunction))
  assert(exceptionCodeFromTag(1) == Some(IllegalDataAddress))
  assert(exceptionCodeFromTag(2) == Some(IllegalDataValue))
  assert(exceptionCodeFromTag(3) == Some(SlaveDeviceFailure))
  assert(exceptionCodeFromTag(4) == Some(Acknowledge))
  assert(exceptionCodeFromTag(5) == Some(SlaveDeviceBusy))
  assert(exceptionCodeFromTag(6) == Some(MemoryParityError))
  assert(exceptionCodeFromTag(7) == Some(GatewayPathUnavailable))
  assert(exceptionCodeFromTag(8) == Some(GatewayTargetDeviceFailed))
  assert(exceptionCodeFromTag(9) == None)
}

let test_exceptionCode_toTag = () => {
  assert(exceptionCodeToTag(IllegalFunction) == 0)
  assert(exceptionCodeToTag(IllegalDataAddress) == 1)
  assert(exceptionCodeToTag(IllegalDataValue) == 2)
  assert(exceptionCodeToTag(SlaveDeviceFailure) == 3)
  assert(exceptionCodeToTag(Acknowledge) == 4)
  assert(exceptionCodeToTag(SlaveDeviceBusy) == 5)
  assert(exceptionCodeToTag(MemoryParityError) == 6)
  assert(exceptionCodeToTag(GatewayPathUnavailable) == 7)
  assert(exceptionCodeToTag(GatewayTargetDeviceFailed) == 8)
}

let test_deviceRole_roundtrip = () => {
  assert(deviceRoleFromTag(0) == Some(Master))
  assert(deviceRoleFromTag(1) == Some(Slave))
  assert(deviceRoleFromTag(2) == None)
}

let test_deviceRole_toTag = () => {
  assert(deviceRoleToTag(Master) == 0)
  assert(deviceRoleToTag(Slave) == 1)
}

let test_gatewayState_roundtrip = () => {
  assert(gatewayStateFromTag(0) == Some(Idle))
  assert(gatewayStateFromTag(1) == Some(Listening))
  assert(gatewayStateFromTag(2) == Some(Processing))
  assert(gatewayStateFromTag(3) == Some(Error))
  assert(gatewayStateFromTag(4) == Some(Stopping))
  assert(gatewayStateFromTag(5) == None)
}

let test_gatewayState_toTag = () => {
  assert(gatewayStateToTag(Idle) == 0)
  assert(gatewayStateToTag(Listening) == 1)
  assert(gatewayStateToTag(Processing) == 2)
  assert(gatewayStateToTag(Error) == 3)
  assert(gatewayStateToTag(Stopping) == 4)
}

// Run all tests
test_functionCode_roundtrip()
test_functionCode_toTag()
test_exceptionCode_roundtrip()
test_exceptionCode_toTag()
test_deviceRole_roundtrip()
test_deviceRole_toTag()
test_gatewayState_roundtrip()
test_gatewayState_toTag()
