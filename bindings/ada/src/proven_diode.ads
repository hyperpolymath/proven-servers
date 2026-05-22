-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-diode protocol (Data diode (unidirectional network)).
--
-- Wraps the C-ABI functions from protocols/proven-diode/ffi/zig/src/diode.zig:
--   diode_abi_version, diode_create_context, diode_destroy_context,
--   diode_state, diode_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Diode is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `Direction` in `DiodeABI.Types`.
   type Direction is
     (High_To_Low,
      Low_To_High);
   pragma Convention (C, Direction);

   -- Matches `DiodeProtocol` in `DiodeABI.Types`.
   type Diode_Protocol is
     (Udp,
      Tcp,
      File_Transfer,
      Syslog,
      Snmp);
   pragma Convention (C, Diode_Protocol);

   -- Matches `TransferState` in `DiodeABI.Types`.
   type Transfer_State is
     (Queued,
      Sending,
      Confirming,
      Complete,
      Failed);
   pragma Convention (C, Transfer_State);

   -- Matches `ValidationResult` in `DiodeABI.Types`.
   type Validation_Result is
     (Passed,
      Format_Error,
      Size_Exceeded,
      Policy_Blocked);
   pragma Convention (C, Validation_Result);

   -- Matches `IntegrityCheck` in `DiodeABI.Types`.
   type Integrity_Check is
     (Crc32,
      Sha256,
      Hmac);
   pragma Convention (C, Integrity_Check);

   -- Matches `GatewayState` in `DiodeABI.Types`.
   type Gateway_State is
     (Idle,
      Configured,
      Transferring,
      Validating,
      Shutdown);
   pragma Convention (C, Gateway_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "diode_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "diode_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "diode_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "diode_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "diode_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Diode;
