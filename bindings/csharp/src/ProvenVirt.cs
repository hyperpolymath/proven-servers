// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Virtualization protocol types for proven-servers.

namespace Proven;

/// <summary>VmState matching the Idris2 ABI tags (0-7).</summary>
public enum VmState : byte
{
    Creating = 0,
    Running = 1,
    Paused = 2,
    Suspended = 3,
    ShuttingDown = 4,
    Stopped = 5,
    Crashed = 6,
    Migrating = 7
}

/// <summary>VirtOperation matching the Idris2 ABI tags (0-10).</summary>
public enum VirtOperation : byte
{
    Create = 0,
    Start = 1,
    Stop = 2,
    Restart = 3,
    Pause = 4,
    Resume = 5,
    Suspend = 6,
    Migrate = 7,
    Snapshot = 8,
    Clone = 9,
    Delete = 10
}

/// <summary>DiskFormat matching the Idris2 ABI tags (0-4).</summary>
public enum DiskFormat : byte
{
    Raw = 0,
    Qcow2 = 1,
    Vdi = 2,
    Vmdk = 3,
    Vhd = 4
}

/// <summary>NetworkType matching the Idris2 ABI tags (0-3).</summary>
public enum NetworkType : byte
{
    Nat = 0,
    Bridged = 1,
    Internal = 2,
    HostOnly = 3
}

/// <summary>BootDevice matching the Idris2 ABI tags (0-3).</summary>
public enum BootDevice : byte
{
    HardDisk = 0,
    Cdrom = 1,
    Network = 2,
    Usb = 3
}
