-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-appserver protocol (Application server).
--
-- Wraps the C-ABI functions from protocols/proven-appserver/ffi/zig/src/appserver.zig:
--   appserver_abi_version, appserver_create_context, appserver_destroy_context,
--   appserver_state, appserver_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Appserver is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `RequestType` in `AppserverABI.Types`.
   type Request_Type is
     (Http,
      Web_Socket,
      Grpc,
      Graph_Ql);
   pragma Convention (C, Request_Type);

   -- Matches `LifecycleState` in `AppserverABI.Types`.
   type Lifecycle_State is
     (Initializing,
      Starting,
      Running,
      Draining,
      Stopping,
      Stopped);
   pragma Convention (C, Lifecycle_State);

   -- Matches `HealthCheck` in `AppserverABI.Types`.
   type Health_Check is
     (Liveness,
      Readiness,
      Startup);
   pragma Convention (C, Health_Check);

   -- Matches `DeployStrategy` in `AppserverABI.Types`.
   type Deploy_Strategy is
     (Rolling_Update,
      Blue_Green,
      Canary,
      Recreate);
   pragma Convention (C, Deploy_Strategy);

   -- Matches `ErrorCategory` in `AppserverABI.Types`.
   type Error_Category is
     (Client_Error,
      Server_Error,
      Timeout,
      Circuit_Open,
      Rate_Limited);
   pragma Convention (C, Error_Category);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "appserver_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "appserver_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "appserver_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "appserver_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "appserver_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Appserver;
