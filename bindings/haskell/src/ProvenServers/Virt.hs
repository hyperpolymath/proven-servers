-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Virtualization protocol types for proven-servers.
--
-- Virtualization/hypervisor types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Virt
  ( -- * ADT types matching Idris2 ABI
      VmState(..)
    , VirtOperation(..)
    , DiskFormat(..)
    , NetworkType(..)
    , BootDevice(..)
    , vmStateToTag
    , vmStateFromTag
    , virtOperationToTag
    , virtOperationFromTag
    , diskFormatToTag
    , diskFormatFromTag
    , networkTypeToTag
    , networkTypeFromTag
    , bootDeviceToTag
    , bootDeviceFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- VmState
-- ---------------------------------------------------------------------------

-- | VmState type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data VmState
  = Creating  -- ^ Tag 0.
  | Running  -- ^ Tag 1.
  | Paused  -- ^ Tag 2.
  | Suspended  -- ^ Tag 3.
  | ShuttingDown  -- ^ Tag 4.
  | Stopped  -- ^ Tag 5.
  | Crashed  -- ^ Tag 6.
  | Migrating  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'VmState' to its ABI tag value.
vmStateToTag :: VmState -> Word8
vmStateToTag = fromIntegral . fromEnum

-- | Decode a 'VmState' from its ABI tag value.
vmStateFromTag :: Word8 -> Maybe VmState
vmStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: VmState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- VirtOperation
-- ---------------------------------------------------------------------------

-- | VirtOperation type matching the Idris2 ABI.
--
-- Tags 0-10 (11 constructors).
data VirtOperation
  = Create  -- ^ Tag 0.
  | Start  -- ^ Tag 1.
  | Stop  -- ^ Tag 2.
  | Restart  -- ^ Tag 3.
  | Pause  -- ^ Tag 4.
  | Resume  -- ^ Tag 5.
  | Suspend  -- ^ Tag 6.
  | Migrate  -- ^ Tag 7.
  | Snapshot  -- ^ Tag 8.
  | Clone  -- ^ Tag 9.
  | Delete  -- ^ Tag 10.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'VirtOperation' to its ABI tag value.
virtOperationToTag :: VirtOperation -> Word8
virtOperationToTag = fromIntegral . fromEnum

-- | Decode a 'VirtOperation' from its ABI tag value.
virtOperationFromTag :: Word8 -> Maybe VirtOperation
virtOperationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: VirtOperation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DiskFormat
-- ---------------------------------------------------------------------------

-- | DiskFormat type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data DiskFormat
  = Raw  -- ^ Tag 0.
  | Qcow2  -- ^ Tag 1.
  | Vdi  -- ^ Tag 2.
  | Vmdk  -- ^ Tag 3.
  | Vhd  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DiskFormat' to its ABI tag value.
diskFormatToTag :: DiskFormat -> Word8
diskFormatToTag = fromIntegral . fromEnum

-- | Decode a 'DiskFormat' from its ABI tag value.
diskFormatFromTag :: Word8 -> Maybe DiskFormat
diskFormatFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DiskFormat)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NetworkType
-- ---------------------------------------------------------------------------

-- | NetworkType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data NetworkType
  = Nat  -- ^ Tag 0.
  | Bridged  -- ^ Tag 1.
  | Internal  -- ^ Tag 2.
  | HostOnly  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NetworkType' to its ABI tag value.
networkTypeToTag :: NetworkType -> Word8
networkTypeToTag = fromIntegral . fromEnum

-- | Decode a 'NetworkType' from its ABI tag value.
networkTypeFromTag :: Word8 -> Maybe NetworkType
networkTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NetworkType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- BootDevice
-- ---------------------------------------------------------------------------

-- | BootDevice type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data BootDevice
  = HardDisk  -- ^ Tag 0.
  | Cdrom  -- ^ Tag 1.
  | Network  -- ^ Tag 2.
  | Usb  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BootDevice' to its ABI tag value.
bootDeviceToTag :: BootDevice -> Word8
bootDeviceToTag = fromIntegral . fromEnum

-- | Decode a 'BootDevice' from its ABI tag value.
bootDeviceFromTag :: Word8 -> Maybe BootDevice
bootDeviceFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BootDevice)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
