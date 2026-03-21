-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Modbus protocol types for proven-servers.
--
-- Modbus industrial protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Modbus
  ( -- * ADT types matching Idris2 ABI
      FunctionCode(..)
    , ExceptionCode(..)
    , DeviceRole(..)
    , GatewayState(..)
    , functionCodeToTag
    , functionCodeFromTag
    , exceptionCodeToTag
    , exceptionCodeFromTag
    , deviceRoleToTag
    , deviceRoleFromTag
    , gatewayStateToTag
    , gatewayStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- FunctionCode
-- ---------------------------------------------------------------------------

-- | FunctionCode type matching the Idris2 ABI.
--
-- Tags 0-9 (10 constructors).
data FunctionCode
  = ReadCoils  -- ^ Tag 0.
  | ReadDiscreteInputs  -- ^ Tag 1.
  | ReadHoldingRegisters  -- ^ Tag 2.
  | ReadInputRegisters  -- ^ Tag 3.
  | WriteSingleCoil  -- ^ Tag 4.
  | WriteSingleRegister  -- ^ Tag 5.
  | WriteMultipleCoils  -- ^ Tag 6.
  | WriteMultipleRegisters  -- ^ Tag 7.
  | ReadWriteMultipleRegisters  -- ^ Tag 8.
  | MaskWriteRegister  -- ^ Tag 9.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'FunctionCode' to its ABI tag value.
functionCodeToTag :: FunctionCode -> Word8
functionCodeToTag = fromIntegral . fromEnum

-- | Decode a 'FunctionCode' from its ABI tag value.
functionCodeFromTag :: Word8 -> Maybe FunctionCode
functionCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FunctionCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ExceptionCode
-- ---------------------------------------------------------------------------

-- | ExceptionCode type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data ExceptionCode
  = IllegalFunction  -- ^ Tag 0.
  | IllegalDataAddress  -- ^ Tag 1.
  | IllegalDataValue  -- ^ Tag 2.
  | SlaveDeviceFailure  -- ^ Tag 3.
  | Acknowledge  -- ^ Tag 4.
  | SlaveDeviceBusy  -- ^ Tag 5.
  | MemoryParityError  -- ^ Tag 6.
  | GatewayPathUnavailable  -- ^ Tag 7.
  | GatewayTargetDeviceFailed  -- ^ Tag 8.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ExceptionCode' to its ABI tag value.
exceptionCodeToTag :: ExceptionCode -> Word8
exceptionCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ExceptionCode' from its ABI tag value.
exceptionCodeFromTag :: Word8 -> Maybe ExceptionCode
exceptionCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ExceptionCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DeviceRole
-- ---------------------------------------------------------------------------

-- | DeviceRole type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data DeviceRole
  = Master  -- ^ Tag 0.
  | Slave  -- ^ Tag 1.
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

-- | GatewayState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data GatewayState
  = Idle  -- ^ Tag 0.
  | Listening  -- ^ Tag 1.
  | Processing  -- ^ Tag 2.
  | Error  -- ^ Tag 3.
  | Stopping  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'GatewayState' to its ABI tag value.
gatewayStateToTag :: GatewayState -> Word8
gatewayStateToTag = fromIntegral . fromEnum

-- | Decode a 'GatewayState' from its ABI tag value.
gatewayStateFromTag :: Word8 -> Maybe GatewayState
gatewayStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: GatewayState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
