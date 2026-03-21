-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- VirtABI Types: C-ABI-compatible numeric representations of Virt types.
--
-- Maps every constructor of the core Virt sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/virt.zig) exactly.
--
-- Types covered:
--   VMState     (8 constructors, tags 0-7)
--   Operation   (11 constructors, tags 0-10)
--   DiskFormat  (5 constructors, tags 0-4)
--   NetworkType (4 constructors, tags 0-3)
--   BootDevice  (4 constructors, tags 0-3)

module VirtABI.Types

import Virt.Types

%default total

---------------------------------------------------------------------------
-- VMState (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
vmStateSize : Nat
vmStateSize = 1

||| Encode a VMState to its ABI tag value.
public export
vmStateToTag : VMState -> Bits8
vmStateToTag Creating     = 0
vmStateToTag Running      = 1
vmStateToTag Paused       = 2
vmStateToTag Suspended    = 3
vmStateToTag ShuttingDown = 4
vmStateToTag Stopped      = 5
vmStateToTag Crashed      = 6
vmStateToTag Migrating    = 7

||| Decode an ABI tag to a VMState.
public export
tagToVMState : Bits8 -> Maybe VMState
tagToVMState 0 = Just Creating
tagToVMState 1 = Just Running
tagToVMState 2 = Just Paused
tagToVMState 3 = Just Suspended
tagToVMState 4 = Just ShuttingDown
tagToVMState 5 = Just Stopped
tagToVMState 6 = Just Crashed
tagToVMState 7 = Just Migrating
tagToVMState _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all VMState values.
public export
vmStateRoundtrip : (v : VMState) -> tagToVMState (vmStateToTag v) = Just v
vmStateRoundtrip Creating     = Refl
vmStateRoundtrip Running      = Refl
vmStateRoundtrip Paused       = Refl
vmStateRoundtrip Suspended    = Refl
vmStateRoundtrip ShuttingDown = Refl
vmStateRoundtrip Stopped      = Refl
vmStateRoundtrip Crashed      = Refl
vmStateRoundtrip Migrating    = Refl

---------------------------------------------------------------------------
-- Operation (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
operationSize : Nat
operationSize = 1

||| Encode an Operation to its ABI tag value.
public export
operationToTag : Operation -> Bits8
operationToTag Create   = 0
operationToTag Start    = 1
operationToTag Stop     = 2
operationToTag Restart  = 3
operationToTag Pause    = 4
operationToTag Resume   = 5
operationToTag Suspend  = 6
operationToTag Migrate  = 7
operationToTag Snapshot = 8
operationToTag Clone    = 9
operationToTag Delete   = 10

||| Decode an ABI tag to an Operation.
public export
tagToOperation : Bits8 -> Maybe Operation
tagToOperation 0  = Just Create
tagToOperation 1  = Just Start
tagToOperation 2  = Just Stop
tagToOperation 3  = Just Restart
tagToOperation 4  = Just Pause
tagToOperation 5  = Just Resume
tagToOperation 6  = Just Suspend
tagToOperation 7  = Just Migrate
tagToOperation 8  = Just Snapshot
tagToOperation 9  = Just Clone
tagToOperation 10 = Just Delete
tagToOperation _  = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all Operation values.
public export
operationRoundtrip : (o : Operation) -> tagToOperation (operationToTag o) = Just o
operationRoundtrip Create   = Refl
operationRoundtrip Start    = Refl
operationRoundtrip Stop     = Refl
operationRoundtrip Restart  = Refl
operationRoundtrip Pause    = Refl
operationRoundtrip Resume   = Refl
operationRoundtrip Suspend  = Refl
operationRoundtrip Migrate  = Refl
operationRoundtrip Snapshot = Refl
operationRoundtrip Clone    = Refl
operationRoundtrip Delete   = Refl

---------------------------------------------------------------------------
-- DiskFormat (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
diskFormatSize : Nat
diskFormatSize = 1

||| Encode a DiskFormat to its ABI tag value.
public export
diskFormatToTag : DiskFormat -> Bits8
diskFormatToTag Raw   = 0
diskFormatToTag QCOW2 = 1
diskFormatToTag VDI   = 2
diskFormatToTag VMDK  = 3
diskFormatToTag VHD   = 4

||| Decode an ABI tag to a DiskFormat.
public export
tagToDiskFormat : Bits8 -> Maybe DiskFormat
tagToDiskFormat 0 = Just Raw
tagToDiskFormat 1 = Just QCOW2
tagToDiskFormat 2 = Just VDI
tagToDiskFormat 3 = Just VMDK
tagToDiskFormat 4 = Just VHD
tagToDiskFormat _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all DiskFormat values.
public export
diskFormatRoundtrip : (d : DiskFormat) -> tagToDiskFormat (diskFormatToTag d) = Just d
diskFormatRoundtrip Raw   = Refl
diskFormatRoundtrip QCOW2 = Refl
diskFormatRoundtrip VDI   = Refl
diskFormatRoundtrip VMDK  = Refl
diskFormatRoundtrip VHD   = Refl

---------------------------------------------------------------------------
-- NetworkType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
networkTypeSize : Nat
networkTypeSize = 1

||| Encode a NetworkType to its ABI tag value.
public export
networkTypeToTag : NetworkType -> Bits8
networkTypeToTag NAT      = 0
networkTypeToTag Bridged  = 1
networkTypeToTag Internal = 2
networkTypeToTag HostOnly = 3

||| Decode an ABI tag to a NetworkType.
public export
tagToNetworkType : Bits8 -> Maybe NetworkType
tagToNetworkType 0 = Just NAT
tagToNetworkType 1 = Just Bridged
tagToNetworkType 2 = Just Internal
tagToNetworkType 3 = Just HostOnly
tagToNetworkType _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all NetworkType values.
public export
networkTypeRoundtrip : (n : NetworkType) -> tagToNetworkType (networkTypeToTag n) = Just n
networkTypeRoundtrip NAT      = Refl
networkTypeRoundtrip Bridged  = Refl
networkTypeRoundtrip Internal = Refl
networkTypeRoundtrip HostOnly = Refl

---------------------------------------------------------------------------
-- BootDevice (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
bootDeviceSize : Nat
bootDeviceSize = 1

||| Encode a BootDevice to its ABI tag value.
public export
bootDeviceToTag : BootDevice -> Bits8
bootDeviceToTag HardDisk = 0
bootDeviceToTag CDROM    = 1
bootDeviceToTag Network  = 2
bootDeviceToTag USB      = 3

||| Decode an ABI tag to a BootDevice.
public export
tagToBootDevice : Bits8 -> Maybe BootDevice
tagToBootDevice 0 = Just HardDisk
tagToBootDevice 1 = Just CDROM
tagToBootDevice 2 = Just Network
tagToBootDevice 3 = Just USB
tagToBootDevice _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all BootDevice values.
public export
bootDeviceRoundtrip : (b : BootDevice) -> tagToBootDevice (bootDeviceToTag b) = Just b
bootDeviceRoundtrip HardDisk = Refl
bootDeviceRoundtrip CDROM    = Refl
bootDeviceRoundtrip Network  = Refl
bootDeviceRoundtrip USB      = Refl
