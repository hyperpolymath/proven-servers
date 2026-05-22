-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-virt protocol (Virtualization/Hypervisor).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Virt is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- VM lifecycle states (tags 0-7).
   type Vm_State is
     (Vm_Creating, Vm_Running, Vm_Paused, Vm_Suspended,
      Vm_Shutting_Down, Vm_Stopped, Vm_Crashed, Vm_Migrating);
   for Vm_State use
     (Vm_Creating      => 0, Vm_Running       => 1,
      Vm_Paused        => 2, Vm_Suspended     => 3,
      Vm_Shutting_Down => 4, Vm_Stopped       => 5,
      Vm_Crashed       => 6, Vm_Migrating     => 7);
   pragma Convention (C, Vm_State);

   -- VM operations (tags 0-10).
   type Virt_Operation is
     (Op_Create, Op_Start, Op_Stop, Op_Restart, Op_Pause,
      Op_Resume, Op_Suspend, Op_Migrate, Op_Snapshot, Op_Clone, Op_Delete);
   for Virt_Operation use
     (Op_Create  => 0,  Op_Start   => 1,  Op_Stop     => 2,
      Op_Restart => 3,  Op_Pause   => 4,  Op_Resume   => 5,
      Op_Suspend => 6,  Op_Migrate => 7,  Op_Snapshot => 8,
      Op_Clone   => 9,  Op_Delete  => 10);
   pragma Convention (C, Virt_Operation);

   -- Disk formats (tags 0-4).
   type Disk_Format is (Dfmt_Raw, Dfmt_Qcow2, Dfmt_Vdi, Dfmt_Vmdk, Dfmt_Vhd);
   for Disk_Format use
     (Dfmt_Raw => 0, Dfmt_Qcow2 => 1, Dfmt_Vdi => 2,
      Dfmt_Vmdk => 3, Dfmt_Vhd => 4);
   pragma Convention (C, Disk_Format);

   -- Network types (tags 0-3).
   type Network_Type is (Net_Nat, Net_Bridged, Net_Internal, Net_Host_Only);
   for Network_Type use
     (Net_Nat => 0, Net_Bridged => 1, Net_Internal => 2, Net_Host_Only => 3);
   pragma Convention (C, Network_Type);

   -- Boot devices (tags 0-3).
   type Boot_Device is (Boot_Hard_Disk, Boot_Cdrom, Boot_Network, Boot_Usb);
   for Boot_Device use
     (Boot_Hard_Disk => 0, Boot_Cdrom => 1, Boot_Network => 2, Boot_Usb => 3);
   pragma Convention (C, Boot_Device);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "virt_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "virt_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "virt_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "virt_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "virt_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Virt;
