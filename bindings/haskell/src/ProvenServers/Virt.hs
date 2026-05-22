-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Virtualization types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Virt
  (
    VmState(..)
  , vmStateToTag
  , vmStateFromTag
  , VirtOperation(..)
  , virtOperationToTag
  , virtOperationFromTag
  , DiskFormat(..)
  , diskFormatToTag
  , diskFormatFromTag
  , NetworkType(..)
  , networkTypeToTag
  , networkTypeFromTag
  , BootDevice(..)
  , bootDeviceToTag
  , bootDeviceFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- VmState
-- ---------------------------------------------------------------------------

-- | VM lifecycle states.
--
-- Tags 0-7 (8 constructors).
data VmState
  = Creating  -- ^ Creating (tag 0).
  | Running  -- ^ Running (tag 1).
  | Paused  -- ^ Paused (tag 2).
  | Suspended  -- ^ Suspended (tag 3).
  | ShuttingDown  -- ^ ShuttingDown (tag 4).
  | Stopped  -- ^ Stopped (tag 5).
  | Crashed  -- ^ Crashed (tag 6).
  | Migrating  -- ^ Migrating (tag 7).
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

-- | VM operations.
--
-- Tags 0-10 (11 constructors).
data VirtOperation
  = Create  -- ^ Create (tag 0).
  | Start  -- ^ Start (tag 1).
  | Stop  -- ^ Stop (tag 2).
  | Restart  -- ^ Restart (tag 3).
  | Pause  -- ^ Pause (tag 4).
  | Resume  -- ^ Resume (tag 5).
  | Suspend  -- ^ Suspend (tag 6).
  | Migrate  -- ^ Migrate (tag 7).
  | Snapshot  -- ^ Snapshot (tag 8).
  | Clone  -- ^ Clone (tag 9).
  | Delete  -- ^ Delete (tag 10).
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

-- | Virtual disk formats.
--
-- Tags 0-4 (5 constructors).
data DiskFormat
  = Raw  -- ^ Raw (tag 0).
  | Qcow2  -- ^ QCOW2 (tag 1).
  | Vdi  -- ^ VDI (tag 2).
  | Vmdk  -- ^ VMDK (tag 3).
  | Vhd  -- ^ VHD (tag 4).
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

-- | VM network types.
--
-- Tags 0-3 (4 constructors).
data NetworkType
  = Nat  -- ^ NAT (tag 0).
  | Bridged  -- ^ Bridged (tag 1).
  | Internal  -- ^ Internal (tag 2).
  | HostOnly  -- ^ HostOnly (tag 3).
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

-- | VM boot devices.
--
-- Tags 0-3 (4 constructors).
data BootDevice
  = HardDisk  -- ^ HardDisk (tag 0).
  | Cdrom  -- ^ CD-ROM (tag 1).
  | Network  -- ^ Network (tag 2).
  | Usb  -- ^ USB (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BootDevice' to its ABI tag value.
bootDeviceToTag :: BootDevice -> Word8
bootDeviceToTag = fromIntegral . fromEnum

-- | Decode a 'BootDevice' from its ABI tag value.
bootDeviceFromTag :: Word8 -> Maybe BootDevice
bootDeviceFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BootDevice)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
