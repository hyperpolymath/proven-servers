-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- abi.Types: C-ABI-compatible numeric representations of Modbus types.
--
-- Maps every constructor of the core Modbus sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/modbus.zig)
-- exactly.
--
-- Types covered:
--   FunctionCode   (10 constructors, tags 0-9)
--   ExceptionCode  (9 constructors, tags 0-8)
--   DeviceRole     (2 constructors, tags 0-1)
--   GatewayState   (5 constructors, tags 0-4)

module abi.Types

import Modbus.Types

%default total

---------------------------------------------------------------------------
-- FunctionCode (10 constructors, tags 0-9)
---------------------------------------------------------------------------

public export
functionCodeToTag : FunctionCode -> Bits8
functionCodeToTag ReadCoils                  = 0
functionCodeToTag ReadDiscreteInputs         = 1
functionCodeToTag ReadHoldingRegisters       = 2
functionCodeToTag ReadInputRegisters         = 3
functionCodeToTag WriteSingleCoil            = 4
functionCodeToTag WriteSingleRegister        = 5
functionCodeToTag WriteMultipleCoils         = 6
functionCodeToTag WriteMultipleRegisters     = 7
functionCodeToTag ReadWriteMultipleRegisters = 8
functionCodeToTag MaskWriteRegister          = 9

public export
tagToFunctionCode : Bits8 -> Maybe FunctionCode
tagToFunctionCode 0 = Just ReadCoils
tagToFunctionCode 1 = Just ReadDiscreteInputs
tagToFunctionCode 2 = Just ReadHoldingRegisters
tagToFunctionCode 3 = Just ReadInputRegisters
tagToFunctionCode 4 = Just WriteSingleCoil
tagToFunctionCode 5 = Just WriteSingleRegister
tagToFunctionCode 6 = Just WriteMultipleCoils
tagToFunctionCode 7 = Just WriteMultipleRegisters
tagToFunctionCode 8 = Just ReadWriteMultipleRegisters
tagToFunctionCode 9 = Just MaskWriteRegister
tagToFunctionCode _ = Nothing

public export
functionCodeRoundtrip : (f : FunctionCode) -> tagToFunctionCode (functionCodeToTag f) = Just f
functionCodeRoundtrip ReadCoils                  = Refl
functionCodeRoundtrip ReadDiscreteInputs         = Refl
functionCodeRoundtrip ReadHoldingRegisters       = Refl
functionCodeRoundtrip ReadInputRegisters         = Refl
functionCodeRoundtrip WriteSingleCoil            = Refl
functionCodeRoundtrip WriteSingleRegister        = Refl
functionCodeRoundtrip WriteMultipleCoils         = Refl
functionCodeRoundtrip WriteMultipleRegisters     = Refl
functionCodeRoundtrip ReadWriteMultipleRegisters = Refl
functionCodeRoundtrip MaskWriteRegister          = Refl

