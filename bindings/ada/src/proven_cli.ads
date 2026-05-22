-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-cli protocol (CLI tool protocol).
--
-- Wraps the C-ABI functions from protocols/proven-cli/ffi/zig/src/cli.zig:
--   cli_abi_version, cli_create_context, cli_destroy_context,
--   cli_state, cli_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Cli is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- CLI command types.
   type Command_Type is
     (Execute,
      Help,
      Version,
      Config,
      Status);
   pragma Convention (C, Command_Type);

   -- CLI output formats.
   type Output_Format is
     (Text,
      Json,
      Table,
      Quiet);
   pragma Convention (C, Output_Format);

   -- CLI verbosity levels.
   type Verbosity is
     (Silent,
      Normal,
      Verbose,
      V_Debug);
   pragma Convention (C, Verbosity);

   -- CLI exit codes.
   type Exit_Code is
     (Ec_Success,
      General_Error,
      Usage_Error,
      Data_Error,
      Internal_Error);
   pragma Convention (C, Exit_Code);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "cli_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "cli_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "cli_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "cli_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "cli_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Cli;
