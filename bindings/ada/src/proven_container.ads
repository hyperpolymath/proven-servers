-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-container protocol (Container runtime).
--
-- Wraps the C-ABI functions from protocols/proven-container/ffi/zig/src/container.zig:
--   container_abi_version, container_create_context, container_destroy_context,
--   container_state, container_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Container is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `ContainerState` in `ContainerABI.Types`.
   type Container_State is
     (Creating,
      Running,
      Paused,
      Restarting,
      Stopped,
      Removing,
      Dead);
   pragma Convention (C, Container_State);

   -- Matches `ContainerOperation` in `ContainerABI.Types`.
   type Container_Operation is
     (Create,
      Start,
      Stop,
      Restart,
      Pause,
      Unpause,
      Kill,
      Remove,
      Exec,
      Logs,
      Inspect);
   pragma Convention (C, Container_Operation);

   -- Matches `NetworkMode` in `ContainerABI.Types`.
   type Network_Mode is
     (Bridge,
      Host,
      None,
      Overlay,
      Macvlan);
   pragma Convention (C, Network_Mode);

   -- Matches `VolumeType` in `ContainerABI.Types`.
   type Volume_Type is
     (Bind,
      Named,
      Tmpfs);
   pragma Convention (C, Volume_Type);

   -- Matches `RestartPolicy` in `ContainerABI.Types`.
   type Restart_Policy is
     (No,
      Always,
      On_Failure,
      Unless_Stopped);
   pragma Convention (C, Restart_Policy);

   -- Matches `HealthStatus` in `ContainerABI.Types`.
   type Health_Status is
     (Starting,
      Healthy,
      Unhealthy,
      No_Check);
   pragma Convention (C, Health_Status);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "container_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "container_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "container_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "container_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "container_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Container;
