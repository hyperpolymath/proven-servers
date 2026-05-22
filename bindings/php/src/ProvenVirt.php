<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Virtualization protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** VmState matching the Idris2 ABI tags. */
enum VmState: int
{
    case Creating = 0;
    case Running = 1;
    case Paused = 2;
    case Suspended = 3;
    case ShuttingDown = 4;
    case Stopped = 5;
    case Crashed = 6;
    case Migrating = 7;
}

/** VirtOperation matching the Idris2 ABI tags. */
enum VirtOperation: int
{
    case Create = 0;
    case Start = 1;
    case Stop = 2;
    case Restart = 3;
    case Pause = 4;
    case Resume = 5;
    case Suspend = 6;
    case Migrate = 7;
    case Snapshot = 8;
    case Clone = 9;
    case Delete = 10;
}

/** DiskFormat matching the Idris2 ABI tags. */
enum DiskFormat: int
{
    case Raw = 0;
    case Qcow2 = 1;
    case Vdi = 2;
    case Vmdk = 3;
    case Vhd = 4;
}

/** NetworkType matching the Idris2 ABI tags. */
enum NetworkType: int
{
    case Nat = 0;
    case Bridged = 1;
    case Internal = 2;
    case HostOnly = 3;
}

/** BootDevice matching the Idris2 ABI tags. */
enum BootDevice: int
{
    case HardDisk = 0;
    case Cdrom = 1;
    case Network = 2;
    case Usb = 3;
}
