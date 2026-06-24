-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ModbusABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into modbus_abi_gen.zig for the comptime guard.

module ModbusABI.Emit

import Modbus.Types
import ModbusABI.Types
import ModbusABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "FUNC" "READ_COILS"                    (functionCodeToTag ReadCoils)
  , line "FUNC" "READ_DISCRETE_INPUTS"          (functionCodeToTag ReadDiscreteInputs)
  , line "FUNC" "READ_HOLDING_REGISTERS"        (functionCodeToTag ReadHoldingRegisters)
  , line "FUNC" "READ_INPUT_REGISTERS"          (functionCodeToTag ReadInputRegisters)
  , line "FUNC" "WRITE_SINGLE_COIL"             (functionCodeToTag WriteSingleCoil)
  , line "FUNC" "WRITE_SINGLE_REGISTER"         (functionCodeToTag WriteSingleRegister)
  , line "FUNC" "WRITE_MULTIPLE_COILS"          (functionCodeToTag WriteMultipleCoils)
  , line "FUNC" "WRITE_MULTIPLE_REGISTERS"      (functionCodeToTag WriteMultipleRegisters)
  , line "FUNC" "READ_WRITE_MULTIPLE_REGISTERS" (functionCodeToTag ReadWriteMultipleRegisters)
  , line "FUNC" "MASK_WRITE_REGISTER"           (functionCodeToTag MaskWriteRegister)
  , line "EXC" "ILLEGAL_FUNCTION"               (exceptionCodeToTag IllegalFunction)
  , line "EXC" "ILLEGAL_DATA_ADDRESS"           (exceptionCodeToTag IllegalDataAddress)
  , line "EXC" "ILLEGAL_DATA_VALUE"             (exceptionCodeToTag IllegalDataValue)
  , line "EXC" "SLAVE_DEVICE_FAILURE"           (exceptionCodeToTag SlaveDeviceFailure)
  , line "EXC" "ACKNOWLEDGE"                     (exceptionCodeToTag Acknowledge)
  , line "EXC" "SLAVE_DEVICE_BUSY"              (exceptionCodeToTag SlaveDeviceBusy)
  , line "EXC" "MEMORY_PARITY_ERROR"            (exceptionCodeToTag MemoryParityError)
  , line "EXC" "GATEWAY_PATH_UNAVAILABLE"       (exceptionCodeToTag GatewayPathUnavailable)
  , line "EXC" "GATEWAY_TARGET_DEVICE_FAILED"   (exceptionCodeToTag GatewayTargetDeviceFailed)
  , line "ROLE" "MASTER" (deviceRoleToTag Master)
  , line "ROLE" "SLAVE"  (deviceRoleToTag Slave)
  , line "GW" "IDLE"       (gatewayStateToTag GSIdle)
  , line "GW" "LISTENING"  (gatewayStateToTag GSListening)
  , line "GW" "PROCESSING" (gatewayStateToTag GSProcessing)
  , line "GW" "ERR"        (gatewayStateToTag GSError)
  , line "GW" "STOPPING"   (gatewayStateToTag GSStopping)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
