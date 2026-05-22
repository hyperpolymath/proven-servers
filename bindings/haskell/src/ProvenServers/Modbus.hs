-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Modbus protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Modbus
  (
    modbusTcpPort
  , modbusMaxCoils
  , modbusMaxRegisters
  , FunctionCode(..)
  , functionCodeToTag
  , functionCodeFromTag
  , isRead
  , isWrite
  , isCoilOperation
  , ExceptionCode(..)
  , exceptionCodeToTag
  , exceptionCodeFromTag
  , isRetryable
  , isGatewayError
  , DeviceRole(..)
  , deviceRoleToTag
  , deviceRoleFromTag
  , GatewayState(..)
  , gatewayStateToTag
  , gatewayStateFromTag
  , isHealthy
  , needsIntervention
  ) where

import Data.Word (Word16, Word8)

-- | Standard Modbus TCP port (Modbus/TCP specification).
modbusTcpPort :: Word16
modbusTcpPort = 502

-- | Maximum number of coils in a single read request.
modbusMaxCoils :: Word16
modbusMaxCoils = 2000

-- | Maximum number of registers in a single read request.
modbusMaxRegisters :: Word16
modbusMaxRegisters = 125

-- ---------------------------------------------------------------------------
-- FunctionCode
-- ---------------------------------------------------------------------------

-- | Maximum number of registers in a single read request.
--
-- Tags 0-9 (10 constructors).
data FunctionCode
  = ReadCoils  -- ^ FC 01: Read coils (tag 0).
  | ReadDiscreteInputs  -- ^ FC 02: Read discrete inputs (tag 1).
  | ReadHoldingRegisters  -- ^ FC 03: Read holding registers (tag 2).
  | ReadInputRegisters  -- ^ FC 04: Read input registers (tag 3).
  | WriteSingleCoil  -- ^ FC 05: Write single coil (tag 4).
  | WriteSingleRegister  -- ^ FC 06: Write single register (tag 5).
  | WriteMultipleCoils  -- ^ FC 15: Write multiple coils (tag 6).
  | WriteMultipleRegisters  -- ^ FC 16: Write multiple registers (tag 7).
  | ReadWriteMultipleRegisters  -- ^ FC 23: Read/write multiple registers (tag 8).
  | MaskWriteRegister  -- ^ FC 22: Mask write register (tag 9).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'FunctionCode' to its ABI tag value.
functionCodeToTag :: FunctionCode -> Word8
functionCodeToTag = fromIntegral . fromEnum

-- | Decode a 'FunctionCode' from its ABI tag value.
functionCodeFromTag :: Word8 -> Maybe FunctionCode
functionCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FunctionCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this function code is a read operation.
isRead :: FunctionCode -> Bool
isRead ReadCoils = True
isRead ReadDiscreteInputs = True
isRead ReadHoldingRegisters = True
isRead ReadInputRegisters = True
isRead ReadWriteMultipleRegisters = True
isRead _ = False

-- | Whether this function code is a write operation.
isWrite :: FunctionCode -> Bool
isWrite WriteSingleCoil = True
isWrite WriteSingleRegister = True
isWrite WriteMultipleCoils = True
isWrite WriteMultipleRegisters = True
isWrite ReadWriteMultipleRegisters = True
isWrite MaskWriteRegister = True
isWrite _ = False

-- | Whether this function code operates on coils (bits).
isCoilOperation :: FunctionCode -> Bool
isCoilOperation ReadCoils = True
isCoilOperation ReadDiscreteInputs = True
isCoilOperation WriteSingleCoil = True
isCoilOperation WriteMultipleCoils = True
isCoilOperation _ = False

-- ---------------------------------------------------------------------------
-- ExceptionCode
-- ---------------------------------------------------------------------------

-- | Modbus exception codes (Modbus Application Protocol Specification).
--
-- Tags 0-8 (9 constructors).
data ExceptionCode
  = IllegalFunction  -- ^ Illegal function code (tag 0).
  | IllegalDataAddress  -- ^ Illegal data address (tag 1).
  | IllegalDataValue  -- ^ Illegal data value (tag 2).
  | SlaveDeviceFailure  -- ^ Slave device failure (tag 3).
  | Acknowledge  -- ^ Acknowledge — long-running operation in progress (tag 4).
  | SlaveDeviceBusy  -- ^ Slave device busy (tag 5).
  | MemoryParityError  -- ^ Memory parity error (tag 6).
  | GatewayPathUnavailable  -- ^ Gateway path unavailable (tag 7).
  | GatewayTargetDeviceFailed  -- ^ Gateway target device failed to respond (tag 8).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ExceptionCode' to its ABI tag value.
exceptionCodeToTag :: ExceptionCode -> Word8
exceptionCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ExceptionCode' from its ABI tag value.
exceptionCodeFromTag :: Word8 -> Maybe ExceptionCode
exceptionCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ExceptionCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this exception indicates the request can be retried.
isRetryable :: ExceptionCode -> Bool
isRetryable Acknowledge = True
isRetryable SlaveDeviceBusy = True
isRetryable _ = False

-- | Whether this exception relates to gateway operation.
isGatewayError :: ExceptionCode -> Bool
isGatewayError GatewayPathUnavailable = True
isGatewayError GatewayTargetDeviceFailed = True
isGatewayError _ = False

-- ---------------------------------------------------------------------------
-- DeviceRole
-- ---------------------------------------------------------------------------

-- | Modbus device role.
--
-- Tags 0-1 (2 constructors).
data DeviceRole
  = Master  -- ^ Master — initiates requests (tag 0).
  | Slave  -- ^ Slave — responds to requests (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DeviceRole' to its ABI tag value.
deviceRoleToTag :: DeviceRole -> Word8
deviceRoleToTag = fromIntegral . fromEnum

-- | Decode a 'DeviceRole' from its ABI tag value.
deviceRoleFromTag :: Word8 -> Maybe DeviceRole
deviceRoleFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DeviceRole)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- GatewayState
-- ---------------------------------------------------------------------------

-- | Modbus TCP gateway lifecycle states.
--
-- Tags 0-4 (5 constructors).
data GatewayState
  = Idle  -- ^ No gateway active (tag 0).
  | Listening  -- ^ Gateway listening for connections (tag 1).
  | Processing  -- ^ Actively processing Modbus transactions (tag 2).
  | Error  -- ^ Error recovery state (tag 3).
  | Stopping  -- ^ Gateway shutting down (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'GatewayState' to its ABI tag value.
gatewayStateToTag :: GatewayState -> Word8
gatewayStateToTag = fromIntegral . fromEnum

-- | Decode a 'GatewayState' from its ABI tag value.
gatewayStateFromTag :: Word8 -> Maybe GatewayState
gatewayStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: GatewayState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the gateway is in a healthy operational state.
isHealthy :: GatewayState -> Bool
isHealthy Listening = True
isHealthy Processing = True
isHealthy _ = False

-- | Whether the gateway needs operator attention.
needsIntervention :: GatewayState -> Bool
needsIntervention Error = True
needsIntervention _ = False
