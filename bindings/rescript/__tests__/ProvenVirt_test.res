// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenVirt protocol bindings.

open ProvenVirt

let test_vmState_roundtrip = () => {
  assert(vmStateFromTag(0) == Some(Creating))
  assert(vmStateFromTag(1) == Some(Running))
  assert(vmStateFromTag(2) == Some(Paused))
  assert(vmStateFromTag(3) == Some(Suspended))
  assert(vmStateFromTag(4) == Some(ShuttingDown))
  assert(vmStateFromTag(5) == Some(Stopped))
  assert(vmStateFromTag(6) == Some(Crashed))
  assert(vmStateFromTag(7) == Some(Migrating))
  assert(vmStateFromTag(8) == None)
}

let test_vmState_toTag = () => {
  assert(vmStateToTag(Creating) == 0)
  assert(vmStateToTag(Running) == 1)
  assert(vmStateToTag(Paused) == 2)
  assert(vmStateToTag(Suspended) == 3)
  assert(vmStateToTag(ShuttingDown) == 4)
  assert(vmStateToTag(Stopped) == 5)
  assert(vmStateToTag(Crashed) == 6)
  assert(vmStateToTag(Migrating) == 7)
}

let test_virtOperation_roundtrip = () => {
  assert(virtOperationFromTag(0) == Some(Create))
  assert(virtOperationFromTag(1) == Some(Start))
  assert(virtOperationFromTag(2) == Some(Stop))
  assert(virtOperationFromTag(3) == Some(Restart))
  assert(virtOperationFromTag(4) == Some(Pause))
  assert(virtOperationFromTag(5) == Some(Resume))
  assert(virtOperationFromTag(6) == Some(Suspend))
  assert(virtOperationFromTag(7) == Some(Migrate))
  assert(virtOperationFromTag(8) == Some(Snapshot))
  assert(virtOperationFromTag(9) == Some(Clone))
  assert(virtOperationFromTag(10) == Some(Delete))
  assert(virtOperationFromTag(11) == None)
}

let test_virtOperation_toTag = () => {
  assert(virtOperationToTag(Create) == 0)
  assert(virtOperationToTag(Start) == 1)
  assert(virtOperationToTag(Stop) == 2)
  assert(virtOperationToTag(Restart) == 3)
  assert(virtOperationToTag(Pause) == 4)
  assert(virtOperationToTag(Resume) == 5)
  assert(virtOperationToTag(Suspend) == 6)
  assert(virtOperationToTag(Migrate) == 7)
  assert(virtOperationToTag(Snapshot) == 8)
  assert(virtOperationToTag(Clone) == 9)
  assert(virtOperationToTag(Delete) == 10)
}

let test_diskFormat_roundtrip = () => {
  assert(diskFormatFromTag(0) == Some(Raw))
  assert(diskFormatFromTag(1) == Some(Qcow2))
  assert(diskFormatFromTag(2) == Some(Vdi))
  assert(diskFormatFromTag(3) == Some(Vmdk))
  assert(diskFormatFromTag(4) == Some(Vhd))
  assert(diskFormatFromTag(5) == None)
}

let test_diskFormat_toTag = () => {
  assert(diskFormatToTag(Raw) == 0)
  assert(diskFormatToTag(Qcow2) == 1)
  assert(diskFormatToTag(Vdi) == 2)
  assert(diskFormatToTag(Vmdk) == 3)
  assert(diskFormatToTag(Vhd) == 4)
}

let test_networkType_roundtrip = () => {
  assert(networkTypeFromTag(0) == Some(Nat))
  assert(networkTypeFromTag(1) == Some(Bridged))
  assert(networkTypeFromTag(2) == Some(Internal))
  assert(networkTypeFromTag(3) == Some(HostOnly))
  assert(networkTypeFromTag(4) == None)
}

let test_networkType_toTag = () => {
  assert(networkTypeToTag(Nat) == 0)
  assert(networkTypeToTag(Bridged) == 1)
  assert(networkTypeToTag(Internal) == 2)
  assert(networkTypeToTag(HostOnly) == 3)
}

let test_bootDevice_roundtrip = () => {
  assert(bootDeviceFromTag(0) == Some(HardDisk))
  assert(bootDeviceFromTag(1) == Some(Cdrom))
  assert(bootDeviceFromTag(2) == Some(Network))
  assert(bootDeviceFromTag(3) == Some(Usb))
  assert(bootDeviceFromTag(4) == None)
}

let test_bootDevice_toTag = () => {
  assert(bootDeviceToTag(HardDisk) == 0)
  assert(bootDeviceToTag(Cdrom) == 1)
  assert(bootDeviceToTag(Network) == 2)
  assert(bootDeviceToTag(Usb) == 3)
}

// Run all tests
test_vmState_roundtrip()
test_vmState_toTag()
test_virtOperation_roundtrip()
test_virtOperation_toTag()
test_diskFormat_roundtrip()
test_diskFormat_toTag()
test_networkType_roundtrip()
test_networkType_toTag()
test_bootDevice_roundtrip()
test_bootDevice_toTag()