---------------------------------------------------------------------------
-- ExceptionCode (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
exceptionCodeToTag : ExceptionCode -> Bits8
exceptionCodeToTag IllegalFunction           = 0
exceptionCodeToTag IllegalDataAddress        = 1
exceptionCodeToTag IllegalDataValue          = 2
exceptionCodeToTag SlaveDeviceFailure        = 3
exceptionCodeToTag Acknowledge               = 4
exceptionCodeToTag SlaveDeviceBusy           = 5
exceptionCodeToTag MemoryParityError         = 6
exceptionCodeToTag GatewayPathUnavailable    = 7
exceptionCodeToTag GatewayTargetDeviceFailed = 8

public export
tagToExceptionCode : Bits8 -> Maybe ExceptionCode
tagToExceptionCode 0 = Just IllegalFunction
tagToExceptionCode 1 = Just IllegalDataAddress
tagToExceptionCode 2 = Just IllegalDataValue
tagToExceptionCode 3 = Just SlaveDeviceFailure
tagToExceptionCode 4 = Just Acknowledge
tagToExceptionCode 5 = Just SlaveDeviceBusy
tagToExceptionCode 6 = Just MemoryParityError
tagToExceptionCode 7 = Just GatewayPathUnavailable
tagToExceptionCode 8 = Just GatewayTargetDeviceFailed
tagToExceptionCode _ = Nothing

public export
exceptionCodeRoundtrip : (e : ExceptionCode) -> tagToExceptionCode (exceptionCodeToTag e) = Just e
exceptionCodeRoundtrip IllegalFunction           = Refl
exceptionCodeRoundtrip IllegalDataAddress        = Refl
exceptionCodeRoundtrip IllegalDataValue          = Refl
exceptionCodeRoundtrip SlaveDeviceFailure        = Refl
exceptionCodeRoundtrip Acknowledge               = Refl
exceptionCodeRoundtrip SlaveDeviceBusy           = Refl
exceptionCodeRoundtrip MemoryParityError         = Refl
exceptionCodeRoundtrip GatewayPathUnavailable    = Refl
exceptionCodeRoundtrip GatewayTargetDeviceFailed = Refl

---------------------------------------------------------------------------
-- DeviceRole (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
deviceRoleToTag : DeviceRole -> Bits8
deviceRoleToTag Master = 0
deviceRoleToTag Slave  = 1

public export
tagToDeviceRole : Bits8 -> Maybe DeviceRole
tagToDeviceRole 0 = Just Master
tagToDeviceRole 1 = Just Slave
tagToDeviceRole _ = Nothing

public export
deviceRoleRoundtrip : (d : DeviceRole) -> tagToDeviceRole (deviceRoleToTag d) = Just d
deviceRoleRoundtrip Master = Refl
deviceRoleRoundtrip Slave  = Refl

---------------------------------------------------------------------------
-- GatewayState (5 constructors, tags 0-4)
-- Composite lifecycle state used by the FFI for simplified management.
---------------------------------------------------------------------------

||| Modbus TCP gateway lifecycle states.
||| Used by the FFI layer for the C ABI.
public export
data GatewayState : Type where
  ||| No gateway active. Initial and terminal state.
  GSIdle        : GatewayState
  ||| Gateway listening for connections.
  GSListening   : GatewayState
  ||| Actively processing Modbus transactions.
  GSProcessing  : GatewayState
  ||| Error recovery state.
  GSError       : GatewayState
  ||| Gateway shutting down.
  GSStopping    : GatewayState

public export
Eq GatewayState where
  GSIdle       == GSIdle       = True
  GSListening  == GSListening  = True
  GSProcessing == GSProcessing = True
  GSError      == GSError      = True
  GSStopping   == GSStopping   = True
  _            == _            = False

public export
Show GatewayState where
  show GSIdle       = "Idle"
  show GSListening  = "Listening"
  show GSProcessing = "Processing"
  show GSError      = "Error"
  show GSStopping   = "Stopping"

public export
gatewayStateToTag : GatewayState -> Bits8
gatewayStateToTag GSIdle       = 0
gatewayStateToTag GSListening  = 1
gatewayStateToTag GSProcessing = 2
gatewayStateToTag GSError      = 3
gatewayStateToTag GSStopping   = 4

public export
tagToGatewayState : Bits8 -> Maybe GatewayState
tagToGatewayState 0 = Just GSIdle
tagToGatewayState 1 = Just GSListening
tagToGatewayState 2 = Just GSProcessing
tagToGatewayState 3 = Just GSError
tagToGatewayState 4 = Just GSStopping
tagToGatewayState _ = Nothing

public export
gatewayStateRoundtrip : (s : GatewayState) -> tagToGatewayState (gatewayStateToTag s) = Just s
gatewayStateRoundtrip GSIdle       = Refl
gatewayStateRoundtrip GSListening  = Refl
gatewayStateRoundtrip GSProcessing = Refl
gatewayStateRoundtrip GSError      = Refl
gatewayStateRoundtrip GSStopping   = Refl
